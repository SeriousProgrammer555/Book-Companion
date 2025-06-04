import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum PasswordStrength {
  tooWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final Color? color;
  final double height;
  final bool showLabel;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.color,
    this.height = 4.0,
    this.showLabel = true,
  });

  PasswordStrength _calculateStrength() {
    if (password.isEmpty) return PasswordStrength.tooWeak;
    if (password.length < 6) return PasswordStrength.weak;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;
    if (password.length >= 12) strength++;

    switch (strength) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.medium;
      case 3:
        return PasswordStrength.strong;
      case 4:
      case 5:
        return PasswordStrength.veryStrong;
      default:
        return PasswordStrength.tooWeak;
    }
  }

  String _getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.tooWeak:
        return 'Too Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  Color _getStrengthColor(PasswordStrength strength, ColorScheme colorScheme) {
    final effectiveColor = color ?? colorScheme.primary;
    switch (strength) {
      case PasswordStrength.tooWeak:
        return colorScheme.error;
      case PasswordStrength.weak:
        return Colors.red.shade400;
      case PasswordStrength.medium:
        return Colors.orange.shade400;
      case PasswordStrength.strong:
        return Colors.lightGreen.shade400;
      case PasswordStrength.veryStrong:
        return effectiveColor;
    }
  }

  double _getStrengthWidth(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.tooWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strength = _calculateStrength();
    final strengthColor = _getStrengthColor(strength, colorScheme);
    final strengthWidth = _getStrengthWidth(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: strengthWidth,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: height,
          ),
        ).animate(target: strengthWidth)
          .custom(
            duration: 300.ms,
            builder: (context, value, child) => SizedBox(
              height: height,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: strengthColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ),
          ),
        if (showLabel && password.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _getStrengthLabel(strength),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: strengthColor,
              fontWeight: FontWeight.w500,
            ),
          ).animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }
} 