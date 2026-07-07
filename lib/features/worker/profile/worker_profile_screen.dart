import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/services/auth_service.dart';


class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => const Center(child: Text('Error')),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 30),
            UserAvatar(
              name: user.name,
              gender: user.gender,
              imageUrl: user.profileImageUrl,
              size: 100,
            ).animate().scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(user.name, style: AppTextStyles.displaySmall).animate().fadeIn(delay: 200.ms),
            Text(user.phone, style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentTertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentTertiary.withValues(alpha: 0.3)),
              ),
              child: Text('WORKER', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentTertiary, fontWeight: FontWeight.w600)),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 30),

            ...[
              _MenuItem(Icons.inventory_2_rounded, 'Cleaning Kit', AppColors.accent),
              _MenuItem(Icons.event_note_rounded, 'Leave Request', AppColors.accentSecondary),
              _MenuItem(Icons.description_rounded, 'Documents', AppColors.warning),
              _MenuItem(Icons.bar_chart_rounded, 'Performance', AppColors.accentTertiary),
              _MenuItem(Icons.headset_mic_rounded, 'Support', AppColors.info),
              _MenuItem(Icons.settings_rounded, 'Settings', AppColors.textSecondary),
            ].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), borderRadius: 16,
                onTap: () {},
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: e.value.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(e.value.icon, color: e.value.color, size: 20)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(e.value.label, style: AppTextStyles.titleMedium)),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                ])),
            ).animate().fadeIn(delay: Duration(milliseconds: 500 + e.key * 60)).slideX(begin: 0.05)),

            const SizedBox(height: 16),
            NeonButton(
              text: 'Sign Out', icon: Icons.logout_rounded,
              gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFFF8E53)]),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                // AuthWrapper handles navigation on signOut
              }).animate().fadeIn(delay: 900.ms),
            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon; final String label; final Color color;
  const _MenuItem(this.icon, this.label, this.color);
}
