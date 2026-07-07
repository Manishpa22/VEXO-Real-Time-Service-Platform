import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/booking_model.dart';
import '../../../models/vehicle_model.dart';
import 'package:easy_localization/easy_localization.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedTimeSlot = 0;
  List<String> _selectedServices = ['Exterior Wash'];
  bool _isBooking = false;
  VehicleModel? _selectedVehicle;

  final _timeSlots = ['6:00 AM', '6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM', '4:00 PM', '4:30 PM', '5:00 PM'];
  final _additionalServicesKeys = ['service_tyre_polish', 'service_dashboard_polish', 'service_car_perfume'];

  void _bookWash() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select a vehicle first'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() => _isBooking = true);

    final v = _selectedVehicle!;
    final booking = BookingModel(
      id: const Uuid().v4(),
      customerId: user.uid,
      vehicleId: v.id,
      vehicleType: v.type,
      status: 'pending',
      scheduledDate: _selectedDate,
      timeSlot: _timeSlots[_selectedTimeSlot],
      address: user.address ?? v.societyName ?? 'Not set',
      societyName: v.societyName,
      parkingSpot: v.parkingSpot,
      services: ['Exterior Wash', ..._selectedServices],
      createdAt: DateTime.now(),
      customerName: user.name,
      vehicleBrand: v.brand,
      vehicleModel: v.model,
      vehicleColor: v.color,
      vehicleNumberPlate: v.numberPlate,
    );

    try {
      await ref.read(firestoreServiceProvider).createBooking(booking);
      setState(() => _isBooking = false);
      if (mounted) {
        _showBookingSuccessDialog();
      }
    } catch (e) {
      setState(() => _isBooking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showBookingSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Booking Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Booking Confirmed!', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Your wash is scheduled for ${DateFormat('MMM d').format(_selectedDate)} at ${_timeSlots[_selectedTimeSlot]}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedVehicle != null)
                    Text(
                      '${_selectedVehicle!.brand} ${_selectedVehicle!.model} • ${_selectedVehicle!.numberPlate}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Great!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('book_a_wash'.tr(), style: AppTextStyles.displaySmall.copyWith(color: colors.textPrimary)).animate().fadeIn(),
            Text('schedule_cleaning'.tr(), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 28),

            // Vehicle Selector
            Text('select_vehicle'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),

            if (user != null)
              StreamBuilder<List<VehicleModel>>(
                stream: ref.watch(firestoreServiceProvider).getUserVehicles(user.uid),
                builder: (context, snapshot) {
                  final vehicles = snapshot.data ?? [];
                  if (vehicles.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(20), borderRadius: 18,
                      child: Column(children: [
                        Icon(Icons.directions_car_outlined, color: colors.textTertiary, size: 40),
                        const SizedBox(height: 8),
                        Text('no_vehicles'.tr(), style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary)),
                        Text('go_to_profile_add'.tr(), style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary)),
                      ]),
                    );
                  }
                  // Auto-select first vehicle if none selected
                  if (_selectedVehicle == null && vehicles.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedVehicle = vehicles.first);
                    });
                  }
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: vehicles.length,
                      itemBuilder: (context, i) {
                        final v = vehicles[i];
                        final isSelected = _selectedVehicle?.id == v.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVehicle = v),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 160,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.primaryGradient : null,
                                color: isSelected ? null : colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: isSelected ? Colors.transparent : colors.border),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(v.type == 'car' ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                                    color: isSelected ? Colors.white : colors.textTertiary, size: 24),
                                const SizedBox(height: 8),
                                Text('${v.brand} ${v.model}', style: AppTextStyles.titleMedium.copyWith(color: isSelected ? Colors.white : colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(v.numberPlate, style: AppTextStyles.bodySmall.copyWith(color: isSelected ? Colors.white.withValues(alpha: 0.8) : colors.textTertiary, fontSize: 11)),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 28),

            // Date picker
            Text('select_date'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: 7,
                itemBuilder: (context, i) {
                  final date = DateTime.now().add(Duration(days: i + 1));
                  final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
                  return Padding(padding: const EdgeInsets.only(right: 10), child: _DateCard(date: date, isSelected: isSelected, onTap: () => setState(() => _selectedDate = date)));
                },
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 28),

            // Time slots
            Text('time_slot'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)).animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10,
              children: List.generate(_timeSlots.length, (i) {
                final isSelected = _selectedTimeSlot == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeSlot = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(gradient: isSelected ? AppColors.primaryGradient : null, color: isSelected ? null : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? Colors.transparent : colors.border)),
                    child: Text(_timeSlots[i], style: AppTextStyles.titleMedium.copyWith(color: isSelected ? Colors.white : colors.textSecondary)),
                  ),
                );
              }),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 28),

            // Additional services
            Text('addon_services'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary)).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 12),
            ...List.generate(_additionalServicesKeys.length, (i) {
              final serviceKey = _additionalServicesKeys[i];
              final serviceName = serviceKey.tr();
              final isSelected = _selectedServices.contains(serviceName);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), borderRadius: 14, opacity: isSelected ? 0.15 : 0.06,
                  onTap: () => setState(() { isSelected ? _selectedServices.remove(serviceName) : _selectedServices.add(serviceName); }),
                  child: Row(children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 250), width: 24, height: 24,
                      decoration: BoxDecoration(gradient: isSelected ? AppColors.primaryGradient : null, color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(7), border: Border.all(color: isSelected ? Colors.transparent : AppColors.textTertiary)),
                      child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null),
                    const SizedBox(width: 14),
                    Text(serviceName, style: AppTextStyles.bodyLarge.copyWith(color: isSelected ? colors.textPrimary : colors.textSecondary)),
                  ]),
                ),
              );
            }).animate(interval: 50.ms).fadeIn(delay: 600.ms).slideX(begin: 0.05),

            const SizedBox(height: 24),
            NeonButton(text: 'book_wash_btn'.tr(), icon: Icons.local_car_wash_rounded, isLoading: _isBooking, onPressed: _isBooking ? null : _bookWash)
                .animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime date; final bool isSelected; final VoidCallback onTap;
  const _DateCard({required this.date, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), width: 65,
        decoration: BoxDecoration(gradient: isSelected ? AppColors.primaryGradient : null, color: isSelected ? null : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? Colors.transparent : colors.border)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(DateFormat('EEE').format(date).toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white.withValues(alpha: 0.8) : colors.textTertiary, fontSize: 10)),
          const SizedBox(height: 4),
          Text('${date.day}', style: AppTextStyles.headlineMedium.copyWith(color: isSelected ? Colors.white : colors.textPrimary)),
          Text(DateFormat('MMM').format(date), style: AppTextStyles.bodySmall.copyWith(color: isSelected ? Colors.white.withValues(alpha: 0.8) : colors.textTertiary, fontSize: 11)),
        ])));
  }
}
