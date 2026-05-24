import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/features/donation/models/donation_model.dart';

class DonationService {
  DonationService._();
  static final DonationService instance = DonationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _campaignsRef =>
      _db.collection('campaigns');

  CollectionReference<Map<String, dynamic>> get _sponsorsRef =>
      _db.collection('sponsors');

  CollectionReference<Map<String, dynamic>> get _donationsRef =>
      _db.collection('donations');

  // ─── Kampanya Okuma ───────────────────────────────────────────────────────

  /// Normal kullanıcılar için: sadece aktif ve tamamlanmış kampanyalar
  /// (composite index gerektirmemesi için sıralama client-side yapılıyor)
  Stream<List<DonationCampaign>> streamPublicCampaigns() {
    return _campaignsRef
        .where('status', whereIn: ['active', 'completed'])
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(DonationCampaign.fromFirestore).toList();
          list.sort((a, b) {
            final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
            return tb.compareTo(ta);
          });
          return list;
        });
  }

  /// Moderatör/Admin için: tüm kampanyalar
  Stream<List<DonationCampaign>> streamAllCampaigns() {
    return _campaignsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DonationCampaign.fromFirestore).toList());
  }

  // ─── Kampanya Yazma ───────────────────────────────────────────────────────

  /// Yeni kampanya oluştur (status = pending — moderasyon bekler)
  Future<String> createCampaign({
    required String title,
    required String description,
    required double targetAmount,
    required DateTime endDate,
    required String creatorId,
    required String creatorName,
    String? coverImageUrl,
  }) async {
    final campaign = DonationCampaign(
      id: '',
      title: title,
      description: description,
      targetAmount: targetAmount,
      endDate: endDate,
      creatorId: creatorId,
      creatorName: creatorName,
      coverImageUrl: coverImageUrl,
      status: CampaignStatus.pending,
    );

    final docRef = await _campaignsRef.add(campaign.toFirestore());
    return docRef.id;
  }

  /// Moderatör/Admin kampanyayı onaylar
  Future<void> approveCampaign(String campaignId) async {
    await _campaignsRef.doc(campaignId).update({
      'status': 'active',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Moderatör/Admin kampanyayı reddeder
  Future<void> rejectCampaign(String campaignId) async {
    await _campaignsRef.doc(campaignId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Bağış İşlemi ─────────────────────────────────────────────────────────

  /// Bağış yap: donations koleksiyonuna kayıt + campaign.collectedAmount artır
  Future<void> makeDonation({
    required String campaignId,
    required String userId,
    required String userName,
    required double amount,
  }) async {
    final batch = _db.batch();

    // 1) donations koleksiyonuna kayıt
    final donationRef = _donationsRef.doc();
    batch.set(donationRef, {
      'campaignId': campaignId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2) kampanyanın toplanan tutarını artır
    final campaignRef = _campaignsRef.doc(campaignId);
    batch.update(campaignRef, {
      'collectedAmount': FieldValue.increment(amount),
    });

    await batch.commit();
  }

  // ─── Sponsor Okuma ────────────────────────────────────────────────────────

  Stream<List<Sponsor>> streamSponsors() {
    return _sponsorsRef
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(Sponsor.fromFirestore).toList();
          list.sort((a, b) => a.tier.compareTo(b.tier));
          return list;
        });
  }

  // ─── En Çok Bağış Yapanlar ────────────────────────────────────────────────

  Future<List<TopDonor>> getTopDonors() async {
    final snap = await _donationsRef.get();
    
    // Aggregation: Map<userId, Map<name, total>>
    final Map<String, Map<String, dynamic>> userTotals = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final userId = data['userId'] as String? ?? 'unknown';
      final userName = data['userName'] as String? ?? 'İsimsiz Kahraman';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

      if (!userTotals.containsKey(userId)) {
        userTotals[userId] = {'name': userName, 'total': 0.0};
      }
      userTotals[userId]!['total'] += amount;
    }

    final donors = userTotals.entries.map((e) {
      return TopDonor(
        userId: e.key,
        userName: e.value['name'] as String,
        totalAmount: e.value['total'] as double,
      );
    }).toList();

    // En çok bağış yapana göre azalan sırada sırala
    donors.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // İlk 10'u döndür
    return donors.take(10).toList();
  }
}
