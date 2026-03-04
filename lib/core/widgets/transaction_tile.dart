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
  final int? animationIndex;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
    this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    final category  = HiveService.getCategoryById(transaction.categoryId);
    final isExpense = transaction.type == TransactionType.expense;
    final color     = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final sign      = isExpense ? '-' : '+';
    final catColor  = Color(category.colorValue);

    final bool hasProduct = transaction.productName != null &&
        transaction.productName!.isNotEmpty;

    Widget tile = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            top: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5), width: 0.5),
            left: BorderSide(color: catColor.withValues(alpha: 0.5), width: 2),
            right: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.2), width: 0.5),
            bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.2), width: 0.5),
          ),
          boxShadow: AppTheme.realisticShadow(elevation: 0.3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TmIconBadge.fromCodePoint(
                iconCodePoint: category.iconCodePoint,
                colorValue: category.colorValue,
                size: 40, iconSize: 18, enableGlow: true,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (transaction.description.isNotEmpty
                          ? transaction.description : category.name).toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 12.5,
                        color: AppTheme.textPrimary, height: 1.2, letterSpacing: 0.5,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasProduct ? '${category.name} · ${transaction.productName!}' : category.name,
                      style: TextStyle(color: AppTheme.textTertiary, fontSize: 10.5, height: 1.2),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(
                        IconData(transaction.paymentIconCodePoint, fontFamily: 'MaterialIcons'),
                        size: 10,
                        color: transaction.paymentMethod == PaymentMethod.cash
                            ? AppTheme.warningColor.withValues(alpha: 0.6)
                            : AppTheme.secondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 3),
                      Flexible(child: Text(
                        '${transaction.paymentLabel}  ·  ${Formatters.formatDate(transaction.date)}',
                        style: TextStyle(
                          color: transaction.paymentMethod == PaymentMethod.cash
                              ? AppTheme.warningColor.withValues(alpha: 0.5)
                              : AppTheme.secondaryColor.withValues(alpha: 0.4),
                          fontSize: 10, fontWeight: FontWeight.w500, height: 1.2,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 85),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$sign${Formatters.formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 14,
                      shadows: [Shadow(color: color.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (animationIndex != null) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (animationIndex! * 35).clamp(0, 250)),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Opacity(
            opacity: val,
            child: Transform.translate(offset: Offset(20 * (1 - val), 0), child: child),
          );
        },
        child: tile,
      );
    }

    if (onDismissed != null) {
      tile = Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.expenseColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.delete_outline, color: AppTheme.expenseColor),
        ),
        child: tile,
      );
    }
    return tile;
  }
}

