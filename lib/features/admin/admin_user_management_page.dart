import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/admin_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/widgets/role_gate.dart';
import 'package:yanyana_p/core/widgets/role_badges.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  List<AppUser> _users = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await AdminService.instance.listUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _changeRole(AppUser user) async {
    final roles = [
      AppAuthRole.user,
      AppAuthRole.moderator,
      AppAuthRole.admin,
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Rol seçin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            for (final r in roles)
              ListTile(
                title: Text(AppAuthRole.label(r).isEmpty ? 'Kullanıcı' : AppAuthRole.label(r)),
                subtitle: Text(r),
                onTap: () => Navigator.pop(ctx, r),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == user.authRole) return;

    try {
      await AdminService.instance.updateUserAuthRole(user.id, selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol güncellendi.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: {AppAuthRole.admin},
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        appBar: AppBar(
          backgroundColor: YanYanaColors.background,
          title: const Text('Kullanıcı Yönetimi'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Tekrar dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                          'Henüz kullanıcı yok.',
                          style: TextStyle(color: YanYanaColors.textMuted),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final u = _users[i];
                            return Material(
                              color: YanYanaColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text(
                                  u.name.isEmpty ? u.email : u.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.email,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    RoleBadgesRow(user: u),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.admin_panel_settings_outlined),
                                  tooltip: 'Rol değiştir',
                                  onPressed: () => _changeRole(u),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
