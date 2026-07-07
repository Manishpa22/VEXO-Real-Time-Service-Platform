import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/neon_button.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatelessWidget {
  final String? referralCode;
  const ReferralScreen({super.key, this.referralCode});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: Text('refer_friend'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_add_rounded, size: 80, color: AppColors.accent),
              const SizedBox(height: 24),
              Text('invite_friends'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: 12),
              Text('referral_desc'.tr(), textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  final code = referralCode ?? 'VEXO123';
                  Share.share('Use my referral code $code to get amazing discounts on premium car cleaning with VEXO app!');
                },
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(referralCode ?? 'VEXO123', style: AppTextStyles.displaySmall.copyWith(letterSpacing: 4, color: AppColors.accentTertiary)),
                ),
              ),
              const SizedBox(height: 32),
              NeonButton(
                text: 'share_code'.tr(),
                icon: Icons.share_rounded,
                onPressed: () {
                  final code = referralCode ?? 'VEXO123';
                  Share.share('Use my referral code $code to get amazing discounts on premium car cleaning with VEXO app!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutVexoScreen extends StatelessWidget {
  const AboutVexoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: Text('about_vexo'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              const SizedBox(height: 24),
              Text('VEXO Car Wash', style: AppTextStyles.displaySmall.copyWith(color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Version 1.0.0', style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
              const SizedBox(height: 32),
              Text('about_desc'.tr(), textAlign: TextAlign.center, style: TextStyle(color: colors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
