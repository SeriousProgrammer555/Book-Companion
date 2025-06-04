import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryLabel;
  final Color? color;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.retryLabel,
    this.color,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.error;
    final effectiveIconSize = iconSize ?? 64.0;

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: effectiveIconSize * 1.5,
              height: effectiveIconSize * 1.5,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: effectiveIconSize,
                color: effectiveColor,
              ),
            ).animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveColor,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required String message,
    VoidCallback? onRetry,
    String? retryLabel,
    Color? backgroundColor,
    super.duration,
  }) : super(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    onRetry();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: Text(retryLabel ?? 'Retry'),
                ),
              ],
            ],
          ),
          backgroundColor: backgroundColor ?? Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        );
}

class ErrorDialog extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final String? cancelLabel;
  final Color? color;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.cancelLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.error;

    return AlertDialog(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            )
          : null,
      content: Text(
        message,
        style: GoogleFonts.poppins(
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(retryLabel ?? 'Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel ?? 'OK'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String message,
    String? title,
    VoidCallback? onRetry,
    String? retryLabel,
    String? cancelLabel,
    Color? color,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        title: title,
        onRetry: onRetry,
        retryLabel: retryLabel,
        cancelLabel: cancelLabel,
        color: color,
      ),
    );
  }
} 