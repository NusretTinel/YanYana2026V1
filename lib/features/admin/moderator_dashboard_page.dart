import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/utils/feature_dialogs.dart';
import 'package:yanyana_p/core/widgets/role_gate.dart';
import 'package:yanyana_p/features/admin/widgets/staff_dashboard_card.dart';
import 'package:yanyana_p/features/auth/login_page.dart';
import 'package:yanyana_p/features/community/community_page.dart';
import 'package:yanyana_p/features/home/main_page.dart';

class ModeratorDashboardPage extends StatelessWidget {
  const ModeratorDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await BackendOrchestrator.instance.authService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _openMainApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return RoleGate(
      allowedRoles: {AppAuthRole.moderator, AppAuthRole.admin},
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: supportGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: YanYanaShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Moderatör Paneli',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'Moderatör',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    StaffDashboardCard(
                      title: 'Topluluk Odaları',
                      subtitle: 'Odaları görüntüleyin',
                      icon: Icons.groups_rounded,
                      color: YanYanaColors.primary,
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const CommunityPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'Bildirilen İçerik',
                      subtitle: 'Şikayet edilen gönderiler',
                      icon: Icons.flag_outlined,
                      color: YanYanaColors.warning,
                      onTap: () => showFutureFeatureDialog(
                        context,
                        title: 'Bildirilen içerik',
                        message:
                            'İçerik şikayetleri ve moderasyon kuyruğu gelecek sürümde eklenecek.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'Mekan Yorumları',
                      subtitle: 'Erişilebilirlik değerlendirmeleri',
                      icon: Icons.rate_review_outlined,
                      color: YanYanaColors.accentPurple,
                      onTap: () => showFutureFeatureDialog(
                        context,
                        title: 'Yorum moderasyonu',
                        message:
                            'Mekan yorum moderasyonu gelecek sürümde eklenecek. Şu an yalnızca planlanmıştır.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => _openMainApp(context),
                      icon: const Icon(Icons.phone_android_rounded),
                      label: const Text('Kullanıcı Uygulamasına Dön'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _logout(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: YanYanaColors.sos,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Çıkış Yap'),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
