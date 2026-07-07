import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'otp_screen.dart';
import 'profile_setup_screen.dart';
import 'widgets/google_sign_in_button.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 10-digit phone number'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).sendOtp(phone);
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => OtpScreen(phone: phone),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().split('Exception:').last.trim()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();

      if (mounted) {
        // AuthWrapper will handle navigation automatically, just pop to root
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        final msg = e.toString().contains('cancelled')
            ? 'Sign-in cancelled'
            : 'Google sign-in failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              // Icon
              Center(
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 48),
                ),
              ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),

              const SizedBox(height: 36),

              // Title
              Center(
                child: Text(
                  'Welcome to VEXO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: colors.textPrimary, height: 1.2,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Sign in with your phone or Google account',
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 40),

              // ─── GOOGLE SIGN-IN BUTTON ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: buildGoogleSignInButton(
                  context: context,
                  onPressed: _signInWithGoogle,
                  isLoading: _isGoogleLoading,
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 28),

              // ─── OR DIVIDER ──────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: colors.textTertiary, letterSpacing: 1,
                    )),
                  ),
                  Expanded(child: Divider(color: colors.border)),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 28),

              // ─── PHONE INPUT ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inputBorder, width: 1.5),
                  boxShadow: colors.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: colors.inputBorder)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 6),
                          Text('+91', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          letterSpacing: 1.5, color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '98765 43210',
                          hintStyle: TextStyle(
                            color: colors.textTertiary, fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          filled: false,
                        ),
                        onSubmitted: (_) => _sendOtp(),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send OTP', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 28),

              // Terms
              Center(
                child: Text(
                  'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary, height: 1.5),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
