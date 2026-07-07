import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/booking_model.dart';

class AssignedJobsScreen extends ConsumerWidget {
  const AssignedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator(color: AppColors.accent));

    return StreamBuilder<List<BookingModel>>(
      stream: ref.watch(firestoreServiceProvider).getWorkerTodayBookings(user.uid),
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? [];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Text('Today\'s Jobs', style: AppTextStyles.displaySmall).animate().fadeIn(),
            Text('${jobs.length} vehicles assigned', style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            if (jobs.isEmpty)
              Center(child: Column(children: [
                const SizedBox(height: 60),
                Icon(Icons.inbox_rounded, size: 80, color: AppColors.textTertiary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No jobs for today', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textTertiary)),
                Text('Check back later or contact admin', style: AppTextStyles.bodyMedium),
              ])).animate().fadeIn(delay: 200.ms)
            else
              ...jobs.asMap().entries.map((e) {
                final job = e.value;
                final statusColor = _statusColor(job.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16), borderRadius: 18,
                    child: Column(children: [
                      Row(children: [
                        Container(padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                          child: Icon(job.vehicleType == 'car' ? Icons.directions_car_rounded : Icons.two_wheeler_rounded, color: statusColor, size: 24)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(job.customerName ?? 'Customer', style: AppTextStyles.titleLarge),
                          if (job.vehicleBrand != null)
                            Text('${job.vehicleBrand} ${job.vehicleModel} • ${job.vehicleColor ?? ""}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          if (job.vehicleNumberPlate != null)
                            Text(job.vehicleNumberPlate!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
                          Text(job.address, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (job.parkingSpot != null)
                            Text('Parking: ${job.parkingSpot}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentTertiary)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(job.status.replaceAll('_', ' ').toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 9))),
                          const SizedBox(height: 6),
                          if (job.timeSlot != null)
                            Text(job.timeSlot!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Text(job.services.join(' • '), style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (job.status == 'assigned' || job.status == 'pending')
                          GestureDetector(
                            onTap: () {
                              ref.read(firestoreServiceProvider).updateBookingStatus(job.id, 'in_progress');
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Started job for ${job.customerName}'),
                                backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating));
                            },
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                              child: Text('Start', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600))))
                        else if (job.status == 'in_progress')
                          GestureDetector(
                            onTap: () {
                              ref.read(firestoreServiceProvider).updateBookingStatus(job.id, 'completed');
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Completed job for ${job.customerName}'),
                                backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating));
                            },
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(gradient: AppColors.secondaryGradient, borderRadius: BorderRadius.circular(12)),
                              child: Text('Done', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600))))
                        else if (job.status == 'completed')
                          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                              const SizedBox(width: 4),
                              Text('Done', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                            ])),
                      ]),
                    ]),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 200 + e.key * 100)).slideY(begin: 0.08);
              }),
            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }

  Color _statusColor(String s) => switch (s) { 'completed' => AppColors.success, 'in_progress' => AppColors.accent, 'cancelled' => AppColors.error, _ => AppColors.warning };
}
