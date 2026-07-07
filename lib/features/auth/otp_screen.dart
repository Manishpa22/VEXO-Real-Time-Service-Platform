import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = PinInputController();
  bool _isVerifying = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);

    try {
      await ref.read(authServiceProvider).verifyOtp(widget.phone, otp);

      if (mounted) {
        // Show success animation
        await _showSuccessDialog();

        // AuthWrapper in main.dart will detect the auth state change
        // and swap to the dashboard automatically.
        // Pop all the way back so AuthWrapper takes over.
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _otpController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP: ${e.toString().split('Exception:').last.trim()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Verification Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: AppColors.of(context).cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.secondaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentTertiary.withValues(alpha: 0.4),
                                blurRadius: 20, spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verified!',
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phone number verified successfully',
                    style: TextStyle(fontSize: 14, color: AppColors.of(context).textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    // Auto-dismiss after 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.of(context).pop(); // pop the dialog
  }

  void _resendOtp() async {
    try {
      await ref.read(authServiceProvider).resendOtp(widget.phone);
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP resent successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to resend OTP'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maskedPhone = '+91 ${widget.phone.substring(0, 2)}****${widget.phone.substring(6)}';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: colors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // Lock icon
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentTertiary.withValues(alpha: 0.3),
                        blurRadius: 25, spreadRadius: 5, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 44),
                ),
              ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  'Verify your\nphone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: colors.textPrimary, height: 1.2,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Enter the 6-digit code sent to\n$maskedPhone',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.5),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 40),

              // OTP Fields
              MaterialPinField(
                length: 6,
                pinController: _otpController,
                autoFocus: true,
                keyboardType: TextInputType.number,
                theme: MaterialPinTheme(
                  shape: MaterialPinShape.outlined,
                  cellSize: const Size(48, 56),
                  borderRadius: BorderRadius.circular(14),
                  borderWidth: 1.5,
                ),
                onCompleted: (_) => _verifyOtp(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Verify OTP', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: _resendTimer > 0
                    ? Text(
                        'Resend code in ${_resendTimer}s',
                        style: TextStyle(fontSize: 14, color: colors.textTertiary),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
