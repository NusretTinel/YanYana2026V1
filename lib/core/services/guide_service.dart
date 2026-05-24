import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/features/guide/models/guide_model.dart';

class GuideService {
  GuideService._();
  static final GuideService instance = GuideService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _guidesRef =>
      _db.collection('guides');

  // ─── Okuma ────────────────────────────────────────────────────────────────

  /// Normal kullanıcılar için: sadece onaylanmış rehberler
  /// (composite index gerektirmemesi için sıralama client-side yapılıyor)
  Stream<List<Guide>> streamApprovedGuides() {
    return _guidesRef
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final guides = snap.docs.map(Guide.fromFirestore).toList();
          guides.sort((a, b) {
            final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
            return tb.compareTo(ta);
          });
          return guides;
        });
  }

  /// Moderatör/Admin için: tüm rehberler (onaylı + beklemede)
  Stream<List<Guide>> streamAllGuides() {
    return _guidesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Guide.fromFirestore).toList());
  }

  /// Tek rehber detayını stream olarak getir
  Stream<Guide?> streamGuide(String guideId) {
    return _guidesRef.doc(guideId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Guide.fromFirestore(snap);
    });
  }

  // ─── Yazma ────────────────────────────────────────────────────────────────

  /// Gönüllü/Moderatör yeni rehber oluşturur (isApproved = false — moderasyon bekler)
  Future<String> createGuide({
    required String title,
    required String description,
    required GuideCategory category,
    required List<Map<String, String>> steps,
    required String authorId,
    required String authorName,
    required String authorRole,
    String? coverImageUrl,
  }) async {
    final guideSteps = steps.asMap().entries.map((e) {
      return GuideStep(
        id: 'step_${e.key}',
        title: e.value['title'] ?? '',
        description: e.value['description'] ?? '',
      );
    }).toList();

    final guide = Guide(
      id: '',
      title: title,
      description: description,
      category: category,
      steps: guideSteps,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      coverImageUrl: coverImageUrl,
      isApproved: false, // Moderasyon bekler
    );

    final docRef = await _guidesRef.add(guide.toFirestore());
    return docRef.id;
  }

  /// Moderatör/Admin rehberi onaylar
  Future<void> approveGuide(String guideId) async {
    await _guidesRef.doc(guideId).update({
      'isApproved': true,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Moderatör/Admin rehberi reddeder (siler)
  Future<void> rejectGuide(String guideId) async {
    await _guidesRef.doc(guideId).delete();
  }

  /// Beğeni sayısını artır (basit increment — idempotent değil, istersen userId bazlı yapılabilir)
  Future<void> likeGuide(String guideId) async {
    await _guidesRef.doc(guideId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
