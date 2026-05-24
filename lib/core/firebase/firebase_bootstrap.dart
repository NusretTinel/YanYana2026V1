import 'package:firebase_core/firebase_core.dart';
import 'package:yanyana_p/firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool initialized = false;

  static Future<void> ensureInitialized() async {
    if (initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    initialized = true;
  }
}
