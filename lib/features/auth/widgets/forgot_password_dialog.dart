import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/utils/app_utils.dart';

/// Shows password reset dialog. Returns `true` if email was sent successfully.
Future<bool?> showForgotPasswordDialog({
  required BuildContext context,
  String initialEmail = '',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await BackendOrchestrator.instance.authService.sendPasswordResetEmail(
        _emailCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      final msg = e is AuthException
          ? e.message
          : 'Şifre sıfırlama e-postası gönderilemedi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: YanYanaColors.sos,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Şifremi Unuttum',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kayıtlı e-posta adresinize şifre sıfırlama bağlantısı göndereceğiz.',
              style: TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !_sending,
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@mail.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: YanYanaColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'E-posta boş bırakılamaz';
                }
                if (!AppUtils.isValidEmail(v)) {
                  return 'Geçerli bir e-posta adresi girin';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          style: FilledButton.styleFrom(
            backgroundColor: YanYanaColors.primary,
          ),
          child: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Bağlantı Gönder'),
        ),
      ],
    );
  }
}
