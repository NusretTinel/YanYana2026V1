import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase Auth errors to Turkish user-facing messages.
String firebaseAuthErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 8 karakter kullanın.';
      case 'operation-not-allowed':
        return 'E-posta/şifre girişi Firebase Console\'da etkin değil.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok veya Firebase\'e ulaşılamıyor.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen bir süre sonra tekrar deneyin.';
      case 'missing-email':
        return 'E-posta adresi girin.';
      case 'invalid-action-code':
      case 'expired-action-code':
        return 'Şifre sıfırlama bağlantısı geçersiz veya süresi dolmuş.';
      default:
        return error.message ?? 'Kimlik doğrulama hatası: ${error.code}';
    }
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Firestore izni reddedildi. Güvenlik kurallarını kontrol edin.';
    }
    if (error.code == 'unavailable') {
      return 'Firestore şu an kullanılamıyor. İnternet bağlantınızı kontrol edin.';
    }
    return error.message ?? 'Firebase hatası: ${error.code}';
  }
  return error.toString();
}
