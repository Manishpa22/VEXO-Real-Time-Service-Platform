import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/theme_provider.dart';

import '../vehicles/vehicle_list_screen.dart';
import 'profile_features_screens.dart';
import '../history/customer_history_screens.dart';
import 'settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final colors = AppColors.of(context);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => const Center(child: Text('Error loading profile')),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 30),
            UserAvatar(
              name: user.name,
              gender: user.gender,
              imageUrl: user.profileImageUrl,
              size: 100,
            ).animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(user.name, style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary,
            )).animate().fadeIn(delay: 200.ms),
            Text(user.phone, style: TextStyle(
              fontSize: 14, color: colors.textSecondary,
            )).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Text(user.role.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 30),

            // Referral code
            if (user.referralCode != null) GlassCard(
              padding: const EdgeInsets.all(18), borderRadius: 18,
              gradient: LinearGradient(colors: [AppColors.accentTertiary.withValues(alpha: 0.12), AppColors.accent.withValues(alpha: 0.06)]),
              onTap: () {
                Share.share('Use my referral code ${user.referralCode} to get amazing discounts on premium car cleaning with VEXO app!');
              },
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: AppColors.secondaryGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('referral_code'.tr(), style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary,
                  )),
                  Text(user.referralCode!, style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accentTertiary, letterSpacing: 3,
                  )),
                ])),
                IconButton(onPressed: () {
                  Share.share('Use my referral code ${user.referralCode} to get amazing discounts on premium car cleaning with VEXO app!');
                }, icon: const Icon(Icons.share_rounded, color: AppColors.accent)),
              ]),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),

            // Menu items
            ..._buildMenuItems(context, ref, user),
            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, WidgetRef ref, dynamic user) {
    final colors = AppColors.of(context);
    final items = [
      _MenuItem(Icons.directions_car_rounded, 'my_vehicles'.tr(), AppColors.accent, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleListScreen()));
      }),
      _MenuItem(Icons.card_membership_rounded, 'nav_plans'.tr(), AppColors.accentSecondary, () {}),
      _MenuItem(Icons.payment_rounded, 'payment_history'.tr(), AppColors.accentTertiary, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()));
      }),
      _MenuItem(Icons.settings_rounded, 'settings'.tr(), const Color(0xFF8B5CF6), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
      }),
    ];
    return [
      ...items.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), borderRadius: 16,
          onTap: e.value.onTap,
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: e.value.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(e.value.icon, color: e.value.color, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Text(e.value.label, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary,
            ))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.textTertiary),
          ]),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 600 + e.key * 60)).slideX(begin: 0.05)),
      const SizedBox(height: 16),
      NeonButton(
        text: 'sign_out'.tr(), icon: Icons.logout_rounded,
        gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFFF8E53)]),
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
        },
      ).animate().fadeIn(delay: 900.ms),
    ];
  }

}

class _MenuItem {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.12)
              : colors.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : colors.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isSelected ? AppColors.accent : colors.textSecondary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.accent : colors.textPrimary,
            )),
            Text(subtitle, style: TextStyle(
              fontSize: 12, color: colors.textTertiary,
            )),
          ])),
          if (isSelected)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
        ]),
      ),
    );
  }
}
