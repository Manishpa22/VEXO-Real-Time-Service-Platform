import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_bg.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/vehicle_model.dart';
import 'add_vehicle_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final colors = AppColors.of(context);
    if (user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      body: AnimatedGradientBg(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: colors.textPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('my_vehicles'.tr(), style: AppTextStyles.displaySmall.copyWith(color: colors.textPrimary)),
                    const Spacer(),
                  ],
                ),
              ).animate().fadeIn(),

              // Vehicle list
              Expanded(
                child: StreamBuilder<List<VehicleModel>>(
                  stream: ref.watch(firestoreServiceProvider).getUserVehicles(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }

                    final vehicles = snapshot.data ?? [];

                    if (vehicles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car_outlined,
                              size: 80, color: colors.textTertiary.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('no_vehicles'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textTertiary)),
                            const SizedBox(height: 8),
                            Text('add_first_vehicle'.tr(), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
                            const SizedBox(height: 32),
                            NeonButton(
                              text: 'add_vehicle'.tr(),
                              icon: Icons.add_rounded,
                              onPressed: () => _navigateToAdd(context),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(v.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 28),
                            ),
                            confirmDismiss: (direction) => showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: colors.surface,
                                title: Text('delete_vehicle'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)),
                                content: Text('remove_vehicle_confirm'.tr(args: ['${v.brand} ${v.model}']), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr(), style: TextStyle(color: colors.textSecondary))),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('delete'.tr(), style: const TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              ref.read(firestoreServiceProvider).deleteVehicle(v.id, user.uid);
                            },
                            child: _VehicleCard(vehicle: v, colors: colors),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 80)).slideY(begin: 0.08);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('add_vehicle'.tr(), style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final AdaptiveColors colors;
  const _VehicleCard({required this.vehicle, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isCar = vehicle.type == 'car';
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isCar ? AppColors.primaryGradient : AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${vehicle.brand} ${vehicle.model}', style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary)),
                Text('${vehicle.color} • ${vehicle.numberPlate}', style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary)),
                if (vehicle.parkingSpot != null || vehicle.societyName != null)
                  Text(
                    [vehicle.societyName, if (vehicle.parkingSpot != null) 'P-${vehicle.parkingSpot}']
                        .whereType<String>()
                        .join(' • '),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isCar ? AppColors.accent : AppColors.accentTertiary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vehicle.type.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: isCar ? AppColors.accent : AppColors.accentTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
