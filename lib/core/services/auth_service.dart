import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/services/profile_service.dart';
import 'package:yanyana_p/core/services/volunteer_service.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Register intent from UI (not auth role).
class RegisterIntent {
  RegisterIntent._();

  static const disabledUser = 'disabled_user';
  static const volunteerApply = 'volunteer_apply';
  static const regularUser = 'regular_user';
  static const business = 'business';
}

/// Client-side Firebase Authentication wrapper (no custom backend).
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '618318744581-b9vnagcrp37ahpdgqc7r0o5nrjm5g3fm.apps.googleusercontent.com',
  );

  AppUser? _appUser;

  AppUser? get currentUser => _appUser;
  bool get isSignedIn => _auth.currentUser != null;
  User? get firebaseUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> refreshCurrentUser() async {
    final fb = _auth.currentUser;
    if (fb == null) {
      _appUser = null;
      return;
    }
    _appUser = await ProfileService.instance.getProfile(fb.uid);
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final trimmedEmail = _normalizeEmail(email);
    if (trimmedEmail.isEmpty) {
      throw AuthException('E-posta adresi boş bırakılamaz.');
    }
    if (password.isEmpty) {
      throw AuthException('Şifre boş bırakılamaz.');
    }
    if (password.length < 8) {
      throw AuthException('Şifre en az 8 karakter olmalıdır.');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      
      // Senkronizasyon: Auth e-postası ile DB e-postasını eşitle
      final uid = cred.user!.uid;
      final authEmail = cred.user!.email;
      if (authEmail != null) {
        await ProfileService.instance.updateEmail(uid, authEmail);
      }
      
      _appUser = await ProfileService.instance.getProfile(uid);
      _appUser ??= await ProfileService.instance.ensureUserDocument(cred.user!);
      return _appUser!;
    } catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<AppUser> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    String registerIntent, {
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
  }) async {
    final name = fullName.trim();
    if (name.isEmpty) throw AuthException('Ad soyad boş bırakılamaz.');
    final trimmedEmail = _normalizeEmail(email);
    if (trimmedEmail.isEmpty) {
      throw AuthException('E-posta adresi boş bırakılamaz.');
    }
    if (password.isEmpty) {
      throw AuthException('Şifre boş bırakılamaz.');
    }
    if (password.length < 8) {
      throw AuthException('Şifre en az 8 karakter olmalıdır.');
    }

    final userType = _userTypeFromIntent(registerIntent);
    final volunteerStatus = registerIntent == RegisterIntent.volunteerApply
        ? VolunteerStatus.pending
        : VolunteerStatus.none;

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final uid = cred.user!.uid;
      await ProfileService.instance.createUserDocument(
        uid: uid,
        email: trimmedEmail,
        name: name,
        userType: userType,
        provider: 'email',
        volunteerStatus: volunteerStatus,
        businessName: businessName,
        businessOwner: businessOwner,
        businessLocation: businessLocation,
        businessPhone: businessPhone,
      );

      if (registerIntent == RegisterIntent.volunteerApply) {
        await VolunteerService.instance.submitVolunteerApplication(
          userId: uid,
          name: name,
          email: trimmedEmail,
          reason: 'Kayıt sırasında gönüllü başvurusu',
        );
      }

      _appUser = await ProfileService.instance.getProfile(uid);
      return _appUser!;
    } catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = _normalizeEmail(email);
    if (trimmedEmail.isEmpty) {
      throw AuthException('E-posta adresi boş bırakılamaz.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
    } catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<AppUser> signInWithGoogle({
    String registerIntent = RegisterIntent.regularUser,
  }) async {
    try {
      final UserCredential cred;
      if (kIsWeb) {
        cred = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException('Google girişi iptal edildi.');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }
      final fbUser = cred.user!;
      final isNew = cred.additionalUserInfo?.isNewUser ?? false;

      if (isNew) {
        final userType = _userTypeFromIntent(registerIntent);
        final volunteerStatus = registerIntent == RegisterIntent.volunteerApply
            ? VolunteerStatus.pending
            : VolunteerStatus.none;
        await ProfileService.instance.createUserDocumentIfNeeded(
          firebaseUser: fbUser,
          userType: userType,
          volunteerStatus: volunteerStatus,
          provider: 'google',
        );
        if (registerIntent == RegisterIntent.volunteerApply) {
          await VolunteerService.instance.submitVolunteerApplication(
            userId: fbUser.uid,
            name: fbUser.displayName ?? 'Kullanıcı',
            email: fbUser.email ?? '',
            reason: 'Google kayıt — gönüllü başvurusu',
          );
        }
      } else {
        await ProfileService.instance.createUserDocumentIfNeeded(
          firebaseUser: fbUser,
          provider: 'google',
        );
      }

      _appUser = await ProfileService.instance.getProfile(fbUser.uid);
      _appUser ??= await ProfileService.instance.ensureUserDocument(
          fbUser,
          provider: 'google',
        );
      return _appUser!;
    } catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> updateUser(AppUser user) async {
    await ProfileService.instance.updateProfile(
      uid: user.id,
      name: user.name,
      disabilityType: user.disabilityType,
      about: user.about,
      voiceIntro: user.voiceIntro,
      interests: user.interests,
      accessibilityNeeds: user.accessibilityNeeds,
      communicationPreferences: user.communicationPreferences,
      emergencyContactName: user.emergencyContactName,
      emergencyContactPhone: user.emergencyContactPhone,
    );
    if (_auth.currentUser?.uid == user.id) {
      _appUser = await ProfileService.instance.getProfile(user.id);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Oturum açılmamış.');
    final trimmed = _normalizeEmail(newEmail);
    if (trimmed.isEmpty) throw AuthException('E-posta boş olamaz.');

    try {
      await user.verifyBeforeUpdateEmail(trimmed);
      
      // Not: Firestore'u burada anında GÜNCELLEMİYORUZ. 
      // Çünkü kullanıcı e-postasına gidip onaylamazsa, Auth ile Firestore uyuşmazlığı çıkar.
      // Kullanıcı onayladıktan sonraki bir sonraki girişinde zaten token'dan yeni mail alınır.
    } catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
    _appUser = null;
  }

  static String _userTypeFromIntent(String intent) {
    switch (intent) {
      case RegisterIntent.disabledUser:
        return AppUserType.disabledUser;
      case RegisterIntent.business:
        return AppUserType.business;
      case RegisterIntent.volunteerApply:
        return AppUserType.regularUser;
      case RegisterIntent.regularUser:
        return AppUserType.regularUser;
      default:
        return AppUserType.regularUser;
    }
  }
}
