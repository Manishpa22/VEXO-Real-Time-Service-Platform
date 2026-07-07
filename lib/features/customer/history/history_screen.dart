import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/booking_model.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator(color: AppColors.accent));

    return StreamBuilder<List<BookingModel>>(
      stream: ref.watch(firestoreServiceProvider).getCustomerBookings(user.uid),
      builder: (context, snapshot) {
        final colors = AppColors.of(context);
        final bookings = snapshot.data ?? [];
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Text('nav_history'.tr(), style: AppTextStyles.displaySmall.copyWith(color: colors.textPrimary)).animate().fadeIn(),
            Text('total_washes'.tr(args: [bookings.length.toString()]), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),
            _buildStats(bookings, colors).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            if (bookings.isEmpty) _buildEmptyState(colors).animate().fadeIn(delay: 300.ms)
            else ...bookings.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HistoryCard(booking: e.value, colors: colors),
            ).animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 80)).slideY(begin: 0.08)),
            const SizedBox(height: 100),
          ]),
        );
      },
    );
  }

  Widget _buildStats(List<BookingModel> bookings, AdaptiveColors colors) {
    final completed = bookings.where((b) => b.status == "completed").length;
    final pending = bookings.where((b) => b.status == "pending" || b.status == "assigned").length;
    final rated = bookings.where((b) => b.rating != null);
    final avgRating = rated.isEmpty ? '—' : (rated.fold<double>(0, (s, b) => s + b.rating!) / rated.length).toStringAsFixed(1);
    return Row(children: [
      Expanded(child: _StatCard(label: 'completed'.tr(), value: '$completed', icon: Icons.check_circle_rounded, color: AppColors.success, colors: colors)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'pending'.tr(), value: '$pending', icon: Icons.schedule_rounded, color: AppColors.warning, colors: colors)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(label: 'avg_rating'.tr(), value: avgRating, icon: Icons.star_rounded, color: AppColors.accent, colors: colors)),
    ]);
  }

  Widget _buildEmptyState(AdaptiveColors colors) => Center(child: Column(children: [
    const SizedBox(height: 60),
    Icon(Icons.local_car_wash_rounded, size: 80, color: colors.textTertiary.withValues(alpha: 0.3)),
    const SizedBox(height: 16),
    Text('no_history'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textTertiary)),
    Text('book_first_wash'.tr(), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
  ]));
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color; final AdaptiveColors colors;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.colors});
  @override
  Widget build(BuildContext context) => GlassCard(padding: const EdgeInsets.all(14), borderRadius: 16,
    child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 8),
      Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)), Text(label, style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary))]));
}

class _HistoryCard extends StatelessWidget {
  final BookingModel booking;
  final AdaptiveColors colors;
  const _HistoryCard({required this.booking, required this.colors});
  Color _statusColor(String s) => switch (s) { 'completed' => AppColors.success, 'in_progress' => AppColors.accent, 'cancelled' => AppColors.error, _ => AppColors.warning };
  @override
  Widget build(BuildContext context) {
    final c = _statusColor(booking.status);
    return GlassCard(padding: const EdgeInsets.all(16), borderRadius: 18, child: Column(children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(booking.vehicleType == 'car' ? Icons.directions_car_rounded : Icons.two_wheeler_rounded, color: c, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.vehicleBrand != null ? '${booking.vehicleBrand} ${booking.vehicleModel}' : booking.services.join(', '),
              style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${DateFormat('d MMM, yyyy').format(booking.scheduledDate)} • ${booking.timeSlot ?? ""}', style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary)),
          if (booking.vehicleNumberPlate != null)
            Text(booking.vehicleNumberPlate!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(booking.status.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: c, fontWeight: FontWeight.w600, fontSize: 10))),
      ]),
      if (booking.workerName != null) Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [
        Icon(Icons.person_outline_rounded, size: 14, color: colors.textTertiary), const SizedBox(width: 4),
        Text(booking.workerName!, style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary)), const Spacer(),
        if (booking.rating != null) ...[const Icon(Icons.star_rounded, size: 14, color: AppColors.warning), const SizedBox(width: 2),
          Text(booking.rating!.toStringAsFixed(1), style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning))],
      ])),
    ]));
  }
}
