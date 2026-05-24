import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/features/home/main_page.dart';

/// Blocks UI when the signed-in user lacks the required authorization role.
class RoleGate extends StatelessWidget {
  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.deniedMessage = 'Bu sayfaya erişim yetkiniz yok.',
    this.redirectToMain = true,
  });

  final Set<String> allowedRoles;
  final Widget child;
  final String deniedMessage;
  final bool redirectToMain;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final role = AppAuthRole.normalize(user?.authRole);
    if (user != null && allowedRoles.contains(role)) {
      return child;
    }

    if (redirectToMain) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainPage()),
          (_) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deniedMessage)),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Erişim')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            deniedMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
