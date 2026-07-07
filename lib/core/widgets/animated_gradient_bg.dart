import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBg({super.key, required this.child});

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with TickerProviderStateMixin {
  late AnimationController _orbController1;
  late AnimationController _orbController2;
  late AnimationController _orbController3;

  @override
  void initState() {
    super.initState();
    _orbController1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _orbController2 = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    _orbController3 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _orbController1.dispose();
    _orbController2.dispose();
    _orbController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.darkGradient,
      ),
      child: Stack(
        children: [
          // Floating orb 1 - cyan
          AnimatedBuilder(
            animation: _orbController1,
            builder: (context, child) {
              final value = _orbController1.value * 2 * math.pi;
              return Positioned(
                top: 100 + math.sin(value) * 80,
                right: -50 + math.cos(value) * 60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.3),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Floating orb 2 - purple
          AnimatedBuilder(
            animation: _orbController2,
            builder: (context, child) {
              final value = _orbController2.value * 2 * math.pi;
              return Positioned(
                bottom: 200 + math.cos(value) * 100,
                left: -80 + math.sin(value) * 60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentSecondary.withValues(alpha: 0.25),
                        AppColors.accentSecondary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Floating orb 3 - green
          AnimatedBuilder(
            animation: _orbController3,
            builder: (context, child) {
              final value = _orbController3.value * 2 * math.pi;
              return Positioned(
                top: 400 + math.sin(value + 1) * 60,
                right: 50 + math.cos(value + 1) * 80,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentTertiary.withValues(alpha: 0.2),
                        AppColors.accentTertiary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Main content
          widget.child,
        ],
      ),
    );
  }
}
