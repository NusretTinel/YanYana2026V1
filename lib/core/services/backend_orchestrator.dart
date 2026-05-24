import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/firebase/firebase_bootstrap.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/chat_thread_service.dart';
import 'package:yanyana_p/core/services/community_post_service.dart';
import 'package:yanyana_p/core/services/community_service.dart';
import 'package:yanyana_p/core/services/matching_engine.dart';
import 'package:yanyana_p/core/services/notification_service.dart';
import 'package:yanyana_p/core/services/place_service.dart';
import 'package:yanyana_p/core/services/profile_service.dart';
import 'package:yanyana_p/core/services/request_manager.dart';
import 'package:yanyana_p/core/services/sos_service.dart';
import 'package:yanyana_p/core/services/success_story_service.dart';
import 'package:yanyana_p/core/services/support_request_service.dart';
import 'package:yanyana_p/core/services/trusted_contact_service.dart';
import 'package:yanyana_p/core/services/volunteer_service.dart';
import 'package:yanyana_p/core/services/volunteer_verification_service.dart';
import 'package:yanyana_p/shared/models/accessibility_review.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';
import 'package:yanyana_p/shared/models/app_user.dart';
import 'package:yanyana_p/shared/models/chat_thread.dart';
import 'package:yanyana_p/shared/models/community_post.dart';
import 'package:yanyana_p/shared/models/community_room.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';
import 'package:yanyana_p/shared/models/notification_model.dart';
import 'package:yanyana_p/shared/models/success_story.dart';
import 'package:yanyana_p/shared/models/support_request.dart';
import 'package:yanyana_p/shared/models/trusted_contact.dart';
import 'package:yanyana_p/shared/models/volunteer_application.dart';

/// Central coordinator — delegates to Firebase client services (no custom backend).
class BackendOrchestrator {
  BackendOrchestrator._()
      : matchingEngine = const MatchingEngine(),
        volunteerVerificationService = const VolunteerVerificationService() {
    notificationService = NotificationService(authService: authService);
    requestManager = RequestManager(
      matchingEngine: matchingEngine,
      notificationService: notificationService,
      supportRequestService: SupportRequestService.instance,
      chatThreadService: ChatThreadService.instance,
      authService: authService,
    );
  }

  static final BackendOrchestrator instance = BackendOrchestrator._();
  static bool _ready = false;

  final AuthService authService = AuthService.instance;
  final ProfileService profileService = ProfileService.instance;
  final PlaceService placeService = PlaceService.instance;
  final SOSService sosService = SOSService.instance;
  final CommunityService communityService = CommunityService.instance;
  final VolunteerService volunteerService = VolunteerService.instance;
  final SuccessStoryService successStoryService = SuccessStoryService.instance;
  final CommunityPostService communityPostService =
      CommunityPostService.instance;
  final TrustedContactService trustedContactService =
      TrustedContactService.instance;
  final ChatThreadService chatThreadService = ChatThreadService.instance;

  late final RequestManager requestManager;
  final MatchingEngine matchingEngine;
  final VolunteerVerificationService volunteerVerificationService;
  late final NotificationService notificationService;

  static Future<void> initialize() async {
    if (_ready) return;
    await FirebaseBootstrap.ensureInitialized();
    await instance.authService.refreshCurrentUser();
    _ready = true;
  }

  static bool get isReady => _ready;

  AppUser? get currentUser => authService.currentUser;

  Future<SupportRequest> createSupportRequest(SupportRequest request) {
    return requestManager.createSupportRequest(request);
  }

