import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../models/vehicle_model.dart';
import '../customer/customer_shell.dart';
import '../worker/worker_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String uid;
  final String? initialName;
  final String? initialEmail;
  final String? phone;
  final String? role;

  const ProfileSetupScreen({super.key, required this.uid, this.initialName, this.initialEmail, this.phone, this.role});
  @override ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'male';
  String _role = 'customer';
  bool _isLoading = false;

  // Vehicle fields (for customers)
  final _vBrandController = TextEditingController();
  final _vModelController = TextEditingController();
  final _vColorController = TextEditingController();
  final _vPlateController = TextEditingController();
  final _vParkingController = TextEditingController();
  final _vSocietyController = TextEditingController();
  String _vType = 'car';

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) _nameController.text = widget.initialName!;
    if (widget.initialEmail != null) _emailController.text = widget.initialEmail!;
    if (widget.phone != null) _phoneController.text = widget.phone!;
    if (widget.role != null) _role = widget.role!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vBrandController.dispose();
    _vModelController.dispose();
    _vColorController.dispose();
    _vPlateController.dispose();
    _vParkingController.dispose();
    _vSocietyController.dispose();
    super.dispose();
  }

  void _setupProfile() async {
    final phoneText = _phoneController.text.trim();
    if (_nameController.text.trim().isEmpty || phoneText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a valid name and phone number'),
        backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).createUserProfile(
        uid: widget.uid,
        name: _nameController.text.trim(),
        phone: '+91$phoneText'.replaceAll('+91+91', '+91'), // ensure format
        email: _emailController.text.trim(),
        role: _role,
      );

      // Update gender and address
      await ref.read(firestoreServiceProvider).updateUserProfile(widget.uid, {
        'gender': _gender,
        'address': _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      }).timeout(const Duration(seconds: 5));

      // Add vehicle if customer filled it in
      if (_role == 'customer' && _vBrandController.text.trim().isNotEmpty && _vPlateController.text.trim().isNotEmpty) {
        final vehicle = VehicleModel(
          id: const Uuid().v4(),
          ownerId: widget.uid,
          type: _vType,
          brand: _vBrandController.text.trim(),
          model: _vModelController.text.trim(),
          color: _vColorController.text.trim().isNotEmpty ? _vColorController.text.trim() : 'Not specified',
          numberPlate: _vPlateController.text.trim().toUpperCase(),
          parkingSpot: _vParkingController.text.trim().isNotEmpty ? _vParkingController.text.trim() : null,
          societyName: _vSocietyController.text.trim().isNotEmpty ? _vSocietyController.text.trim() : null,
        );
        await ref.read(firestoreServiceProvider).addVehicle(vehicle).timeout(const Duration(seconds: 5));
      }

      // Success!
      // DO NOT navigate manually. When createUserProfile succeeds, the Firestore snapshot
      // listener in currentUserProvider gets fresh data, causing AuthGate to automatically
      // swap this ProfileSetupScreen with the proper Shell (Worker or Customer).
      // If we manually pushed this screen, we pop it.
      if (mounted) {
        if (!ModalRoute.of(context)!.isFirst) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: canPop ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 40),
              Text('Setup Profile', style: AppTextStyles.displaySmall).animate().fadeIn(),
              Text('Let us know about you', style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // Avatar preview + Gender selector
              Center(
                child: Column(children: [
                  UserAvatar(name: _nameController.text.isEmpty ? '?' : _nameController.text, gender: _gender, size: 100)
                      .animate().scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _GenderChip(icon: Icons.male_rounded, label: 'Male', color: const Color(0xFF1565C0),
                      isSelected: _gender == 'male', onTap: () => setState(() => _gender = 'male')),
                    const SizedBox(width: 12),
                    _GenderChip(icon: Icons.female_rounded, label: 'Female', color: const Color(0xFFE91E8C),
                      isSelected: _gender == 'female', onTap: () => setState(() => _gender = 'female')),
                    const SizedBox(width: 12),
                    _GenderChip(icon: Icons.transgender_rounded, label: 'Other', color: const Color(0xFF9C27B0),
                      isSelected: _gender == 'other', onTap: () => setState(() => _gender = 'other')),
                  ]),
                ]),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              // Core Info
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Role Selector
                  if (widget.role == null) ...[
                    Text('I am a...', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _VTypeChip(icon: Icons.person_rounded, label: 'Customer', isSelected: _role == 'customer', onTap: () => setState(() => _role = 'customer'))),
                      const SizedBox(width: 12),
                      Expanded(child: _VTypeChip(icon: Icons.engineering_rounded, label: 'Worker', isSelected: _role == 'worker', onTap: () => setState(() => _role = 'worker'))),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  _buildField(_nameController, 'Full Name *', 'Enter your name', Icons.person_rounded, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),
                  if (widget.phone == null) ...[
                    _buildField(_phoneController, 'Phone Number *', '10-digit number', Icons.phone_rounded, isPhone: true),
                    const SizedBox(height: 16),
                  ],
                  _buildField(_addressController, 'Address', 'Your home/society address', Icons.location_on_rounded),
                ]),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              // Vehicle section (only for customers)
              if (_role == 'customer') ...[
                const SizedBox(height: 28),
                Text('Add Your Vehicle', style: AppTextStyles.headlineSmall).animate().fadeIn(delay: 400.ms),
                Text('Optional — you can add more later', style: AppTextStyles.bodySmall).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: _VTypeChip(icon: Icons.directions_car_rounded, label: 'Car',
                    isSelected: _vType == 'car', onTap: () => setState(() => _vType = 'car'))),
                  const SizedBox(width: 12),
                  Expanded(child: _VTypeChip(icon: Icons.two_wheeler_rounded, label: 'Bike',
                    isSelected: _vType == 'bike', onTap: () => setState(() => _vType = 'bike'))),
                ]).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    _buildField(_vBrandController, 'Brand', 'e.g. Honda, Hyundai', Icons.branding_watermark_rounded),
                    const SizedBox(height: 16),
                    _buildField(_vModelController, 'Model', 'e.g. City, i20', Icons.category_rounded),
                    const SizedBox(height: 16),
                    _buildField(_vColorController, 'Color', 'e.g. White, Black', Icons.palette_rounded),
                    const SizedBox(height: 16),
                    _buildField(_vPlateController, 'Number Plate', 'e.g. MH 12 AB 1234', Icons.pin_rounded),
                    const SizedBox(height: 16),
                    _buildField(_vSocietyController, 'Society / Building', 'Where is it parked?', Icons.apartment_rounded),
                    const SizedBox(height: 16),
                    _buildField(_vParkingController, 'Parking Spot', 'e.g. P-12', Icons.local_parking_rounded),
                  ]),
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
              ],

              const SizedBox(height: 32),

              NeonButton(text: 'Complete Setup', icon: Icons.check_circle_rounded, isLoading: _isLoading, onPressed: _isLoading ? null : _setupProfile)
                  .animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 40),
            ]),
          ),
        ),
    );
  }

  Widget _buildField(TextEditingController c, String label, String hint, IconData icon, {ValueChanged<String>? onChanged, bool isPhone = false}) {
    return TextField(
      controller: c,
      onChanged: onChanged,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
      maxLength: isPhone ? 10 : null,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      textCapitalization: isPhone ? TextCapitalization.none : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label, hintText: hint, counterText: '',
        prefixText: isPhone ? '+91 ' : null,
        prefixStyle: isPhone ? AppTextStyles.bodyLarge.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600) : null,
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true, fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final IconData icon; final String label; final Color color; final bool isSelected; final VoidCallback onTap;
  const _GenderChip({required this.icon, required this.label, required this.color, required this.isSelected, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: isSelected ? color.withValues(alpha: 0.2) : AppColors.glassWhite,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isSelected ? color : AppColors.glassBorder, width: isSelected ? 2 : 1)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: isSelected ? color : AppColors.textTertiary, size: 18),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.bodySmall.copyWith(color: isSelected ? color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
    ])));
}

class _VTypeChip extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final VoidCallback onTap;
  const _VTypeChip({required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: GlassCard(
    borderRadius: 14, opacity: isSelected ? 0.15 : 0.06, borderOpacity: isSelected ? 0.4 : 0.15,
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: isSelected ? AppColors.accent : AppColors.textTertiary, size: 22),
      const SizedBox(width: 8),
      Text(label, style: AppTextStyles.titleMedium.copyWith(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
    ])));
}
