import 'package:flutter/material.dart';

class YanYanaColors {
  // Brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFE0E7FF);

  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color secondaryLight = Color(0xFFCCFBF1);

  static const Color accentPink = Color(0xFFF472B6);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentYellow = Color(0xFFFBBF24);

  // Semantic colors
  static const Color sos = Color(0xFFEF4444);
  static const Color sosLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  // Background and surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1F5F9);

  // Text
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color white = Colors.white;
}

const LinearGradient primaryGradient = LinearGradient(
  colors: [
    YanYanaColors.primary,
    YanYanaColors.accentPurple,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient supportGradient = LinearGradient(
  colors: [
    YanYanaColors.secondary,
    YanYanaColors.accentBlue,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient calmGradient = LinearGradient(
  colors: [
    Color(0xFFE0F2FE),
    Color(0xFFEDE9FE),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient sosGradient = LinearGradient(
  colors: [
    YanYanaColors.sos,
    Color(0xFFFB7185),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class YanYanaShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF475569).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> nav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, -8),
    ),
  ];
}

class YanYanaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const YanYanaTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: YanYanaColors.textDark,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: YanYanaColors.primary, size: 21),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: YanYanaColors.surface,
        labelStyle: const TextStyle(
          color: YanYanaColors.textMuted,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: YanYanaColors.textLight,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: YanYanaColors.sos,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: YanYanaColors.sos,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final double height;
  final IconData? icon;
  final LinearGradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.icon,
    this.gradient = primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(
              colors: [Color(0xFFD4D4D4), Color(0xFFD4D4D4)],
            )
                : gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isLoading ? null : YanYanaShadows.soft,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}