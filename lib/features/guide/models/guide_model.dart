import 'package:cloud_firestore/cloud_firestore.dart';

enum GuideCategory { dailyTasks, recipes, socialSkills, other }

extension GuideCategoryExt on GuideCategory {
  String get value {
    switch (this) {
      case GuideCategory.dailyTasks:
        return 'daily_tasks';
      case GuideCategory.recipes:
        return 'recipes';
      case GuideCategory.socialSkills:
        return 'social_skills';
      case GuideCategory.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case GuideCategory.dailyTasks:
        return 'Günlük İşler';
      case GuideCategory.recipes:
        return 'Yemek Tarifleri';
      case GuideCategory.socialSkills:
        return 'Sosyal Beceriler';
      case GuideCategory.other:
        return 'Diğer';
    }
  }

  static GuideCategory fromValue(String? value) {
    switch (value) {
      case 'daily_tasks':
        return GuideCategory.dailyTasks;
      case 'recipes':
        return GuideCategory.recipes;
      case 'social_skills':
        return GuideCategory.socialSkills;
      default:
        return GuideCategory.other;
    }
  }
}

class GuideStep {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  bool isCompleted;

  GuideStep({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.isCompleted = false,
  });

  factory GuideStep.fromMap(Map<String, dynamic> map) {
    return GuideStep(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class Guide {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final GuideCategory category;
  final List<GuideStep> steps;

  // Moderasyon
  final bool isApproved;
  final String authorId;
  final String authorName;
  final String authorRole;

  // Etkileşim
  int likes;
  bool isFavorite;

  // İlerleme (local — Firestore'a ayrı koleksiyonda tutulabilir)
  int completedStepsCount;

  // Zaman damgası
  final DateTime? createdAt;

  Guide({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.steps,
    this.coverImageUrl,
    this.isApproved = false,
    required this.authorId,
    required this.authorName,
    this.authorRole = 'Gönüllü',
    this.likes = 0,
    this.isFavorite = false,
    this.completedStepsCount = 0,
    this.createdAt,
  });

  double get progressPercentage {
    if (steps.isEmpty) return 0.0;
    return completedStepsCount / steps.length;
  }

  factory Guide.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final stepsList = (data['steps'] as List<dynamic>?)
            ?.map((s) => GuideStep.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [];
    return Guide(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      category: GuideCategoryExt.fromValue(data['category'] as String?),
      steps: stepsList,
      isApproved: data['isApproved'] as bool? ?? false,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Kullanıcı',
      authorRole: data['authorRole'] as String? ?? 'Gönüllü',
      likes: data['likes'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      'category': category.value,
      'steps': steps.map((s) => s.toMap()).toList(),
      'isApproved': isApproved,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'likes': likes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
