import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/hive_service.dart';

/// Banner che mostra alert quando uno o più budget superano l'80%
class BudgetAlertBanner extends ConsumerWidget {
  const BudgetAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(budgetAlertsProvider);

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) {
        final cat = HiveService.getCategoryById(alert.categoryId);
        final isOver = alert.isOver;
        final color = isOver ? AppTheme.expenseColor : AppTheme.warningColor;
        final percentStr = '${(alert.percent * 100).toStringAsFixed(0)}%';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isOver
                      ? Icons.warning_rounded
                      : Icons.notification_important_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOver
                          ? 'Budget superato – ${cat.name}'
                          : 'Quasi al limite – ${cat.name}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOver
                          ? 'Hai superato il budget ($percentStr)'
                          : 'Hai usato $percentStr del budget',
                      style: TextStyle(
                        color: AppTheme.textTertiary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                percentStr,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
