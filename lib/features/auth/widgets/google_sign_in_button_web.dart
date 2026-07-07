import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget buildGoogleSignInButton({
  required BuildContext context,
  required VoidCallback onPressed,
  required bool isLoading,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: Center(
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: web.GSIButtonType.standard,
          shape: web.GSIButtonShape.rectangular,
          theme: web.GSIButtonTheme.outline,
          text: web.GSIButtonText.signinWith,
          size: web.GSIButtonSize.large,
          minimumWidth: 320,
        ),
      ),
    ),
  );
}