  Future<EmergencyRequest> triggerSOS({
    double? latitude,
    double? longitude,
    String source = 'map',
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    if (!user.hasEmergencyContact) {
      throw StateError(
        'SOS için profilde acil durum kişisi adı ve telefonu eklemelisiniz.',
      );
    }
    final req = await sosService.createSOSRequest(
      userId: user.id,
      userName: user.name,
      emergencyContactName: user.emergencyContactName,
      emergencyContactPhone: user.emergencyContactPhone,
      source: source,
      latitude: latitude,
      longitude: longitude,
    );
    await notificationService.addForCurrentUser(
      title: 'SOS kaydı oluşturuldu',
      message: 'Acil durum isteğiniz Firestore\'a kaydedildi.',
    );
    return req;
  }

  Stream<List<EmergencyRequest>> streamMapEmergencyRequests() {
    final user = authService.currentUser;
    if (user == null) return const Stream.empty();
    return sosService.streamUserSOSRequests(user.id).map(
          sosService.mapVisibleOnMap,
        );
  }

  List<EmergencyRequest> getMapEmergencyRequests() {
    final user = authService.currentUser;
    if (user == null) return const [];
    return const [];
  }

  Future<void> dismissMapEmergencyRequest(String requestId) async {
    await sosService.dismissRequest(requestId);
  }

  Future<void> startSafeCall({required String trustedContactId}) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    if (!user.hasEmergencyContact) {
      throw StateError('Güvenilir kişi bilgisi profilde tanımlı değil.');
    }
    await sosService.createSOSRequest(
      userId: user.id,
      userName: user.name,
      emergencyContactName: user.emergencyContactName,
      emergencyContactPhone: user.emergencyContactPhone,
      source: 'safe_call',
      message: 'Güvenli arama isteği',
    );
    await notificationService.addForCurrentUser(
      title: 'Güvenli arama',
      message: 'Güvenli arama isteğiniz kaydedildi.',
    );
  }

  Future<void> signOut() => authService.signOut();

