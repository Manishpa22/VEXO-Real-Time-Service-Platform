import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_nav_bar.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/services/auth_service.dart';
import 'home/customer_home_screen.dart';
import 'subscriptions/subscription_screen.dart';
import 'booking/booking_screen.dart';
import 'history/history_screen.dart';
import 'profile/customer_profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomerTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final customerTabProvider = NotifierProvider<CustomerTabNotifier, int>(CustomerTabNotifier.new);

class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(customerTabProvider);

    final user = ref.watch(currentUserProvider).value;
    final colors = AppColors.of(context);
    
    final screens = const [
      CustomerHomeScreen(),
      SubscriptionScreen(),
      BookingScreen(),
      HistoryScreen(),
      CustomerProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('V', style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900,
                    )),
                  ),
                ),
                const SizedBox(width: 10),
                Text('VEXO', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  letterSpacing: 3, color: colors.textPrimary,
                )),
              ]),
              Row(children: [
                IconButton(
                  onPressed: () {},
                  icon: Stack(children: [
                    Icon(Icons.notifications_outlined, color: colors.textPrimary, size: 24),
                    Positioned(top: 0, right: 0, child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.accentWarm, shape: BoxShape.circle),
                    )),
                  ]),
                ),
                const SizedBox(width: 4),
                if (user != null) GestureDetector(
                  onTap: () => ref.read(customerTabProvider.notifier).setTab(4),
                  child: UserAvatar(
                    name: user.name, gender: user.gender,
                    imageUrl: user.profileImageUrl, size: 36, showBorder: false,
                  ),
                ),
              ]),
            ]),
          ),
          if (Theme.of(context).brightness == Brightness.light)
            Divider(color: colors.divider, height: 1, thickness: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(currentIndex), child: screens[currentIndex]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(customerTabProvider.notifier).setTab(i),
        items: [
          GlassNavBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'nav_home'.tr()),
          GlassNavBarItem(icon: Icons.card_membership_outlined, activeIcon: Icons.card_membership_rounded, label: 'nav_plans'.tr()),
          GlassNavBarItem(icon: Icons.local_car_wash_outlined, activeIcon: Icons.local_car_wash_rounded, label: 'nav_book'.tr()),
          GlassNavBarItem(icon: Icons.history_outlined, activeIcon: Icons.history_rounded, label: 'nav_history'.tr()),
          GlassNavBarItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'nav_profile'.tr()),
        ],
      ),
    );
  }
}
