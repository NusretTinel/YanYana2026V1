import 'package:cloud_firestore/cloud_firestore.dart';

enum CampaignStatus { pending, active, completed, rejected }

extension CampaignStatusExt on CampaignStatus {
  String get value {
    switch (this) {
      case CampaignStatus.pending:
        return 'pending';
      case CampaignStatus.active:
        return 'active';
      case CampaignStatus.completed:
        return 'completed';
      case CampaignStatus.rejected:
        return 'rejected';
    }
  }

  static CampaignStatus fromValue(String? value) {
    switch (value) {
      case 'active':
        return CampaignStatus.active;
      case 'completed':
        return CampaignStatus.completed;
      case 'rejected':
        return CampaignStatus.rejected;
      default:
        return CampaignStatus.pending;
    }
  }
}

class DonationCampaign {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final double targetAmount;
  double collectedAmount;
  final DateTime endDate;
  final DateTime? createdAt;

  // Moderasyon
  CampaignStatus status;
  final String creatorId;
  final String creatorName;

  DonationCampaign({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.targetAmount,
    this.collectedAmount = 0.0,
    required this.endDate,
    this.createdAt,
    this.status = CampaignStatus.pending,
    required this.creatorId,
    required this.creatorName,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = collectedAmount / targetAmount;
    return progress > 1.0 ? 1.0 : progress;
  }

  factory DonationCampaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationCampaign(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      collectedAmount: (data['collectedAmount'] as num?)?.toDouble() ?? 0.0,
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      status: CampaignStatusExt.fromValue(data['status'] as String?),
      creatorId: data['creatorId'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? 'Kullanıcı',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'targetAmount': targetAmount,
      'collectedAmount': collectedAmount,
      'endDate': Timestamp.fromDate(endDate),
      'status': status.value,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class Sponsor {
  final String id;
  final String name;
  final String logoUrl;
  final String tier;

  Sponsor({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.tier,
  });

  factory Sponsor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sponsor(
      id: doc.id,
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String? ?? '',
      tier: data['tier'] as String? ?? '',
    );
  }
}

class DonationRecord {
  final String campaignId;
  final String userId;
  final String userName;
  final double amount;
  final DateTime createdAt;

  DonationRecord({
    required this.campaignId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'campaignId': campaignId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class TopDonor {
  final String userId;
  final String userName;
  final double totalAmount;

  TopDonor({
    required this.userId,
    required this.userName,
    required this.totalAmount,
  });

  String get disabilityFriendlyTitle {
    // Determine the title based on the ranking or arbitrary values
    // We will assign titles in the UI where we know the rank, or here by amount.
    if (totalAmount >= 10000) return 'Engelsiz Kahraman';
    if (totalAmount >= 5000) return 'Umut Işığı';
    if (totalAmount >= 1000) return 'Yol Arkadaşı';
    if (totalAmount >= 500) return 'Gönül Elçisi';
    if (totalAmount >= 100) return 'İyilik Meleği';
    return 'Destekçi';
  }
}
