import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'package:easy_localization/easy_localization.dart';

import '../booking/quick_booking_screens.dart';
import '../history/customer_history_screens.dart';
import '../customer_shell.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Greeting
            userAsync.when(
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_getGreeting().tr()}! 👋', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(user?.name ?? 'guest'.tr(), style: AppTextStyles.displaySmall),
                  Text(today, style: AppTextStyles.bodySmall),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

            const SizedBox(height: 24),

            // Active Subscription Card
            _buildSubscriptionCard(ref)
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.15, curve: Curves.easeOutCubic),

            const SizedBox(height: 20),

            // Quick Actions
            Text('quick_actions'.tr(), style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _QuickActionCard(icon: Icons.local_car_wash_rounded, label: 'book_wash'.tr(), color: AppColors.accent, gradient: AppColors.primaryGradient, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BookWashScreen()));
                })),
                const SizedBox(width: 12),
                Expanded(child: _QuickActionCard(icon: Icons.calendar_month_rounded, label: 'view_schedule'.tr(), color: AppColors.accentTertiary, gradient: AppColors.secondaryGradient, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewScheduleScreen()));
                })),
                const SizedBox(width: 12),
                Expanded(child: _QuickActionCard(icon: Icons.star_rounded, label: 'rate_cleaner'.tr(), color: AppColors.warning, gradient: AppColors.warmGradient, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RateCleanerScreen()));
                })),
                const SizedBox(width: 12),
                Expanded(child: _QuickActionCard(icon: Icons.history_rounded, label: 'wash_history'.tr(), color: AppColors.accentSecondary, gradient: LinearGradient(colors: [AppColors.accentSecondary, AppColors.accent.withValues(alpha: 0.8)]), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WashHistoryScreen()));
                })),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),

            const SizedBox(height: 24),

            // Upcoming Wash
            StreamBuilder(
              stream: ref.watch(firestoreServiceProvider).getCustomerBookings(userAsync.value?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
                final bookings = snapshot.data ?? [];
                final upcoming = bookings.where((b) => b.status == 'pending' || b.status == 'assigned').toList();
                
                if (upcoming.isEmpty) return const SizedBox.shrink();

                final up = upcoming.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('upcoming_wash'.tr(), style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 12),
                    _UpcomingWashCard(booking: up).animate().fadeIn(delay: 600.ms).slideY(begin: 0.15),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Service Plans Banner
            Text('explore_plans'.tr(), style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 12),

            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                children: [
                  _PlanBannerCard(title: 'plan_bike_name'.tr(), price: '₹399', period: 'days_28_period'.tr(), features: 'plan_bike_feat1'.tr(), gradient: LinearGradient(colors: [AppColors.accentSecondary, AppColors.accent]), imagePath: 'assets/images/bike.png', shadowColor: AppColors.accent),
                  const SizedBox(width: 12),
                  _PlanBannerCard(title: 'plan_vexogo_name'.tr(), price: '₹799', period: 'days_28_period'.tr(), features: 'plan_vexogo_feat1'.tr(), gradient: AppColors.primaryGradient, imagePath: 'assets/images/vexo_go_car.png', shadowColor: Colors.grey),
                  const SizedBox(width: 12),
                  _PlanBannerCard(title: 'plan_vexopremium_name'.tr(), price: '₹999', period: 'days_28_period'.tr(), features: 'plan_vexopremium_feat1'.tr(), gradient: AppColors.warmGradient, imagePath: 'assets/images/vexo_per_car.png', shadowColor: Colors.orange),
                  const SizedBox(width: 12),
                  _PlanBannerCard(title: 'plan_yearlyno_name'.tr(), price: '₹10k', period: 'year_period'.tr(), features: 'plan_yearlyno_feat1'.tr(), gradient: AppColors.secondaryGradient, imagePath: 'assets/images/vexo_yerar_car.png', shadowColor: Colors.deepPurple),
                  const SizedBox(width: 12),
                  _PlanBannerCard(title: 'plan_yearlyce_name'.tr(), price: '₹12k', period: 'year_period'.tr(), features: 'plan_yearlyce_feat5'.tr(), gradient: AppColors.secondaryGradient, imagePath: 'assets/images/vexo_yerar_car.png', shadowColor: Colors.deepPurple),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder(
      stream: ref.watch(firestoreServiceProvider).getActiveSubscription(user.uid),
      builder: (context, snapshot) {
        final sub = snapshot.data;
        if (sub == null) {
          return GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.1), AppColors.accentSecondary.withValues(alpha: 0.05)]),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('no_active_plan'.tr(), style: AppTextStyles.headlineSmall),
                Text('subscribe_to_get'.tr(), style: AppTextStyles.bodySmall),
              ])),
            ]),
          );
        }

        final daysLeft = sub.endDate.difference(DateTime.now()).inDays;
        final totalDays = sub.endDate.difference(sub.startDate).inDays;
        final progress = totalDays > 0 ? (totalDays - daysLeft) / totalDays : 0.0;

        return GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.accentSecondary.withValues(alpha: 0.08)]),
          child: Column(children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sub.planName, style: AppTextStyles.headlineSmall),
                Text(sub.vehicleType == 'car' ? 'car_plan'.tr() : 'bike_plan'.tr(), style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text('purchased_on'.tr(args: [DateFormat('d MMM yyyy').format(sub.startDate)]), style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                child: Text('active'.tr(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('days_remaining'.tr(args: [daysLeft.toString(), totalDays.toString()]), style: AppTextStyles.bodySmall),
                Text('${(progress * 100).toInt()}%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: AppColors.textTertiary.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation(AppColors.accent), minHeight: 6)),
            ]),
          ]),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'greeting_morning';
    if (hour < 17) return 'greeting_afternoon';
    return 'greeting_evening';
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon; final String label; final Color color; final Gradient gradient; final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.gradient, required this.onTap});
  @override State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(duration: const Duration(milliseconds: 150), vsync: this); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) => _c.forward(), onTapUp: (_) { _c.reverse(); widget.onTap(); }, onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: Tween<double>(begin: 1.0, end: 0.95).animate(_c),
        child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), borderRadius: 18,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: widget.gradient, borderRadius: BorderRadius.circular(12)),
              child: Icon(widget.icon, color: Colors.white, size: 22)),
            const SizedBox(height: 10),
            Text(widget.label, textAlign: TextAlign.center, style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w500, fontSize: 11)),
          ]))));
  }
}

