class AccessibilityReview {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final bool wheelchairAccessible;
  final bool hasRamp;
  final bool hasElevator;
  final bool hasAccessibleToilet;
  final bool hasQuietArea;
  final bool corridorWide;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const AccessibilityReview({
    required this.id,
    required this.placeId,
    required this.userId,
    this.userName = '',
    required this.wheelchairAccessible,
    required this.hasRamp,
    required this.hasElevator,
    required this.hasAccessibleToilet,
    required this.hasQuietArea,
    required this.corridorWide,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
