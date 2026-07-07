import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';

class BookWashScreen extends ConsumerWidget {
  const BookWashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: Text('book_a_wash'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary)),
      ),
      body: Center(
        child: Text('booking_coming_soon'.tr(), style: TextStyle(color: colors.textSecondary)),
      ),
    );
  }
}

class ViewScheduleScreen extends ConsumerWidget {
  const ViewScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: Text('my_schedule'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary)),
      ),
      body: Center(
        child: Text('schedule_coming_soon'.tr(), style: TextStyle(color: colors.textSecondary)),
      ),
    );
  }
}
