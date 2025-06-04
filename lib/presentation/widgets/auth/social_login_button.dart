import 'package:flutter/material.dart';

enum SocialLoginType {
  google,
  facebook,
  apple,
  twitter,
}

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  IconData _getIcon() {
    switch (type) {
      case SocialLoginType.google:
        return Icons.g_mobiledata;
      case SocialLoginType.facebook:
        return Icons.facebook;
      case SocialLoginType.apple:
        return Icons.apple;
      case SocialLoginType.twitter:
        return Icons.flutter_dash;
    }
  }

  Color _getColor() {
    switch (type) {
      case SocialLoginType.google:
        return Colors.red;
      case SocialLoginType.facebook:
        return const Color(0xFF1877F2);
      case SocialLoginType.apple:
        return Colors.black;
      case SocialLoginType.twitter:
        return const Color(0xFF1DA1F2);
    }
  }

  String _getText() {
    switch (type) {
      case SocialLoginType.google:
        return 'Continue with Google';
      case SocialLoginType.facebook:
        return 'Continue with Facebook';
      case SocialLoginType.apple:
        return 'Continue with Apple';
      case SocialLoginType.twitter:
        return 'Continue with Twitter';
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        side: BorderSide(color: _getColor()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
              ),
            )
          : Icon(_getIcon(), color: _getColor()),
      label: Text(
        _getText(),
        style: TextStyle(color: _getColor()),
      ),
    );
  }
} 