import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/admin_service.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/utils/feature_dialogs.dart';
import 'package:yanyana_p/core/widgets/role_gate.dart';
import 'package:yanyana_p/features/admin/admin_sos_overview_page.dart';
import 'package:yanyana_p/features/admin/admin_user_management_page.dart';
import 'package:yanyana_p/features/admin/volunteer_admin_page.dart';
import 'package:yanyana_p/features/admin/widgets/staff_dashboard_card.dart';
import 'package:yanyana_p/features/auth/login_page.dart';
import 'package:yanyana_p/features/home/main_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  AdminStats? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final stats = await AdminService.instance.fetchStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _logout() async {
    await BackendOrchestrator.instance.authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _openMainApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: {AppAuthRole.admin},
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_loadingStats)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_stats != null)
                      _StatsStrip(stats: _stats!),
                    const SizedBox(height: 16),
                    StaffDashboardCard(
                      title: 'Gönüllü Başvuruları',
                      subtitle: 'Bekleyen başvuruları onaylayın veya reddedin',
                      icon: Icons.volunteer_activism_rounded,
                      color: YanYanaColors.secondary,
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const VolunteerAdminPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'Kullanıcı Yönetimi',
                      subtitle: 'Kullanıcıları görüntüleyin, rol atayın',
                      icon: Icons.people_alt_rounded,
                      color: YanYanaColors.primary,
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminUserManagementPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'Topluluk Moderasyonu',
                      subtitle: 'Oda ve içerik yönetimi',
                      icon: Icons.forum_outlined,
                      color: YanYanaColors.accentPurple,
                      onTap: () => showFutureFeatureDialog(
                        context,
                        title: 'Topluluk moderasyonu',
                        message:
                            'Topluluk moderasyon araçları gelecek sürümde eklenecek. Şu an yalnızca planlanmıştır.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'SOS Talepleri',
                      subtitle: 'Acil destek taleplerini görüntüleyin',
                      icon: Icons.sos_rounded,
                      color: YanYanaColors.sos,
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminSosOverviewPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaffDashboardCard(
                      title: 'Uygulama İstatistikleri',
                      subtitle: 'Kullanıcı, mekan ve başvuru sayıları',
                      icon: Icons.insights_rounded,
                      color: YanYanaColors.accentBlue,
                      onTap: _loadStats,
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadStats,
                        tooltip: 'Yenile',
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _openMainApp,
                      icon: const Icon(Icons.phone_android_rounded),
                      label: const Text('Kullanıcı Uygulamasına Dön'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _logout,
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

  Widget _buildHeader() {
    final user = AuthService.instance.currentUser;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Paneli',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Yönetici',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: YanYanaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Özet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: YanYanaColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          _statRow('Kullanıcı', stats.totalUsers),
          _statRow('Erişilebilir mekan', stats.totalPlaces),
          _statRow('SOS talebi', stats.totalSosRequests),
          _statRow('Bekleyen gönüllü başvurusu', stats.pendingVolunteerApplications),
        ],
      ),
    );
  }

  Widget _statRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: YanYanaColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
