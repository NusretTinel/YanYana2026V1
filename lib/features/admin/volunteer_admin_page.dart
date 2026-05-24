import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/widgets/role_gate.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/volunteer_application.dart';

class VolunteerAdminPage extends StatefulWidget {
  const VolunteerAdminPage({super.key});

  @override
  State<VolunteerAdminPage> createState() => _VolunteerAdminPageState();
}

class _VolunteerAdminPageState extends State<VolunteerAdminPage> {
  final _orchestrator = BackendOrchestrator.instance;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final _areas = const [
    'Ulaşım Desteği',
    'Okuma Desteği',
    'Sosyal Destek',
    'Acil Destek',
    'Mentorluk',
  ];

  String _selectedArea = 'Ulaşım Desteği';
  List<VolunteerApplication> _applications = const [];
  StreamSubscription<List<VolunteerApplication>>? _appsSub;

  @override
  void initState() {
    super.initState();
    _appsSub = _orchestrator.streamVolunteerApplications().listen((apps) {
      if (!mounted) return;
      setState(() => _applications = apps);
    });
  }

  @override
  void dispose() {
    _appsSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _approve(VolunteerApplication app) async {
    final updated = await _orchestrator.approveVolunteer(app);
    if (!mounted) return;
    setState(() {
      _applications = _applications
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
    });
  }

  Future<void> _reject(VolunteerApplication app) async {
    final updated = await _orchestrator.rejectVolunteer(app);
    if (!mounted) return;
    setState(() {
      _applications = _applications
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: {AppAuthRole.admin},
      child: Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.background,
        elevation: 0,
        title: const Text(
          'Gönüllü Başvuru ve Yönetim',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: YanYanaColors.sosLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.sosLight),
                ),
                child: const Text(
                  'E-Devlet doğrulaması bu prototipte simüle edilmiştir. Gerçek entegrasyon future work kapsamındadır.',
                  style: TextStyle(
                    color: YanYanaColors.textDark,
                    fontSize: 12.8,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Gönüllü Başvurusu',
                icon: Icons.volunteer_activism_rounded,
                color: YanYanaColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: _inputDeco(
                        label: 'Ad Soyad',
                        hint: 'Örn: Zeynep Kaya',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDeco(
                        label: 'E-posta',
                        hint: 'ornek@mail.com',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Destek Alanı',
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _areas.map((a) {
                        final selected = a == _selectedArea;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedArea = a),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? YanYanaColors.primary
                                  : YanYanaColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? YanYanaColors.primary
                                    : YanYanaColors.border,
                              ),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : YanYanaColors.textMuted,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDeco(
                        label: 'Not (opsiyonel)',
                        hint: 'Kısa açıklama ekleyin',
                        icon: Icons.notes_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: 'Başvuru Gönder',
                        icon: Icons.send_rounded,
                        gradient: supportGradient,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gönüllü başvurusu prototip olarak alındı.'),
                            ),
                          );
                          _nameCtrl.clear();
                          _emailCtrl.clear();
                          _noteCtrl.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Admin Onay (Mock)',
                icon: Icons.admin_panel_settings_rounded,
                color: YanYanaColors.primary,
                child: Column(
                  children: _applications.map((a) => _buildApplicationCard(a)).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildApplicationCard(VolunteerApplication app) {
    final statusColor = app.status == 'approved'
        ? YanYanaColors.success
        : app.status == 'rejected'
            ? YanYanaColors.sos
            : YanYanaColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: YanYanaColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: YanYanaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: YanYanaColors.primaryLight,
                child: Text(
                  app.name.isEmpty ? '?' : app.name[0],
                  style: const TextStyle(
                    color: YanYanaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.email,
                      style: const TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withValues(alpha: 0.18)),
                ),
                child: Text(
                  app.status,
                  style: const TextStyle(
                    color: YanYanaColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Alan: ${app.supportArea}',
            style: const TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 12.8,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: app.status == 'pending' ? () => _approve(app) : null,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Onayla',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: YanYanaColors.success,
                    side: BorderSide(color: YanYanaColors.success.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: app.status == 'pending' ? () => _reject(app) : null,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text(
                    'Reddet',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: YanYanaColors.sos,
                    side: BorderSide(color: YanYanaColors.sos.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: YanYanaColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  static InputDecoration _inputDeco({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: YanYanaColors.primary, size: 21),
      filled: true,
      fillColor: YanYanaColors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.primary, width: 1.6),
      ),
    );
  }
}

