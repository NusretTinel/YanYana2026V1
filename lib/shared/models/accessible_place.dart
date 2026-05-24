import 'package:flutter/material.dart';

/// User or imported accessible place (Firestore-ready shape).
class AccessiblePlace {
  final String id;
  final String externalId;
  final String source;
  final String createdByUid;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String distance;
  final double rating;
  final List<String> tags;
  final String description;
  final bool wheelchairAccessible;
  final bool hasRamp;
  final bool hasElevator;
  final bool hasAccessibleToilet;
  final bool hasQuietArea;
  final bool hearingSupport;
  final bool visualSupport;
  final bool corridorWide;
  final int userCommentCount;
  final Color color;

  const AccessiblePlace({
    required this.id,
    required this.externalId,
    required this.source,
    this.createdByUid = '',
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.rating,
    required this.tags,
    this.description = '',
    required this.wheelchairAccessible,
    required this.hasRamp,
    required this.hasElevator,
    required this.hasAccessibleToilet,
    required this.hasQuietArea,
    this.hearingSupport = false,
    this.visualSupport = false,
    required this.corridorWide,
    required this.userCommentCount,
    required this.color,
  });

  List<String> get accessibilityLabels {
    final labels = <String>[];
    if (wheelchairAccessible) labels.add('Tekerlekli sandalye');
    if (hasAccessibleToilet) labels.add('Erişilebilir tuvalet');
    if (hasElevator) labels.add('Asansör');
    if (hasRamp) labels.add('Rampa');
    if (hearingSupport) labels.add('İşitme desteği');
    if (visualSupport) labels.add('Görsel destek');
    if (hasQuietArea) labels.add('Sessiz alan');
    return labels;
  }

  AccessiblePlace copyWith({
    String? id,
    String? externalId,
    String? source,
    String? createdByUid,
    String? name,
    String? category,
    double? latitude,
    double? longitude,
    String? distance,
    double? rating,
    List<String>? tags,
    String? description,
    bool? wheelchairAccessible,
    bool? hasRamp,
    bool? hasElevator,
    bool? hasAccessibleToilet,
    bool? hasQuietArea,
    bool? hearingSupport,
    bool? visualSupport,
    bool? corridorWide,
    int? userCommentCount,
    Color? color,
  }) {
    return AccessiblePlace(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      source: source ?? this.source,
      createdByUid: createdByUid ?? this.createdByUid,
      name: name ?? this.name,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      hasRamp: hasRamp ?? this.hasRamp,
      hasElevator: hasElevator ?? this.hasElevator,
      hasAccessibleToilet: hasAccessibleToilet ?? this.hasAccessibleToilet,
      hasQuietArea: hasQuietArea ?? this.hasQuietArea,
      hearingSupport: hearingSupport ?? this.hearingSupport,
      visualSupport: visualSupport ?? this.visualSupport,
      corridorWide: corridorWide ?? this.corridorWide,
      userCommentCount: userCommentCount ?? this.userCommentCount,
      color: color ?? this.color,
    );
  }
}
