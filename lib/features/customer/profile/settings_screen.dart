import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'profile_features_screens.dart'; // For AboutVexoScreen

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);

    final items = [
      _SettingsItem(Icons.dark_mode_rounded, 'appearance'.tr(), const Color(0xFF8B5CF6), () {
        _showThemeBottomSheet(context, ref);
      }),
      _SettingsItem(Icons.language_rounded, 'language'.tr(), Colors.blueAccent, () {
        _showLanguageBottomSheet(context, ref);
      }),
      _SettingsItem(Icons.notifications_rounded, 'notifications'.tr(), AppColors.warning, () {}),
      _SettingsItem(Icons.help_outline_rounded, 'help_support'.tr(), AppColors.info, () {}),
      _SettingsItem(Icons.info_outline_rounded, 'about_vexo'.tr(), AppColors.textSecondary, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutVexoScreen()));
      }),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('settings'.tr(), style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            ...items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 16,
                onTap: e.value.onTap,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: e.value.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(e.value.icon, color: e.value.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(e.value.label, style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary,
                    )),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.textTertiary),
                ]),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 + e.key * 60)).slideX(begin: 0.05)),
          ],
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Consumer(builder: (ctx, ref, _) {
          final currentMode = ref.watch(themeModeProvider);
          final sheetColors = AppColors.of(ctx);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: sheetColors.textTertiary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('appearance'.tr(), style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: sheetColors.textPrimary,
                  )),
                  const SizedBox(height: 8),
                  Text('Choose how Vexo looks for you.', style: TextStyle(
                    fontSize: 14, color: sheetColors.textSecondary,
                  )),
                  const SizedBox(height: 24),
                  
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    title: 'system_default'.tr(),
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                      Navigator.pop(ctx);
                    },
                    colors: sheetColors,
                  ),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    title: 'light_mode'.tr(),
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                      Navigator.pop(ctx);
                    },
                    colors: sheetColors,
                  ),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    title: 'dark_mode'.tr(),
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                      Navigator.pop(ctx);
                    },
                    colors: sheetColors,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final currentLocale = context.locale;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('language'.tr(), style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: colors.textPrimary,
                )),
                const SizedBox(height: 8),
                Text('Choose your preferred language.', style: TextStyle(
                  fontSize: 14, color: colors.textSecondary,
                )),
                const SizedBox(height: 24),
                
                _ThemeOption(
                  icon: Icons.language_rounded,
                  title: 'English',
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () {
                    context.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.language_rounded,
                  title: 'हिंदी (Hindi)',
                  isSelected: currentLocale.languageCode == 'hi',
                  onTap: () {
                    context.setLocale(const Locale('hi'));
                    Navigator.pop(ctx);
                  },
                  colors: colors,
                ),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.language_rounded,
                  title: 'मराठी (Marathi)',
                  isSelected: currentLocale.languageCode == 'mr',
                  onTap: () {
                    context.setLocale(const Locale('mr'));
                    Navigator.pop(ctx);
                  },
                  colors: colors,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _SettingsItem(this.icon, this.label, this.color, this.onTap);
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final AdaptiveColors colors;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : colors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accent : colors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(
                fontSize: 16, 
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              )),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
