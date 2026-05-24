import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yanyana_p/core/constants/place_categories.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/core/firebase/place_document_mapper.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/accessibility_review.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';

/// Firestore accessible places (client-side SDK only).
class PlaceService {
  PlaceService._();

  static final PlaceService instance = PlaceService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _places =>
      _db.collection(FirestoreCollections.accessiblePlaces);

  List<AccessiblePlace> _mapPlaces(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((d) => PlaceDocumentMapper.fromFirestore(d.id, d.data()))
        .toList();
  }

  Stream<List<AccessiblePlace>> streamPlaces() {
    return _places.snapshots().map((snap) => _mapPlaces(snap.docs));
  }

  Future<List<AccessiblePlace>> getPlaces() async {
    try {
      final snap = await _places.get();
      return _mapPlaces(snap.docs);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<AccessiblePlace> addPlace({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required String description,
    required double rating,
    required bool wheelchairAccessible,
    required bool hasAccessibleToilet,
    required bool hasElevator,
    required bool hasRamp,
    required bool hearingSupport,
    required bool visualSupport,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Oturum açmanız gerekiyor.');

    final ref = _places.doc();
    final data = PlaceDocumentMapper.toFirestore(
      id: ref.id,
      createdByUid: uid,
      name: name.trim(),
      category: category,
      description: description.trim(),
      ratingAverage: rating.clamp(1, 5),
      ratingCount: 0,
      wheelchairAccessible: wheelchairAccessible,
      accessibleRestroom: hasAccessibleToilet,
      elevator: hasElevator,
      ramp: hasRamp,
      hearingSupport: hearingSupport,
      visualSupport: visualSupport,
      latitude: latitude,
      longitude: longitude,
    );
    await ref.set(data);
    final snap = await ref.get();
    return PlaceDocumentMapper.fromFirestore(ref.id, snap.data()!);
  }

  Future<AccessiblePlace> updatePlace(AccessiblePlace place) async {
    final data = PlaceDocumentMapper.toFirestore(
      id: place.id,
      createdByUid: place.createdByUid,
      name: place.name,
      category: place.category,
      description: place.description,
      ratingAverage: place.rating,
      ratingCount: place.userCommentCount,
      wheelchairAccessible: place.wheelchairAccessible,
      accessibleRestroom: place.hasAccessibleToilet,
      elevator: place.hasElevator,
      ramp: place.hasRamp,
      hearingSupport: place.hearingSupport,
      visualSupport: place.visualSupport,
      latitude: place.latitude,
      longitude: place.longitude,
      isUpdate: true,
    );
    await _places.doc(place.id).update(data);
    final snap = await _places.doc(place.id).get();
    return PlaceDocumentMapper.fromFirestore(place.id, snap.data()!);
  }

  Future<void> deletePlace(String placeId) async {
    final reviews = await _places.doc(placeId).collection(FirestoreCollections.reviews).get();
    final batch = _db.batch();
    for (final doc in reviews.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_places.doc(placeId));
    await batch.commit();
  }

  AccessiblePlace _fallbackPlace(String placeId) => AccessiblePlace(
        id: placeId,
        externalId: '',
        source: '',
        name: '',
        category: '',
        latitude: 0,
        longitude: 0,
        distance: '',
        rating: 0,
        tags: const [],
        wheelchairAccessible: false,
        hasRamp: false,
        hasElevator: false,
        hasAccessibleToilet: false,
        hasQuietArea: false,
        corridorWide: false,
        userCommentCount: 0,
        color: YanYanaColors.primary,
      );

  List<AccessibilityReview> _mapReviews(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    AccessiblePlace placeSnapshot,
  ) {
    final list = docs
        .map(
          (d) => PlaceDocumentMapper.reviewFromFirestore(
            d.id,
            d.data(),
            placeSnapshot,
          ),
        )
        .toList();
    sortByNewest(list, (r) => r.createdAt);
    return list;
  }

  Stream<List<AccessibilityReview>> streamReviews(String placeId) {
    return _places
        .doc(placeId)
        .collection(FirestoreCollections.reviews)
        .snapshots()
        .asyncMap((snap) async {
      final placeSnap = await _places.doc(placeId).get();
      final place = placeSnap.exists
          ? PlaceDocumentMapper.fromFirestore(placeId, placeSnap.data()!)
          : _fallbackPlace(placeId);
      return _mapReviews(snap.docs, place);
    });
  }

  Future<List<AccessibilityReview>> getReviews(String placeId) async {
    final placeSnap = await _places.doc(placeId).get();
    if (!placeSnap.exists) return [];
    final place = PlaceDocumentMapper.fromFirestore(placeId, placeSnap.data()!);
    final snap = await _places
        .doc(placeId)
        .collection(FirestoreCollections.reviews)
        .get();
    return _mapReviews(snap.docs, place);
  }

  Future<AccessibilityReview> addReview({
    required String placeId,
    required String comment,
    required double rating,
    required AccessiblePlace placeSnapshot,
    required String userName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Oturum açmanız gerekiyor.');
    if (comment.trim().isEmpty) {
      throw ArgumentError('Yorum boş olamaz.');
    }

    final reviewRef =
        _places.doc(placeId).collection(FirestoreCollections.reviews).doc();
    final reviewData = PlaceDocumentMapper.reviewToFirestore(
      id: reviewRef.id,
      placeId: placeId,
      userId: uid,
      userName: userName,
      rating: rating.clamp(1, 5),
      comment: comment.trim(),
    );
    await reviewRef.set(reviewData);
    await updatePlaceRating(placeId);

    final saved = await reviewRef.get();
    return PlaceDocumentMapper.reviewFromFirestore(
      reviewRef.id,
      saved.data() ?? reviewData,
      placeSnapshot,
    );
  }

  Future<void> updatePlaceRating(String placeId) async {
    final snap = await _places
        .doc(placeId)
        .collection(FirestoreCollections.reviews)
        .get();
    if (snap.docs.isEmpty) {
      await _places.doc(placeId).update({
        'ratingAverage': 0,
        'ratingCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    var sum = 0.0;
    for (final doc in snap.docs) {
      sum += (doc.data()['rating'] as num).toDouble();
    }
    final avg = sum / snap.docs.length;
    await _places.doc(placeId).update({
      'ratingAverage': double.parse(avg.toStringAsFixed(1)),
      'ratingCount': snap.docs.length,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<AccessiblePlace> filterPlaces({
    required List<AccessiblePlace> places,
    String searchQuery = '',
    String categoryFilter = 'Tümü',
    Set<String> accessibilityFilters = const {},
  }) {
    var result = places;
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) {
        final hay =
            '${p.name} ${p.category} ${p.description}'.toLowerCase();
        return hay.contains(q);
      }).toList();
    }
    if (categoryFilter != 'Tümü') {
      result = result.where((p) => p.category == categoryFilter).toList();
    }
    for (final f in accessibilityFilters) {
      result = result.where((p) {
        switch (f) {
          case 'wheelchair':
            return p.wheelchairAccessible;
          case 'restroom':
            return p.hasAccessibleToilet;
          case 'elevator':
            return p.hasElevator;
          case 'ramp':
            return p.hasRamp;
          case 'hearing':
            return p.hearingSupport;
          case 'visual':
            return p.visualSupport;
          default:
            return true;
        }
      }).toList();
    }
    return result;
  }

  static List<String> get categoryFilters => ['Tümü', ...PlaceCategories.all];
}