  Future<AppUser> updateProfile({
    String? name,
    String? disabilityType,
    String? about,
    String? voiceIntro,
    List<String>? interests,
    List<String>? accessibilityNeeds,
    List<String>? communicationPreferences,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
    List<String>? businessFacilities,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    final updated = await profileService.updateProfile(
      uid: user.id,
      name: name?.trim(),
      disabilityType: disabilityType,
      about: about,
      voiceIntro: voiceIntro,
      interests: interests,
      communicationPreferences: communicationPreferences,
      accessibilityNeeds: accessibilityNeeds,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      businessName: businessName,
      businessOwner: businessOwner,
      businessLocation: businessLocation,
      businessPhone: businessPhone,
      businessFacilities: businessFacilities,
    );
    await authService.updateUser(updated);
    return updated;
  }

  Future<CommunityRoom> createCommunityRoom({
    required String title,
    required String category,
    required String description,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    return communityService.createRoom(
      title: title,
      category: category,
      description: description,
      createdByUid: user.id,
    );
  }

  Future<void> joinCommunityRoom(String roomId) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    await communityService.joinRoom(roomId: roomId, uid: user.id);
  }

  Stream<List<CommunityRoom>> streamCommunityRooms() =>
      communityService.streamRooms();

  List<CommunityRoom> getRooms() => const [];

  Future<List<String>> getJoinedRoomIds() async {
    final user = authService.currentUser;
    if (user == null) return const [];
    return communityService.getJoinedRoomIds(user.id);
  }

  Future<bool> isRoomJoined(String roomId) async {
    final user = authService.currentUser;
    if (user == null) return false;
    return communityService.isMember(roomId, user.id);
  }

  Future<AccessiblePlace> addAccessiblePlace({
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    String description = '',
    double rating = 0,
    bool wheelchairAccessible = false,
    bool hasAccessibleToilet = false,
    bool hasElevator = false,
    bool hasRamp = false,
    bool hearingSupport = false,
    bool visualSupport = false,
  }) async {
    return placeService.addPlace(
      name: name,
      category: category,
      latitude: latitude,
      longitude: longitude,
      description: description,
      rating: rating < 1 ? 3 : rating,
      wheelchairAccessible: wheelchairAccessible,
      hasAccessibleToilet: hasAccessibleToilet,
      hasElevator: hasElevator,
      hasRamp: hasRamp,
      hearingSupport: hearingSupport,
      visualSupport: visualSupport,
    );
  }

  Future<AccessiblePlace> updateAccessiblePlace(AccessiblePlace place) =>
      placeService.updatePlace(place);

  Future<void> deleteAccessiblePlace(String placeId) =>
      placeService.deletePlace(placeId);

  List<AccessibilityReview> getPlaceReviews(String placeId) => const [];

  Future<List<AccessibilityReview>> fetchPlaceReviews(String placeId) =>
      placeService.getReviews(placeId);

  Future<AccessibilityReview> addPlaceReview({
    required String placeId,
    required String comment,
    required double rating,
    required AccessiblePlace placeSnapshot,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    return placeService.addReview(
      placeId: placeId,
      comment: comment,
      rating: rating,
      placeSnapshot: placeSnapshot,
      userName: user.name,
    );
  }

  Stream<List<AccessiblePlace>> streamAccessiblePlaces() =>
      placeService.streamPlaces();

  Future<List<AccessiblePlace>> getAccessiblePlaces({
    double latitude = 39.9208,
    double longitude = 32.8541,
  }) =>
      placeService.getPlaces();

  Future<VolunteerApplication?> getMyVolunteerApplication() async {
    final user = authService.currentUser;
    if (user == null) return null;
    return volunteerService.getApplicationForUser(user.id);
  }

  Future<VolunteerApplication> submitVolunteerApplication({
    required String supportArea,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    final app = await volunteerService.submitVolunteerApplication(
      userId: user.id,
      name: user.name,
      email: user.email,
      reason: supportArea,
    );
    await authService.refreshCurrentUser();
    return app;
  }

  bool get isAdmin {
    final u = authService.currentUser;
    return u?.isAdmin ?? false;
  }

  bool get isModerator {
    final u = authService.currentUser;
    return u?.isModerator ?? false;
  }

  bool get isStaff {
    final u = authService.currentUser;
    return u?.isStaff ?? false;
  }

  Future<bool> checkIsAdmin() async {
    final u = authService.currentUser;
    if (u == null) return false;
    final role = await profileService.getAuthRole(u.id);
    return AppAuthRole.isAdmin(role ?? AppAuthRole.user);
  }

  Stream<List<VolunteerApplication>> streamVolunteerApplications() =>
      volunteerService.streamApplicationsForAdmin();

  List<VolunteerApplication> getVolunteerApplications() => const [];

  Future<VolunteerApplication> approveVolunteer(
    VolunteerApplication application,
  ) async {
    final admin = authService.currentUser;
    final updated = await volunteerService.approveApplication(
      application.id,
      reviewedBy: admin?.id ?? 'admin',
    );
    
    await notificationService.sendNotification(
      userId: application.userId,
      title: 'Başvurunuz Onaylandı',
      message: 'Tebrikler! Gönüllülük başvurunuz onaylandı.',
    );
    
    await authService.refreshCurrentUser();
    return updated;
  }

  Future<void> updateEmail(String newEmail) async {
    await authService.updateEmail(newEmail);
  }

  Future<VolunteerApplication> rejectVolunteer(
    VolunteerApplication application,
  ) async {
    final admin = authService.currentUser;
    final updated = await volunteerService.rejectApplication(
      application.id,
      reviewedBy: admin?.id ?? 'admin',
    );
    await authService.refreshCurrentUser();
    return updated;
  }

  AppUser? getCurrentUser() => authService.currentUser;

  Stream<List<ChatThread>> streamChatThreads() {
    final user = authService.currentUser;
    if (user == null) return const Stream.empty();
    return chatThreadService.streamForUser(user.id);
  }

  Future<List<NotificationModel>> getNotifications() =>
      notificationService.getNotifications();

  Stream<List<NotificationModel>> streamNotifications() =>
      notificationService.streamNotifications();

  Future<List<CommunityPost>> getCommunityPosts() =>
      communityPostService.getPosts();

  Stream<List<CommunityPost>> streamCommunityPosts() =>
      communityPostService.streamPosts();

  Future<void> addCommunityPost({
    required String title,
    required String content,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    await communityPostService.addPost(
      authorId: user.id,
      authorName: user.name,
      title: title,
      body: content,
    );
  }

  Stream<List<SuccessStory>> streamSuccessStories() =>
      successStoryService.streamStories();

  Future<List<SuccessStory>> getSuccessStories() =>
      successStoryService.getStories();

  Future<void> addSuccessStory({
    required String title,
    required String content,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    await successStoryService.addStory(
      userId: user.id,
      authorName: user.name,
      title: title,
      content: content,
    );
  }

  Future<List<TrustedContact>> getTrustedContacts() async {
    final user = authService.currentUser;
    if (user == null) return const [];
    final contacts = await trustedContactService.getContacts(user.id);
    if (contacts.isNotEmpty) return contacts;
    if (!user.hasEmergencyContact) return const [];
    return [
      TrustedContact(
        id: 'profile_ec',
        userId: user.id,
        name: user.emergencyContactName,
        phoneNumber: user.emergencyContactPhone,
        relationship: 'Acil durum kişisi',
      ),
    ];
  }

  Future<TrustedContact> addTrustedContact({
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');
    final contact = await trustedContactService.addContact(
      userId: user.id,
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
    );
    await updateProfile(
      emergencyContactName: name,
      emergencyContactPhone: phoneNumber,
    );
    return contact;
  }
}
