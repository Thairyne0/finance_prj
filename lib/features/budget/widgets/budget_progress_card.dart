import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../widget/tm_widgets.dart';

class BudgetProgressCard extends StatelessWidget {
  final String categoryName;
  final int iconCodePoint;
  final int colorValue;
  final double budgetLimit;
  final double spent;
  final VoidCallback onDelete;

  const BudgetProgressCard({
    super.key,
    required this.categoryName,
    required this.iconCodePoint,
    required this.colorValue,
    required this.budgetLimit,
    required this.spent,
    required this.onDelete,
  });

  double get percent => budgetLimit > 0 ? spent / budgetLimit : 0;
  bool get isOver => spent > budgetLimit;
  double get remaining => budgetLimit - spent;

  Color get progressColor {
    if (percent > 1.0) return AppTheme.expenseColor;
    if (percent > 0.8) return AppTheme.warningColor;
    return AppTheme.incomeColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$categoryName-budget'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expenseColor),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isOver
                ? AppTheme.expenseColor.withValues(alpha: 0.4)
                : AppTheme.borderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TmIconBadge.fromCodePoint(
                  iconCodePoint: iconCodePoint,
                  colorValue: colorValue,
                  size: 40,
                  iconSize: 20,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        isOver
                            ? 'Superato di ${Formatters.formatCurrency(spent - budgetLimit)}'
                            : 'Rimangono ${Formatters.formatCurrency(remaining)}',
                        style: TextStyle(
                          color: isOver
                              ? AppTheme.expenseColor
                              : AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            TmProgressBar(
              value: percent,
              color: progressColor,
              height: 8,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatCurrency(spent),
                  style: TextStyle(color: progressColor, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  Formatters.formatCurrency(budgetLimit),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

