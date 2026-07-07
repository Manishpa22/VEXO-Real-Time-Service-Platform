import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';

class WashHistoryScreen extends StatelessWidget {
  const WashHistoryScreen({super.key});
  @override Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(backgroundColor: colors.background,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: colors.textPrimary), title: Text('wash_history'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary))),
    body: Center(child: Text('history_coming_soon'.tr(), style: TextStyle(color: colors.textSecondary))));
  }
}

class RateCleanerScreen extends StatelessWidget {
  const RateCleanerScreen({super.key});
  @override Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(backgroundColor: colors.background,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: colors.textPrimary), title: Text('rate_cleaner'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary))),
    body: Center(child: Text('ratings_coming_soon'.tr(), style: TextStyle(color: colors.textSecondary))));
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});
  @override Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(backgroundColor: colors.background,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: BackButton(color: colors.textPrimary), title: Text('payment_history'.tr(), style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary))),
    body: Center(child: Text('payments_coming_soon'.tr(), style: TextStyle(color: colors.textSecondary))));
  }
}
