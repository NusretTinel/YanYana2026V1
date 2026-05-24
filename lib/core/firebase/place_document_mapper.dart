import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/accessibility_review.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';

class PlaceDocumentMapper {
  PlaceDocumentMapper._();

  static AccessiblePlace fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final tags = <String>[];
    if (data['wheelchairAccessible'] == true) tags.add('Tekerlekli sandalye');
    if (data['accessibleRestroom'] == true) tags.add('Erişilebilir tuvalet');
    if (data['elevator'] == true) tags.add('Asansör');
    if (data['ramp'] == true) tags.add('Rampa');
    if (data['hearingSupport'] == true) tags.add('İşitme desteği');
    if (data['visualSupport'] == true) tags.add('Görsel destek');

    return AccessiblePlace(
      id: id,
      externalId: '',
      source: 'FIRESTORE',
      createdByUid: data['createdByUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'Diğer',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      distance: '—',
      rating: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
      tags: tags,
      description: data['description'] as String? ?? '',
      wheelchairAccessible: data['wheelchairAccessible'] as bool? ?? false,
      hasRamp: data['ramp'] as bool? ?? false,
      hasElevator: data['elevator'] as bool? ?? false,
      hasAccessibleToilet: data['accessibleRestroom'] as bool? ?? false,
      hasQuietArea: false,
      hearingSupport: data['hearingSupport'] as bool? ?? false,
      visualSupport: data['visualSupport'] as bool? ?? false,
      corridorWide: false,
      userCommentCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      color: YanYanaColors.primary,
    );
  }

  static Map<String, dynamic> toFirestore({
    required String id,
    required String createdByUid,
    required String name,
    required String category,
    required String description,
    required double ratingAverage,
    required int ratingCount,
    required bool wheelchairAccessible,
    required bool accessibleRestroom,
    required bool elevator,
    required bool ramp,
    required bool hearingSupport,
    required bool visualSupport,
    required double latitude,
    required double longitude,
    bool isUpdate = false,
  }) {
    return {
      'id': id,
      'createdByUid': createdByUid,
      'name': name,
      'category': category,
      'description': description,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'wheelchairAccessible': wheelchairAccessible,
      'accessibleRestroom': accessibleRestroom,
      'elevator': elevator,
      'ramp': ramp,
      'hearingSupport': hearingSupport,
      'visualSupport': visualSupport,
      'latitude': latitude,
      'longitude': longitude,
      if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> reviewToFirestore({
    required String id,
    required String placeId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) =>
      {
        'id': id,
        'placeId': placeId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static AccessibilityReview reviewFromFirestore(
    String id,
    Map<String, dynamic> data,
    AccessiblePlace placeSnapshot,
  ) {
    return AccessibilityReview(
      id: id,
      placeId: data['placeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      wheelchairAccessible: placeSnapshot.wheelchairAccessible,
      hasRamp: placeSnapshot.hasRamp,
      hasElevator: placeSnapshot.hasElevator,
      hasAccessibleToilet: placeSnapshot.hasAccessibleToilet,
      hasQuietArea: placeSnapshot.hasQuietArea,
      corridorWide: placeSnapshot.corridorWide,
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'] as String? ?? '',
      createdAt: parseFirestoreDate(data['createdAt']),
    );
  }
}
