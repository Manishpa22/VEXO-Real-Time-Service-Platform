import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/subscription_model.dart';
import '../../auth/profile_setup_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});
  @override ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _selectedVehicleType = 'car';
  String? _selectedPlanType;

  late final _allPlans = [
    _PlanData(name: 'plan_bike_name'.tr(), type: 'bike', price: 399, period: '28 days', vehicleType: 'bike', icon: Icons.two_wheeler_rounded, gradient: LinearGradient(colors: [AppColors.accentSecondary, AppColors.accent]), imagePath: 'assets/images/bike.png',
      features: ['plan_bike_feat1'.tr(), 'plan_bike_feat2'.tr(), 'plan_bike_feat3'.tr(), 'plan_bike_feat4'.tr()]),
    _PlanData(name: 'plan_vexogo_name'.tr(), type: 'vexo_go', price: 799, period: '28 days', vehicleType: 'car', icon: Icons.directions_car_rounded, gradient: AppColors.primaryGradient, imagePath: 'assets/images/vexo_go_car.png',
      features: ['plan_vexogo_feat1'.tr(), 'plan_vexogo_feat2'.tr(), 'plan_vexogo_feat3'.tr(), 'plan_vexogo_feat4'.tr(), 'plan_vexogo_feat5'.tr()]),
    _PlanData(name: 'plan_vexopremium_name'.tr(), type: 'vexo_premium', price: 999, period: '28 days', vehicleType: 'car', icon: Icons.star_rounded, gradient: AppColors.warmGradient, isPopular: true, imagePath: 'assets/images/vexo_per_car.png',
      features: ['plan_vexopremium_feat1'.tr(), 'plan_vexopremium_feat2'.tr(), 'plan_vexopremium_feat3'.tr(), 'plan_vexopremium_feat4'.tr(), 'plan_vexopremium_feat5'.tr(), 'plan_vexopremium_feat6'.tr()]),
    _PlanData(name: 'plan_yearlyno_name'.tr(), type: 'yearly_no_ceramic', price: 10000, period: 'year', vehicleType: 'car', icon: Icons.workspace_premium_rounded, gradient: AppColors.secondaryGradient, imagePath: 'assets/images/vexo_yerar_car.png',
      features: ['plan_yearlyno_feat1'.tr(), 'plan_yearlyno_feat2'.tr(), 'plan_yearlyno_feat3'.tr(), 'plan_yearlyno_feat4'.tr(), 'plan_yearlyno_feat5'.tr(), 'plan_yearlyno_feat6'.tr()]),
    _PlanData(name: 'plan_yearlyce_name'.tr(), type: 'yearly_ceramic', price: 12000, period: 'year', vehicleType: 'car', icon: Icons.workspace_premium_rounded, gradient: AppColors.secondaryGradient, imagePath: 'assets/images/vexo_yerar_car.png',
      features: ['plan_yearlyce_feat1'.tr(), 'plan_yearlyce_feat2'.tr(), 'plan_yearlyce_feat3'.tr(), 'plan_yearlyce_feat4'.tr(), 'plan_yearlyce_feat5'.tr(), 'plan_yearlyce_feat6'.tr(), 'plan_yearlyce_feat7'.tr()]),
  ];

  void _subscribe() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (!user.isProfileComplete) {
      _showCompleteProfileDialog(user.uid, user.name, user.email, user.phone, user.role);
      return;
    }

    final displayPlans = _allPlans.where((p) => p.vehicleType == _selectedVehicleType).toList();
    if (_selectedPlanType == null || !displayPlans.any((p) => p.type == _selectedPlanType)) {
      _selectedPlanType = displayPlans.first.type;
    }
    
    final plan = _allPlans.firstWhere((p) => p.type == _selectedPlanType);
    final sub = SubscriptionModel(
      id: const Uuid().v4(), userId: user.uid, planName: plan.name, planType: plan.type,
      price: plan.price.toDouble(), vehicleType: plan.vehicleType,
      startDate: DateTime.now(),
      endDate: plan.period == 'year' ? DateTime.now().add(const Duration(days: 365)) : DateTime.now().add(const Duration(days: 28)),
      isActive: true, features: plan.features,
    );

    try {
      await ref.read(firestoreServiceProvider).createSubscription(sub);
      if (mounted) {
        _showSubscriptionSuccessDialog(plan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showSubscriptionSuccessDialog(_PlanData plan) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription Success',
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
                          width: 85, height: 85,
                          decoration: BoxDecoration(
                            gradient: plan.gradient as LinearGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (plan.gradient as LinearGradient).colors.first.withValues(alpha: 0.4),
                                blurRadius: 25, spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 44),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Successfully Subscribed!', style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: plan.gradient as LinearGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${plan.price}/${plan.period}',
                    style: AppTextStyles.headlineSmall.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.period == 'year' ? 'Valid for 365 days' : 'Valid for 28 days',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: (plan.gradient as LinearGradient).colors.first,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Awesome!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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

  void _showCompleteProfileDialog(String uid, String name, String email, String phone, String role) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Complete Profile',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: AppColors.of(context).cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.warning, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text('profile_incomplete'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'please_complete_profile'.tr(),
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: NeonButton(
                      text: 'complete_setup'.tr(),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ProfileSetupScreen(
                            uid: uid,
                            initialName: name,
                            initialEmail: email,
                            phone: phone.isEmpty ? null : phone,
                            role: role,
                          )
                        ));
                      },
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
    final displayPlans = _allPlans.where((p) => p.vehicleType == _selectedVehicleType).toList();
    if (_selectedPlanType == null || !displayPlans.any((p) => p.type == _selectedPlanType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedPlanType = displayPlans.first.type);
      });
    }

    final selectedPlan = _allPlans.firstWhere((p) => p.type == _selectedPlanType, orElse: () => displayPlans.first);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Text('choose_plan'.tr(), style: AppTextStyles.displaySmall).animate().fadeIn(duration: 400.ms),
          Text('select_perfect_plan'.tr(), style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          
          // Segmented Control
          Container(
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedVehicleType = 'bike'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _selectedVehicleType == 'bike' ? const Color(0xFF1A1A2E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      alignment: Alignment.center,
                      child: Text('Bike Plans', style: TextStyle(
                        color: _selectedVehicleType == 'bike' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedVehicleType = 'car'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _selectedVehicleType == 'car' ? const Color(0xFF1A1A2E) : Colors.transparent,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      alignment: Alignment.center,
                      child: Text('Car Plans', style: TextStyle(
                        color: _selectedVehicleType == 'car' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ...List.generate(displayPlans.length, (i) {
            final plan = displayPlans[i];
            final isSelected = _selectedPlanType == plan.type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16), 
              child: _PlanCard(
                data: plan, 
                isSelected: isSelected, 
                onTap: () => setState(() => _selectedPlanType = plan.type)
              )
            ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 100)).slideY(begin: 0.1, curve: Curves.easeOutCubic);
          }),
          const SizedBox(height: 16),
          NeonButton(
            text: 'subscribe_now_price'.tr(args: [selectedPlan.price.toString()]), 
            icon: Icons.check_circle_rounded,
            gradient: (selectedPlan.gradient as LinearGradient), 
            onPressed: _subscribe
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }
}

class _PlanData {
  final String name, type; final int price; final String period, vehicleType; final IconData icon; final Gradient gradient; final List<String> features; final bool isPopular;
  final String imagePath;
  const _PlanData({required this.name, required this.type, required this.price, required this.period, required this.vehicleType, required this.icon, required this.gradient, required this.features, this.isPopular = false, required this.imagePath});
}

class _PlanCard extends StatelessWidget {
  final _PlanData data; final bool isSelected; final VoidCallback onTap;
  const _PlanCard({required this.data, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeColor = (data.gradient as LinearGradient).colors.first;
    
    return GestureDetector(
      onTap: onTap, 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? themeColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: themeColor.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8))
          ] : [],
        ),
        child: Stack(
          clipBehavior: Clip.none, 
          children: [
            Row(
              children: [
                // Left Side (60%)
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.name, style: AppTextStyles.titleMedium.copyWith(color: isSelected ? themeColor : const Color(0xFF1A1A2E), fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${data.price}', style: AppTextStyles.displaySmall.copyWith(fontSize: 26, color: const Color(0xFF1A1A2E))),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text('/${data.period == 'year' ? 'year_period'.tr() : 'days_28_period'.tr()}', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...data.features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8), 
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(2), 
                                decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, color: themeColor, size: 12)
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(f, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87, fontSize: 13))),
                            ]
                          )
                        )),
                      ],
                    ),
                  ),
                ),
                // Right Side (40%)
                Expanded(
                  flex: 4,
                  child: const SizedBox(height: 180), // Reserve space
                ),
              ],
            ),
            
            // 3D Image Overlapping
            Positioned(
              right: -30,
              bottom: 10,
              top: 10,
              child: Image.asset(
                data.imagePath,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),

            // Most Popular Badge
            if (data.isPopular) Positioned(
              top: 0, 
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E), 
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16))
                ),
                child: Text('MOST POPULAR', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 10))
              )
            ),
          ]
        )
      )
    );
  }
}