class _UpcomingWashCard extends StatelessWidget {
  final dynamic booking;
  const _UpcomingWashCard({this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking == null) return const SizedBox.shrink();
    
    // Parse the date (assuming scheduledDate is a Timestamp or DateTime)
    DateTime date;
    if (booking.scheduledDate == null) {
      date = DateTime.now();
    } else {
      date = booking.scheduledDate.toDate();
    }
    
    final isTomorrow = date.day == DateTime.now().add(const Duration(days: 1)).day;
    final dayLabel = isTomorrow ? 'TOM' : DateFormat('dd MMM').format(date).toUpperCase();
    final timeStr = DateFormat('h:mm').format(date);
    final amPm = DateFormat('a').format(date);

    return GlassCard(padding: const EdgeInsets.all(20), child: Row(children: [
      Container(width: 60, height: 60, decoration: BoxDecoration(gradient: AppColors.secondaryGradient, borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(dayLabel, style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
          Text(timeStr, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 16)),
          Text(amPm, style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 9)),
        ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isTomorrow ? 'tomorrows_wash'.tr() : 'upcoming_wash'.tr(), style: AppTextStyles.titleLarge),
        const SizedBox(height: 4),
        Text(booking.package ?? 'Standard Wash', style: AppTextStyles.bodySmall),
        if (booking.workerName != null) ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.person_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(booking.workerName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
          ]),
        ]
      ])),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accent, size: 16)),
    ]));
  }
}

class _PlanBannerCard extends ConsumerWidget {
  final String title, price, period, features, imagePath;
  final Gradient gradient;
  final Color shadowColor;
  
  const _PlanBannerCard({
    required this.title, required this.price, required this.period,
    required this.features, required this.gradient, required this.imagePath,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () {
      ref.read(customerTabProvider.notifier).setTab(1);
    },
    child: Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      clipBehavior: Clip.antiAlias, // Clips overlapping image corners cleanly
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        boxShadow: [
          BoxShadow(color: shadowColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          // 1. Vehicle Graphics Placement Layer
          Positioned(
            bottom: -15,
            right: -25,
            child: Image.asset(
              imagePath,
              width: 190,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 100),
            ),
          ),
          
          // 2. Foreground Text Content Layer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(features, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontSize: 24)),
                    Text(period, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
