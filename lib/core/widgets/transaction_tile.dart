import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/hive_service.dart';
import '../../widget/tm_widgets.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final category = HiveService.getCategoryById(transaction.categoryId);
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final sign = isExpense ? '-' : '+';

    Widget tile = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark, width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: TmIconBadge.fromCodePoint(
          iconCodePoint: category.iconCodePoint,
          colorValue: category.colorValue,
          size: 48,
          iconSize: 22,
        ),
        title: Text(
          transaction.description.isNotEmpty
              ? transaction.description
              : category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (transaction.productName != null &&
                    transaction.productName!.isNotEmpty) ...[
                  Text(' • ',
                      style: Theme.of(context).textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      transaction.productName!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.secondaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  IconData(transaction.paymentIconCodePoint,
                      fontFamily: 'MaterialIcons'),
                  size: 12,
                  color: transaction.paymentMethod == PaymentMethod.cash
                      ? AppTheme.warningColor.withValues(alpha: 0.7)
                      : AppTheme.primaryColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  transaction.paymentLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: transaction.paymentMethod == PaymentMethod.cash
                            ? AppTheme.warningColor.withValues(alpha: 0.7)
                            : AppTheme.primaryColor.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '  •  ${Formatters.formatDate(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '$sign${Formatters.formatCurrency(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );

    if (onDismissed != null) {
      tile = Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.expenseColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppTheme.expenseColor),
        ),
        child: tile,
      );
    }

    return tile;
  }
}

