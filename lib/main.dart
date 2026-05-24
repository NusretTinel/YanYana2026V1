import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/services/profile_service.dart';
import 'package:yanyana_p/features/admin/admin_dashboard_page.dart';
import 'package:yanyana_p/features/admin/moderator_dashboard_page.dart';
import 'package:yanyana_p/features/auth/login_page.dart';
import 'package:yanyana_p/features/home/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YanYanaApp());
}

class YanYanaApp extends StatelessWidget {
  const YanYanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YanYana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<void> _initFuture;
  bool _initFailed = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await BackendOrchestrator.initialize();
    } catch (e) {
      _initFailed = true;
      _initError = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, initSnap) {
        if (initSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_initFailed) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase başlatılamadı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _initError ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Proje kökünde şunu çalıştırın:\nflutterfire configure',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return StreamBuilder<User?>(
          stream: AuthService.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting &&
                !authSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final fbUser = authSnap.data;
            if (fbUser == null) {
              return const LoginPage();
            }
            return _SignedInShell(key: ValueKey(fbUser.uid));
          },
        );
      },
    );
  }
}

/// Loads Firestore profile and routes by authorization role.
class _SignedInShell extends StatefulWidget {
  const _SignedInShell({super.key});

  @override
  State<_SignedInShell> createState() => _SignedInShellState();
}

class _SignedInShellState extends State<_SignedInShell> {
  late Future<void> _profileFuture;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final fb = AuthService.instance.firebaseUser;
      if (fb == null) return;

      var profile = await ProfileService.instance.getProfile(fb.uid);
      if (profile == null) {
        final provider =
            fb.providerData.isNotEmpty ? fb.providerData.first.providerId : 'email';
        await ProfileService.instance.ensureUserDocument(fb, provider: provider);
      }
      await AuthService.instance.refreshCurrentUser();
    } catch (_) {
      _loadError =
          'Profil bilgileri yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }
  }

  Widget _homeForRole() {
    final user = AuthService.instance.currentUser;
    if (user == null) return const LoginPage();
    if (user.isAdmin) return const AdminDashboardPage();
    if (user.isModerator) return const ModeratorDashboardPage();
    return const MainPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_loadError != null) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loadError = null;
                          _profileFuture = _loadProfile();
                        });
                      },
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (AuthService.instance.currentUser == null) {
          return const LoginPage();
        }
        return _homeForRole();
      },
    );
  }
}
