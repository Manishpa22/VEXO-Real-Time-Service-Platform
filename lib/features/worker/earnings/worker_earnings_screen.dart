import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class WorkerEarningsScreen extends ConsumerWidget {
  const WorkerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator(color: AppColors.accent));

    return StreamBuilder<Map<String, dynamic>>(
      stream: ref.watch(firestoreServiceProvider).getWorkerStats(user.uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'totalEarnings': 0.0, 'completedJobs': 0};
        final earnings = (stats['totalEarnings'] as double).toInt();
        final jobs = stats['completedJobs'] as int;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Text('Earnings', style: AppTextStyles.displaySmall).animate().fadeIn(),
            const SizedBox(height: 24),

            GlassCard(padding: const EdgeInsets.all(24),
              gradient: LinearGradient(colors: [AppColors.accentTertiary.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.05)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Earnings', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text('₹$earnings', style: AppTextStyles.displayLarge.copyWith(
                  foreground: Paint()..shader = AppColors.secondaryGradient.createShader(const Rect.fromLTWH(0, 0, 200, 50)))),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.work_rounded, color: AppColors.accent, size: 16), const SizedBox(width: 4),
                  Text('$jobs jobs completed', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                ]),
              ])).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            Text('Payout Info', style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

            GlassCard(padding: const EdgeInsets.all(18), borderRadius: 18,
              child: Column(children: [
                _PayoutRow(label: 'Per Job', value: '₹150'),
                const Divider(color: AppColors.surfaceLight, height: 20),
                _PayoutRow(label: 'Jobs Completed', value: '$jobs'),
                const Divider(color: AppColors.surfaceLight, height: 20),
                _PayoutRow(label: 'Payout Date', value: '1st of month'),
                const Divider(color: AppColors.surfaceLight, height: 20),
                _PayoutRow(label: 'Payment Mode', value: 'Bank Transfer'),
              ])).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }
}

class _PayoutRow extends StatelessWidget {
  final String label, value;
  const _PayoutRow({required this.label, required this.value});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: AppTextStyles.bodyMedium),
    Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.accent)),
  ]);
}
