import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator(color: AppColors.accent));

    return StreamBuilder<Map<String, dynamic>>(
      stream: ref.watch(firestoreServiceProvider).getWorkerStats(user.uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'totalJobs': 0, 'completedJobs': 0, 'pendingJobs': 0, 'avgRating': 0.0, 'totalEarnings': 0.0};
        final completed = stats['completedJobs'] as int;
        final total = stats['totalJobs'] as int;
        final progress = total > 0 ? completed / total : 0.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Text('Hey ${user.name}! 💪', style: AppTextStyles.bodyLarge).animate().fadeIn(),
            Text('Dashboard', style: AppTextStyles.displaySmall).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            GlassCard(padding: const EdgeInsets.all(24),
              gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.accentSecondary.withValues(alpha: 0.06)]),
              child: Row(children: [
                CircularPercentIndicator(radius: 50, lineWidth: 8, percent: progress.clamp(0.0, 1.0),
                  center: Text('${(progress * 100).toInt()}%', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.accent)),
                  progressColor: AppColors.accent, backgroundColor: AppColors.textTertiary.withValues(alpha: 0.2), circularStrokeCap: CircularStrokeCap.round),
                const SizedBox(width: 24),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Progress', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text('$completed of $total jobs done', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Keep up the great work!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentTertiary)),
                ])),
              ])).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: _StatTile(icon: Icons.monetization_on_rounded, label: 'Earnings', value: '₹${(stats['totalEarnings'] as double).toInt()}', color: AppColors.accentTertiary)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(icon: Icons.star_rounded, label: 'Rating', value: (stats['avgRating'] as double).toStringAsFixed(1), color: AppColors.warning)),
            ]).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _StatTile(icon: Icons.check_circle_rounded, label: 'Completed', value: '$completed', color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(icon: Icons.pending_actions_rounded, label: 'Pending', value: '${stats['pendingJobs']}', color: AppColors.warning)),
            ]).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context) => GlassCard(padding: const EdgeInsets.all(16), borderRadius: 18,
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ]),
    ]));
}
