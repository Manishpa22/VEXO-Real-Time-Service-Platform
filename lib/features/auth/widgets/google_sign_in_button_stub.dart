import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

Widget buildGoogleSignInButton({
  required BuildContext context,
  required VoidCallback onPressed,
  required bool isLoading,
}) {
  final colors = AppColors.of(context);
  return OutlinedButton(
    onPressed: isLoading ? null : onPressed,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: colors.inputBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: colors.isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white,
      elevation: 0,
    ),
    child: isLoading
        ? SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.textPrimary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
  );
}
