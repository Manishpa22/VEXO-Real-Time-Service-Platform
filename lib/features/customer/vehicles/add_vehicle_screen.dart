import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_bg.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/vehicle_model.dart';
import 'package:easy_localization/easy_localization.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  String _type = 'car';
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _parkingController = TextEditingController();
  final _societyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _parkingController.dispose();
    _societyController.dispose();
    super.dispose();
  }

  void _addVehicle() async {
    if (_brandController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fill_required_fields'.tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final vehicle = VehicleModel(
      id: const Uuid().v4(),
      ownerId: user.uid,
      type: _type,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : 'not_specified'.tr(),
      numberPlate: _plateController.text.trim().toUpperCase(),
      parkingSpot: _parkingController.text.trim().isNotEmpty ? _parkingController.text.trim() : null,
      societyName: _societyController.text.trim().isNotEmpty ? _societyController.text.trim() : null,
    );

    // Optimistic UI updates - dispatch without awaiting so the user doesn't wait
    ref.read(firestoreServiceProvider).addVehicle(vehicle).catchError((e) {
      debugPrint('Error adding vehicle: $e');
    });

    if (mounted) {
      Navigator.pop(context);
      
      // Delay snackbar slightly so it appears gracefully after screen transitions
      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('vehicle_added_success'.tr(args: ['${vehicle.brand} ${vehicle.model}'])),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: AnimatedGradientBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
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
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                Text('add_vehicle'.tr(), style: AppTextStyles.displaySmall.copyWith(color: colors.textPrimary))
                    .animate().fadeIn(delay: 100.ms),
                Text('enter_vehicle_details'.tr(), style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary))
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),

                // Type selector
                Text('vehicle_type'.tr(), style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary))
                    .animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _TypeButton(
                    icon: Icons.directions_car_rounded,
                    label: 'car'.tr(),
                    isSelected: _type == 'car',
                    onTap: () => setState(() => _type = 'car'),
                    colors: colors,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _TypeButton(
                    icon: Icons.two_wheeler_rounded,
                    label: 'bike'.tr(),
                    isSelected: _type == 'bike',
                    onTap: () => setState(() => _type = 'bike'),
                    colors: colors,
                  )),
                ]).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildField(_brandController, 'brand'.tr() + ' *', 'brand_hint'.tr(), Icons.branding_watermark_rounded, colors),
                      const SizedBox(height: 16),
                      _buildField(_modelController, 'model'.tr() + ' *', 'model_hint'.tr(), Icons.category_rounded, colors),
                      const SizedBox(height: 16),
                      _buildField(_colorController, 'color'.tr(), 'color_hint'.tr(), Icons.palette_rounded, colors),
                      const SizedBox(height: 16),
                      _buildField(_plateController, 'number_plate'.tr() + ' *', 'plate_hint'.tr(), Icons.pin_rounded, colors),
                      const SizedBox(height: 16),
                      _buildField(_societyController, 'society_building'.tr(), 'society_hint'.tr(), Icons.apartment_rounded, colors),
                      const SizedBox(height: 16),
                      _buildField(_parkingController, 'parking_spot'.tr(), 'parking_hint'.tr(), Icons.local_parking_rounded, colors),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),
                NeonButton(
                  text: 'add_vehicle'.tr(),
                  icon: Icons.add_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _addVehicle,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, String hint, IconData icon, AdaptiveColors colors) {
    return TextField(
      controller: c,
      style: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AdaptiveColors colors;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 18,
        opacity: isSelected ? 0.15 : 0.06,
        borderOpacity: isSelected ? 0.4 : 0.15,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: isSelected ? Colors.white : colors.textTertiary,
                size: 30),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              )),
        ]),
      ),
    );
  }
}
