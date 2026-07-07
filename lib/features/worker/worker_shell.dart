import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/animated_gradient_bg.dart';
import '../../core/widgets/glass_nav_bar.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/services/auth_service.dart';
import 'dashboard/worker_dashboard_screen.dart';
import 'jobs/assigned_jobs_screen.dart';
import 'earnings/worker_earnings_screen.dart';
import 'profile/worker_profile_screen.dart';

class WorkerShell extends ConsumerStatefulWidget {
  const WorkerShell({super.key});
  @override ConsumerState<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends ConsumerState<WorkerShell> {
  int _currentIndex = 0;

  final _screens = [
    const WorkerDashboardScreen(),
    const AssignedJobsScreen(),
    const WorkerEarningsScreen(),
    const WorkerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      extendBody: true,
      body: AnimatedGradientBg(
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.secondaryGradient),
                    child: Center(child: Text('V', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)))),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('VEXO', style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 3)),
                    Text('Worker', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentTertiary, fontSize: 10)),
                  ]),
                ]),
                Row(children: [
                  IconButton(onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24)),
                  const SizedBox(width: 4),
                  if (user != null) GestureDetector(
                    onTap: () => setState(() => _currentIndex = 3),
                    child: UserAvatar(name: user.name, gender: user.gender, imageUrl: user.profileImageUrl, size: 36, showBorder: false),
                  ),
                ]),
              ]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic, switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation,
                  child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation), child: child)),
                child: KeyedSubtree(key: ValueKey(_currentIndex), child: _screens[_currentIndex]),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          GlassNavBarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
          GlassNavBarItem(icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt_rounded, label: 'Jobs'),
          GlassNavBarItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Earnings'),
          GlassNavBarItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
