import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/features/community/models/community_feed_content_type.dart';
import 'package:yanyana_p/features/community/utils/community_content_category.dart';
import 'package:yanyana_p/features/community/widgets/community_content_actions.dart';
import 'package:yanyana_p/features/community/widgets/community_content_form_sheet.dart';
import 'package:yanyana_p/shared/models/community_post.dart';
import 'package:yanyana_p/shared/models/success_story.dart';

/// Add / edit / delete flows for community feed content.
class CommunityContentManager {
  CommunityContentManager._();

  static String? get currentUserId =>
      BackendOrchestrator.instance.currentUser?.id;

  static bool canManagePost(CommunityPost post) {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return false;
    if (post.authorId.isEmpty) return kDebugMode;
    return post.authorId == uid;
  }

  static bool canManageStory(SuccessStory story) {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return false;
    if (story.userId.isEmpty) return kDebugMode;
    return story.userId == uid;
  }

  static Future<void> createContent(
    BuildContext context, {
    CommunityFeedContentType? initialType,
    bool lockType = false,
  }) async {
    final data = await CommunityContentFormSheet.show(
      context,
      initialType: initialType,
      lockType: lockType,
    );
    if (data == null || !context.mounted) return;

    try {
      await _saveNew(data);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım başarıyla eklendi.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Future<void> editPost(BuildContext context, CommunityPost post) async {
    if (!canManagePost(post)) return;

    final type = feedContentTypeForPost(post);
    final data = await CommunityContentFormSheet.show(
      context,
      isEditing: true,
      initialType: type,
      initialTitle: post.title,
      initialContent: post.body,
      lockType: true,
    );
    if (data == null || !context.mounted) return;

    try {
      await BackendOrchestrator.instance.updateCommunityPost(
        postId: post.id,
        title: normalizedPostTitle(type: data.type, title: data.title),
        content: data.content,
        postType: data.type.firestorePostType,
      );
      if (!context.mounted) return;
      CommunityContentActions.showUpdatedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Future<void> editStory(
    BuildContext context,
    SuccessStory story,
  ) async {
    if (!canManageStory(story)) return;

    final data = await CommunityContentFormSheet.show(
      context,
      isEditing: true,
      initialType: CommunityFeedContentType.successStory,
      initialTitle: story.title,
      initialContent: story.content,
      lockType: true,
    );
    if (data == null || !context.mounted) return;

    try {
      await BackendOrchestrator.instance.updateSuccessStory(
        storyId: story.id,
        title: data.title,
        content: data.content,
      );
      if (!context.mounted) return;
      CommunityContentActions.showUpdatedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Future<void> deletePost(
    BuildContext context,
    CommunityPost post,
  ) async {
    if (!canManagePost(post)) return;

    final confirmed = await CommunityContentActions.confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    try {
      await BackendOrchestrator.instance.deleteCommunityPost(post.id);
      if (!context.mounted) return;
      CommunityContentActions.showDeletedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Future<void> deleteStory(
    BuildContext context,
    SuccessStory story,
  ) async {
    if (!canManageStory(story)) return;

    final confirmed = await CommunityContentActions.confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    try {
      await BackendOrchestrator.instance.deleteSuccessStory(story.id);
      if (!context.mounted) return;
      CommunityContentActions.showDeletedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  static Future<void> _saveNew(CommunityContentFormData data) async {
    final backend = BackendOrchestrator.instance;
    switch (data.type) {
      case CommunityFeedContentType.successStory:
        await backend.addSuccessStory(
          title: data.title,
          content: data.content,
        );
      case CommunityFeedContentType.dailyQuote:
      case CommunityFeedContentType.communityPost:
        await backend.addCommunityPost(
          title: normalizedPostTitle(type: data.type, title: data.title),
          content: data.content,
          postType: data.type.firestorePostType,
        );
    }
  }
}
