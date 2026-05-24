import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/profile_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/utils/app_utils.dart';

/// E-posta alanı — Firestore `users` koleksiyonundan öneri (en az 2 harf).
class RegisteredEmailField extends StatefulWidget {
  const RegisteredEmailField({
    super.key,
    required this.controller,
    this.validator,
    this.label = 'E-posta',
    this.hint = 'ornek@mail.com',
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final String hint;

  @override
  State<RegisteredEmailField> createState() => _RegisteredEmailFieldState();
}

class _RegisteredEmailFieldState extends State<RegisteredEmailField> {
  final _focusNode = FocusNode();
  Timer? _debounce;
  Timer? _hideSuggestionsTimer;
  List<String> _suggestions = const [];
  bool _searching = false;
  bool _pickingSuggestion = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideSuggestionsTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _hideSuggestionsTimer?.cancel();
      return;
    }
    if (_pickingSuggestion) return;

    // Blur clears the list after tap handlers run (onTap loses race otherwise).
    _hideSuggestionsTimer?.cancel();
    _hideSuggestionsTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted || _focusNode.hasFocus || _pickingSuggestion) return;
      setState(() => _suggestions = const []);
    });
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    _debounce?.cancel();
    if (text.trim().length < 2) {
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _fetch(text));
  }

  Future<void> _fetch(String text) async {
    setState(() => _searching = true);
    try {
      final emails =
          await ProfileService.instance.searchRegisteredEmails(text);
      if (!mounted) return;
      final current = widget.controller.text.trim().toLowerCase();
      setState(() {
        _suggestions = emails
            .where((e) => e.toLowerCase() != current)
            .toList();
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
    }
  }

  void _pick(String email) {
    _pickingSuggestion = true;
    _hideSuggestionsTimer?.cancel();

    widget.controller.value = TextEditingValue(
      text: email,
      selection: TextSelection.collapsed(offset: email.length),
    );

    setState(() => _suggestions = const []);

    _focusNode.requestFocus();

    Future.microtask(() {
      _pickingSuggestion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions =
        _focusNode.hasFocus && (_suggestions.isNotEmpty || _searching);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          validator: widget.validator ??
              (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'E-posta boş bırakılamaz';
                }
                if (!AppUtils.isValidEmail(v)) {
                  return 'Geçerli bir e-posta adresi girin';
                }
                return null;
              },
          style: const TextStyle(
            color: YanYanaColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: YanYanaColors.primary,
              size: 21,
            ),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: YanYanaColors.surface,
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
              borderSide: const BorderSide(
                color: YanYanaColors.primary,
                width: 1.8,
              ),
            ),
          ),
        ),
        if (showSuggestions) ...[
          const SizedBox(height: 6),
          Material(
            elevation: 6,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            color: YanYanaColors.surface,
            clipBehavior: Clip.antiAlias,
            child: _searching && _suggestions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'Kayıtlı e-postalar aranıyor…',
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final email = _suggestions[i];
                      return _SuggestionTile(
                        email: email,
                        onSelect: () => _pick(email),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

/// Selects on pointer down so blur does not remove the tile before onTap.
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.email,
    required this.onSelect,
  });

  final String email;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onSelect(),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: YanYanaColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: YanYanaColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
