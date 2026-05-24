import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/auth/widgets/forgot_password_dialog.dart';
import 'package:yanyana_p/features/auth/widgets/registered_email_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _buildHeader(),
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LoginForm(tabController: _tabController),
                  _RegisterForm(tabController: _tabController),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.diversity_1_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'YanYana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Erişilebilir destek ve topluluk platformu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        height: 54,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: YanYanaColors.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: YanYanaColors.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: supportGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: YanYanaShadows.soft,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: YanYanaColors.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Giriş Yap'),
            Tab(text: 'Kayıt Ol'),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        'Gizlilik Politikası · Kullanım Koşulları',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: YanYanaColors.textMuted.withValues(alpha: 0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final TabController tabController;

  const _LoginForm({required this.tabController});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? YanYanaColors.sos : YanYanaColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await BackendOrchestrator.instance.authService.signInWithGoogle();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e is AuthException
          ? e.message
          : 'Google ile giriş yapılamadı.';
      _showMessage(msg, error: true);
    }
  }

  Future<void> _openForgotPassword() async {
    final sent = await showForgotPasswordDialog(
      context: context,
      initialEmail: _emailCtrl.text.trim(),
    );
    if (sent == true && mounted) {
      _showMessage(
        'Şifre sıfırlama bağlantısı e-postanıza gönderildi. Gelen kutunuzu ve spam klasörünü kontrol edin.',
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await BackendOrchestrator.instance.authService.signInWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e is AuthException
          ? e.message
          : 'Giriş yapılamadı. Lütfen tekrar deneyin.';
      _showMessage(msg, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegisteredEmailField(controller: _emailCtrl),
            const SizedBox(height: 16),
            YanYanaTextField(
              controller: _passCtrl,
              label: 'Şifre',
              hint: 'Şifrenizi girin',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: YanYanaColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Şifre boş bırakılamaz';
                }
                if (v.length < 8) {
                  return 'Şifre en az 8 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _openForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: YanYanaColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Şifremi Unuttum',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Giriş Yap',
              child: GradientButton(
                label: 'Giriş Yap',
                icon: Icons.arrow_forward_rounded,
                isLoading: _loading,
                onPressed: _login,
              ),
            ),
            const SizedBox(height: 14),
            Semantics(
              button: true,
              label: 'Google ile devam et',
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.login_rounded, size: 22),
                label: const Text(
                  'Google ile devam et',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hesabın yok mu? ',
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.tabController.animateTo(1),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: YanYanaColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final TabController tabController;

  const _RegisterForm({required this.tabController});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  final _businessOwnerCtrl = TextEditingController();
  final _businessLocationCtrl = TextEditingController();
  final _businessPhoneCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  String _registerIntent = RegisterIntent.regularUser;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _businessOwnerCtrl.dispose();
    _businessLocationCtrl.dispose();
    _businessPhoneCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? YanYanaColors.sos : YanYanaColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await BackendOrchestrator.instance.authService.signInWithGoogle(
        registerIntent: _registerIntent,
      );
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e is AuthException
          ? e.message
          : 'Google ile kayıt yapılamadı.';
      _showMessage(msg, error: true);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await BackendOrchestrator.instance.authService.registerWithEmailAndPassword(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _registerIntent,
        businessName: _registerIntent == RegisterIntent.business ? _nameCtrl.text.trim() : null,
        businessOwner: _registerIntent == RegisterIntent.business ? _businessOwnerCtrl.text.trim() : null,
        businessLocation: _registerIntent == RegisterIntent.business ? _businessLocationCtrl.text.trim() : null,
        businessPhone: _registerIntent == RegisterIntent.business ? _businessPhoneCtrl.text.trim() : null,
      );
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e is AuthException
          ? e.message
          : 'Kayıt tamamlanamadı. Lütfen tekrar deneyin.';
      _showMessage(msg, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hesap türü',
              style: TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _RoleChip(
              label: AppUserType.label(AppUserType.disabledUser),
              icon: Icons.accessibility_new_rounded,
              selected: _registerIntent == RegisterIntent.disabledUser,
              color: YanYanaColors.primary,
              onTap: () => setState(
                () => _registerIntent = RegisterIntent.disabledUser,
              ),
            ),
            const SizedBox(height: 8),
            _RoleChip(
              label: 'Engelli Dostu İşletmeyim',
              icon: Icons.storefront_rounded,
              selected: _registerIntent == RegisterIntent.business,
              color: YanYanaColors.sos,
              onTap: () => setState(
                () => _registerIntent = RegisterIntent.business,
              ),
            ),
            const SizedBox(height: 8),
            _RoleChip(
              label: 'Gönüllü olmak istiyorum',
              icon: Icons.volunteer_activism_rounded,
              selected: _registerIntent == RegisterIntent.volunteerApply,
              color: YanYanaColors.secondary,
              onTap: () => setState(
                () => _registerIntent = RegisterIntent.volunteerApply,
              ),
            ),
            const SizedBox(height: 8),
            _RoleChip(
              label: AppUserType.label(AppUserType.regularUser),
              icon: Icons.person_outline_rounded,
              selected: _registerIntent == RegisterIntent.regularUser,
              color: YanYanaColors.accentPurple,
              onTap: () => setState(
                () => _registerIntent = RegisterIntent.regularUser,
              ),
            ),
            const SizedBox(height: 16),
            YanYanaTextField(
              controller: _nameCtrl,
              label: _registerIntent == RegisterIntent.business ? 'İşletme Adı' : 'Ad Soyad',
              hint: _registerIntent == RegisterIntent.business ? 'İşletmenizin adını girin' : 'Adınızı girin',
              icon: _registerIntent == RegisterIntent.business ? Icons.storefront_rounded : Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return _registerIntent == RegisterIntent.business ? 'İşletme adı boş bırakılamaz' : 'Ad soyad boş bırakılamaz';
                }
                return null;
              },
            ),
            if (_registerIntent == RegisterIntent.business) ...[
              const SizedBox(height: 12),
              YanYanaTextField(
                controller: _businessOwnerCtrl,
                label: 'İşletme Sahibinin Adı Soyadı',
                hint: 'İşletme sahibinin adını girin',
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'İşletme sahibi boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              YanYanaTextField(
                controller: _businessLocationCtrl,
                label: 'İşletme Açık Adresi',
                hint: 'Adresinizi girin',
                icon: Icons.location_on_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Adres boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              YanYanaTextField(
                controller: _businessPhoneCtrl,
                label: 'İşletme İletişim Numarası',
                hint: 'Telefon numaranızı girin',
                icon: Icons.phone_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'İletişim numarası boş bırakılamaz';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            RegisteredEmailField(controller: _emailCtrl),
            const SizedBox(height: 12),
            YanYanaTextField(
              controller: _passCtrl,
              label: 'Şifre',
              hint: 'En az 8 karakter',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePass,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: YanYanaColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePass = !_obscurePass);
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Şifre boş bırakılamaz';
                }
                if (v.length < 8) {
                  return 'Şifre en az 8 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            YanYanaTextField(
              controller: _confirmCtrl,
              label: 'Şifre Tekrar',
              hint: 'Şifrenizi tekrar girin',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: YanYanaColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Şifre tekrar boş bırakılamaz';
                }
                if (v != _passCtrl.text) {
                  return 'Şifreler eşleşmiyor';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            Semantics(
              button: true,
              label: 'Kayıt Ol',
              child: GradientButton(
                label: 'Kayıt Ol',
                icon: Icons.person_add_alt_1_rounded,
                isLoading: _loading,
                onPressed: _register,
                gradient: supportGradient,
              ),
            ),
            const SizedBox(height: 14),
            Semantics(
              button: true,
              label: 'Google ile devam et',
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.login_rounded, size: 22),
                label: const Text(
                  'Google ile devam et',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Zaten hesabın var mı? ',
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.tabController.animateTo(0),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: YanYanaColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : YanYanaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : YanYanaColors.border,
          ),
          boxShadow: selected ? YanYanaShadows.soft : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : YanYanaColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : YanYanaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
