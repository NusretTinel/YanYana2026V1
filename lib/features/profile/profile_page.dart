import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/services/profile_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/utils/feature_dialogs.dart';
import 'package:yanyana_p/core/widgets/role_badges.dart';
import 'package:yanyana_p/features/admin/admin_dashboard_page.dart';
import 'package:yanyana_p/features/admin/moderator_dashboard_page.dart';
import 'package:yanyana_p/features/home/main_page.dart';
import 'package:yanyana_p/features/home/trusted_contacts_page.dart';
import 'package:yanyana_p/shared/models/app_user.dart';
import 'package:yanyana_p/shared/models/volunteer_application.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _backend = BackendOrchestrator.instance;

  AppUser? _user;
  VolunteerApplication? _volunteerApp;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final uid = _backend.authService.currentUser?.id;
      if (uid == null) {
        setState(() {
          _user = null;
          _loading = false;
        });
        return;
      }
      final user = await ProfileService.instance.getProfile(uid) ?? _backend.currentUser;
      final volunteerApp = await _backend.getMyVolunteerApplication();
      if (!mounted) return;
      setState(() {
        _user = user;
        _volunteerApp = volunteerApp;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
        _user = _backend.currentUser;
      });
    }
  }

  void _onUserSaved(AppUser updatedUser) {
    setState(() => _user = updatedUser);
  }

  double _profileCompletion(AppUser user) {
    var filled = 0;
    const total = 7;
    if (user.name.trim().isNotEmpty) filled++;
    if (user.about.trim().isNotEmpty) filled++;
    if (user.voiceIntro.trim().isNotEmpty) filled++;
    if (user.interests.isNotEmpty) filled++;
    if (user.communicationPreferences.isNotEmpty ||
        user.communicationPreference.isNotEmpty) {
      filled++;
    }
    if (user.accessibilityNeeds.isNotEmpty) filled++;
    if (user.hasEmergencyContact) filled++;
    return filled / total;
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: YanYanaColors.sos),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _backend.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yapılamadı: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: YanYanaColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: YanYanaColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off_outlined, size: 48),
                const SizedBox(height: 12),
                Text(
                  _loadError ?? 'Oturum bulunamadı.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _load,
                  child: const Text('Yeniden dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;

    return Scaffold(
      backgroundColor: YanYanaColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: YanYanaColors.textDark,
                  ),
                ),
                if (_loadError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Bazı alanlar önbellekten yüklendi.',
                    style: TextStyle(
                      color: YanYanaColors.warning.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _ProfileHeaderCard(
                  user: user,
                  completion: _profileCompletion(user),
                  onRefresh: _load,
                ),
                const SizedBox(height: 14),

                if (user.userType == AppUserType.business) ...[
                  _BusinessInfoSection(user: user, onSaved: _onUserSaved),
                  const SizedBox(height: 14),
                  _BusinessFacilitiesSection(user: user, onSaved: _onUserSaved),
                  const SizedBox(height: 14),
                ] else ...[
                  _PersonalInfoSection(user: user, onSaved: _onUserSaved),
                  const SizedBox(height: 14),
                  if (user.userType == AppUserType.disabledUser) ...[
                    _AccessibilitySection(user: user, onSaved: _onUserSaved),
                    const SizedBox(height: 14),
                  ],
                  _EmergencyContactSection(user: user, onSaved: _onUserSaved, onManage: _load),
                  const SizedBox(height: 14),
                  _VolunteerCard(
                    user: user,
                    application: _volunteerApp,
                    onApply: () async {
                      try {
                        final app = await _backend.submitVolunteerApplication(
                          supportArea: 'Genel destek',
                        );
                        if (!mounted) return;
                        setState(() => _volunteerApp = app);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gönüllü başvurunuz alındı.'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                  ),
                ],

                if (user.isAdmin) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Yönetim',
                    icon: Icons.admin_panel_settings_outlined,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dashboard_customize_outlined),
                      title: const Text('Admin Paneli'),
                      subtitle: const Text('Gönüllü başvuruları ve kullanıcı yönetimi'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      ),
                    ),
                  ),
                ],
                if (user.isModerator && !user.isAdmin) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Moderasyon',
                    icon: Icons.shield_outlined,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.forum_outlined),
                      title: const Text('Moderatör Paneli'),
                      subtitle: const Text('Topluluk moderasyon araçları'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ModeratorDashboardPage(),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _AccountActionsCard(onLogout: _logout),
                SizedBox(height: MainPage.bottomContentPadding * 0.35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatefulWidget {
  final AppUser user;
  final double completion;
  final VoidCallback onRefresh;

  const _ProfileHeaderCard({
    required this.user,
    required this.completion,
    required this.onRefresh,
  });

  @override
  State<_ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<_ProfileHeaderCard> {

  String get _initials {
    final parts = widget.user.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.user.photoURL.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            backgroundImage:
                hasPhoto ? NetworkImage(widget.user.photoURL) : null,
            onBackgroundImageError: hasPhoto ? (_, __) {} : null,
            child: hasPhoto
                ? null
                : Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.name.isEmpty ? 'İsimsiz kullanıcı' : widget.user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          RoleBadgesRow(user: widget.user, lightOnGradient: true),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.completion.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Profil tamamlanma: ${(widget.completion * 100).round()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: YanYanaColors.border),
        boxShadow: YanYanaShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: YanYanaColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: YanYanaColors.textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  final String text;
  const _SubsectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: YanYanaColors.textDark,
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hint;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const _ProfileField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      final value = controller.text.trim();
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: YanYanaColors.surfaceSoft.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: YanYanaColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: YanYanaColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: YanYanaColors.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: YanYanaColors.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: YanYanaColors.surfaceSoft,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: YanYanaColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: YanYanaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: YanYanaColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class _PreferenceChips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool enabled;

  const _PreferenceChips({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      if (selected.isEmpty) {
        return const Text(
          'Belirtilmemiş',
          style: TextStyle(color: YanYanaColors.textMuted, fontSize: 14),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selected.map((label) => Chip(
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: YanYanaColors.primary,
            ),
          ),
          backgroundColor: YanYanaColors.primaryLight.withValues(alpha: 0.3),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )).toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final on = selected.contains(label);
        return Semantics(
          button: true,
          selected: on,
          label: label,
          child: FilterChip(
            label: Text(label),
            selected: on,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: on ? Colors.white : YanYanaColors.textDark,
            ),
            selectedColor: YanYanaColors.primary,
            backgroundColor: YanYanaColors.surfaceSoft,
            side: BorderSide(
              color: on ? YanYanaColors.primary : YanYanaColors.border,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (v) {
              final next = Set<String>.from(selected);
              if (v) {
                next.add(label);
              } else {
                next.remove(label);
              }
              onChanged(next);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _EmergencyContactPreview extends StatelessWidget {
  final String name;
  final String phone;

  const _EmergencyContactPreview({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: YanYanaColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: YanYanaColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.contact_emergency_rounded, color: YanYanaColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: YanYanaColors.textDark,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final AppUser user;
  final VolunteerApplication? application;
  final VoidCallback onApply;

  const _VolunteerCard({
    required this.user,
    required this.application,
    required this.onApply,
  });

  String _statusLabel(String status) => VolunteerStatus.label(status).isNotEmpty
      ? VolunteerStatus.label(status)
      : 'Beklemede';

  @override
  Widget build(BuildContext context) {
    final isVolunteer = user.userType == AppUserType.volunteer;

    return _SectionCard(
      title: 'Gönüllülük',
      icon: Icons.volunteer_activism_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isVolunteer)
            const Text(
              'Gönüllü hesabı olarak kayıtlısınız.',
              style: TextStyle(color: YanYanaColors.textMuted, fontSize: 14),
            )
          else if (application != null) ...[
            Text(
              'Başvuru durumu: ${_statusLabel(application!.status)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: YanYanaColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Başvurunuz inceleniyor. Sonuç bildirimlerde görünecek.',
              style: const TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 13,
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.volunteer_activism_rounded),
                label: const Text('Gönüllü olmak istiyorum'),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountActionsCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _AccountActionsCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Hesap',
      icon: Icons.settings_outlined,
      child: Semantics(
        button: true,
        label: 'Çıkış Yap',
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: YanYanaColors.sos),
            label: const Text(
              'Çıkış Yap',
              style: TextStyle(
                color: YanYanaColors.sos,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: YanYanaColors.sosLight),
              backgroundColor: YanYanaColors.sosLight.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// Section Widgets
// =======================================================================

class _PersonalInfoSection extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;

  const _PersonalInfoSection({required this.user, required this.onSaved});

  @override
  State<_PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<_PersonalInfoSection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _aboutCtrl;
  late TextEditingController _interestsCtrl;

  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initControllers();
  }

  @override
  void didUpdateWidget(_PersonalInfoSection old) {
    super.didUpdateWidget(old);
    if (!_isEditing && old.user != widget.user) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: widget.user.name);
    _aboutCtrl = TextEditingController(text: widget.user.about);
    _interestsCtrl = TextEditingController(text: widget.user.interests.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aboutCtrl.dispose();
    _interestsCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  String _preListenText = '';

  Future<void> _listenToAbout() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    }
    
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('onStatus: $val');
          if (val == 'notListening' || val == 'done') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _preListenText = _aboutCtrl.text.trim();
        });
        _speech.listen(
          onResult: (val) => setState(() {
            final newWords = val.recognizedWords.trim();
            if (_preListenText.isEmpty) {
              _aboutCtrl.text = newWords;
            } else {
              _aboutCtrl.text = '$_preListenText $newWords'.trim();
            }
          }),
          localeId: 'tr_TR',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speakAbout() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
      return;
    }
    final text = _aboutCtrl.text.trim();
    if (text.isEmpty) return;
    
    setState(() => _isPlaying = true);
    await _tts.setLanguage("tr-TR");
    await _tts.setSpeechRate(0.5);
    
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    
    await _tts.speak(text);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = await BackendOrchestrator.instance.updateProfile(
        name: _nameCtrl.text.trim(),
        about: _aboutCtrl.text.trim(),
        voiceIntro: widget.user.voiceIntro, // Mevcut değeri koru veya boş bırakabiliriz
        interests: _interestsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
      if (mounted) {
        widget.onSaved(updated);
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kişisel bilgiler güncellendi.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: YanYanaColors.sos));
      }
    }
  }

  void _cancel() {
    setState(() {
      _initControllers();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Kişisel bilgiler',
      icon: Icons.person_outline_rounded,
      trailing: _isEditing
          ? null
          : IconButton(
              icon: const Icon(Icons.edit, color: YanYanaColors.primary, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      child: Column(
        children: [
          _ProfileField(
            label: 'Ad Soyad',
            controller: _nameCtrl,
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _ProfileField(
                label: 'Hakkında',
                controller: _aboutCtrl,
                maxLines: 3,
                hint: 'Kendinizi kısaca tanıtın',
                enabled: _isEditing,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_aboutCtrl.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: YanYanaColors.sos),
                          onPressed: () => setState(() {
                            _aboutCtrl.clear();
                            _preListenText = '';
                          }),
                          tooltip: 'Metni temizle',
                        ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? YanYanaColors.sos : YanYanaColors.primary,
                        ),
                        onPressed: _listenToAbout,
                        tooltip: 'Sesle yazdır',
                      ),
                    ],
                  ),
                )
              else if (_aboutCtrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.stop_circle : Icons.play_circle,
                      color: YanYanaColors.primary,
                      size: 28,
                    ),
                    onPressed: _speakAbout,
                    tooltip: 'Sesli oku',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'İlgi alanları',
            controller: _interestsCtrl,
            hint: 'Virgülle ayırın (ör. müzik, spor)',
            enabled: _isEditing,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _cancel,
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessibilitySection extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;

  const _AccessibilitySection({required this.user, required this.onSaved});

  @override
  State<_AccessibilitySection> createState() => _AccessibilitySectionState();
}

class _AccessibilitySectionState extends State<_AccessibilitySection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late Set<String> _selectedComm;
  late Set<String> _selectedAccess;

  static const _commOptions = [
    'Yazılı iletişim',
    'Sesli iletişim',
    'Yavaş ve net iletişim',
    'Görsel destek',
  ];
  static const _accessOptions = [
    'Görme desteği',
    'İşitme desteği',
    'Hareket desteği',
    'Görünmez engel',
    'Acil destek ihtiyacı',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(_AccessibilitySection old) {
    super.didUpdateWidget(old);
    if (!_isEditing && old.user != widget.user) {
      _initData();
    }
  }

  void _initData() {
    _selectedComm = {
      if (widget.user.communicationPreferences.isEmpty && widget.user.communicationPreference.isNotEmpty)
        widget.user.communicationPreference
      else
        ...widget.user.communicationPreferences
    };
    _selectedAccess = {...widget.user.accessibilityNeeds};
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = await BackendOrchestrator.instance.updateProfile(
        communicationPreferences: _selectedComm.toList(),
        accessibilityNeeds: _selectedAccess.toList(),
      );
      if (mounted) {
        widget.onSaved(updated);
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erişilebilirlik güncellendi.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: YanYanaColors.sos));
      }
    }
  }

  void _cancel() {
    setState(() {
      _initData();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Erişilebilirlik tercihleri',
      icon: Icons.accessibility_new_rounded,
      trailing: _isEditing
          ? null
          : IconButton(
              icon: const Icon(Icons.edit, color: YanYanaColors.primary, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SubsectionLabel('İletişim tercihleri'),
          const SizedBox(height: 8),
          _PreferenceChips(
            options: _commOptions,
            selected: _selectedComm,
            enabled: _isEditing,
            onChanged: (next) => setState(() {
              _selectedComm
                ..clear()
                ..addAll(next);
            }),
          ),
          const SizedBox(height: 16),
          const _SubsectionLabel('Erişilebilirlik ihtiyaçları'),
          const SizedBox(height: 8),
          _PreferenceChips(
            options: _accessOptions,
            selected: _selectedAccess,
            enabled: _isEditing,
            onChanged: (next) => setState(() {
              _selectedAccess
                ..clear()
                ..addAll(next);
            }),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _cancel,
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyContactSection extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;
  final VoidCallback onManage;

  const _EmergencyContactSection({required this.user, required this.onSaved, required this.onManage});

  @override
  State<_EmergencyContactSection> createState() => _EmergencyContactSectionState();
}

class _EmergencyContactSectionState extends State<_EmergencyContactSection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _emergencyNameCtrl;
  late TextEditingController _emergencyPhoneCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(_EmergencyContactSection old) {
    super.didUpdateWidget(old);
    if (!_isEditing && old.user != widget.user) {
      _initControllers();
    }
  }

  void _initControllers() {
    _emergencyNameCtrl = TextEditingController(text: widget.user.emergencyContactName);
    _emergencyPhoneCtrl = TextEditingController(text: widget.user.emergencyContactPhone);
  }

  @override
  void dispose() {
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = await BackendOrchestrator.instance.updateProfile(
        emergencyContactName: _emergencyNameCtrl.text.trim(),
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim(),
      );
      if (mounted) {
        widget.onSaved(updated);
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Acil durum kişisi güncellendi.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: YanYanaColors.sos));
      }
    }
  }

  void _cancel() {
    setState(() {
      _initControllers();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Acil durum kişisi',
      icon: Icons.emergency_rounded,
      trailing: _isEditing
          ? null
          : IconButton(
              icon: const Icon(Icons.edit, color: YanYanaColors.primary, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOS ve güvenli arama bu bilgiyi kullanır.',
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (!widget.user.hasEmergencyContact &&
              !_isEditing &&
              widget.user.emergencyContactName.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Henüz acil durum kişisi eklenmedi.',
                style: TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          _ProfileField(
            label: 'Acil kişi adı',
            controller: _emergencyNameCtrl,
            hint: 'Örn. Ayşe Yılmaz',
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'Acil kişi telefon',
            controller: _emergencyPhoneCtrl,
            keyboardType: TextInputType.phone,
            hint: '05xx xxx xx xx',
            enabled: _isEditing,
          ),
          const SizedBox(height: 8),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _cancel,
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BusinessInfoSection extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;

  const _BusinessInfoSection({required this.user, required this.onSaved});

  @override
  State<_BusinessInfoSection> createState() => _BusinessInfoSectionState();
}

class _BusinessInfoSectionState extends State<_BusinessInfoSection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _ownerCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(_BusinessInfoSection old) {
    super.didUpdateWidget(old);
    if (!_isEditing && old.user != widget.user) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: widget.user.businessName);
    _ownerCtrl = TextEditingController(text: widget.user.businessOwner);
    _locationCtrl = TextEditingController(text: widget.user.businessLocation);
    _phoneCtrl = TextEditingController(text: widget.user.businessPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = await BackendOrchestrator.instance.updateProfile(
        businessName: _nameCtrl.text.trim(),
        businessOwner: _ownerCtrl.text.trim(),
        businessLocation: _locationCtrl.text.trim(),
        businessPhone: _phoneCtrl.text.trim(),
      );
      if (mounted) {
        widget.onSaved(updated);
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İşletme bilgileri güncellendi.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: YanYanaColors.sos));
      }
    }
  }

  void _cancel() {
    setState(() {
      _initControllers();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'İşletme Bilgileri',
      icon: Icons.storefront_rounded,
      trailing: _isEditing
          ? null
          : IconButton(
              icon: const Icon(Icons.edit, color: YanYanaColors.primary, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      child: Column(
        children: [
          _ProfileField(
            label: 'İşletme Adı',
            controller: _nameCtrl,
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'İşletme Sahibi',
            controller: _ownerCtrl,
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'Açık Adres / Konum',
            controller: _locationCtrl,
            maxLines: 3,
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'İşletme İletişim Numarası',
            controller: _phoneCtrl,
            enabled: _isEditing,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _cancel,
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BusinessFacilitiesSection extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;

  const _BusinessFacilitiesSection({required this.user, required this.onSaved});

  @override
  State<_BusinessFacilitiesSection> createState() => _BusinessFacilitiesSectionState();
}

class _BusinessFacilitiesSectionState extends State<_BusinessFacilitiesSection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late Set<String> _selectedFacilities;

  static const _facilityOptions = [
    'Tekerlekli Sandalye Rampası',
    'Asansör',
    'Engelli Tuvaleti',
    'Braille Menü / Yönlendirme',
    'İşaret Dili Bilen Personel',
    'Geniş Kapı/Geçiş',
    'Sessiz Alan',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(_BusinessFacilitiesSection old) {
    super.didUpdateWidget(old);
    if (!_isEditing && old.user != widget.user) {
      _initData();
    }
  }

  void _initData() {
    _selectedFacilities = {...widget.user.businessFacilities};
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = await BackendOrchestrator.instance.updateProfile(
        businessFacilities: _selectedFacilities.toList(),
      );
      if (mounted) {
        widget.onSaved(updated);
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erişilebilirlik imkanları güncellendi.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: YanYanaColors.sos));
      }
    }
  }

  void _cancel() {
    setState(() {
      _initData();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Sunduğunuz Erişilebilirlik İmkanları',
      icon: Icons.accessible_forward_rounded,
      trailing: _isEditing
          ? null
          : IconButton(
              icon: const Icon(Icons.edit, color: YanYanaColors.primary, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İşletmenizin sahip olduğu imkanları seçin. Bu bilgiler haritada engelli bireyler için görünürlüğünüzü artırır.',
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          _PreferenceChips(
            options: _facilityOptions,
            selected: _selectedFacilities,
            enabled: _isEditing,
            onChanged: (next) => setState(() {
              _selectedFacilities
                ..clear()
                ..addAll(next);
            }),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : _cancel,
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
