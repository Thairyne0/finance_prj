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
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border(context), width: 0.8),
        ),
        child: Row(
          children: [
            // ── Linea accento laterale ────────────────────────────────
            Container(
              width: 3,
              height: 52,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ── Contenuto principale ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icona categoria con glow
                    TmIconBadge.fromCodePoint(
                      iconCodePoint: category.iconCodePoint,
                      colorValue: category.colorValue,
                      size: 42,
                      iconSize: 19,
                      enableGlow: true,
                    ),
                    const SizedBox(width: 10),

                    // Testo centrale
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            transaction.description.isNotEmpty
                                ? transaction.description
                                : category.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  hasProduct
                                      ? '${category.name} · ${transaction.productName!}'
                                      : category.name,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textMutedC(context),
                                        fontSize: 11,
                                        height: 1.2,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                IconData(
                                  transaction.paymentIconCodePoint,
                                  fontFamily: 'MaterialIcons',
                                ),
                                size: 11,
                                color: transaction.paymentMethod == PaymentMethod.cash
                                    ? AppTheme.warningColor.withValues(alpha: 0.65)
                                    : AppTheme.primaryColor.withValues(alpha: 0.65),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${transaction.paymentLabel}  ·  ${Formatters.formatDate(transaction.date)}',
                                  style: TextStyle(
                                    color: transaction.paymentMethod == PaymentMethod.cash
                                        ? AppTheme.warningColor.withValues(alpha: 0.65)
                                        : AppTheme.primaryColor.withValues(alpha: 0.65),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Importo con colore
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 85),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$sign${Formatters.formatCurrency(transaction.amount)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Animazione staggered opzionale
    if (animationIndex != null) {
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 350 + (animationIndex! * 40).clamp(0, 300)),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(30 * (1 - val), 0),
              child: child,
            ),
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
            color: AppTheme.expenseColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: AppTheme.expenseColor,
          ),
        ),
        child: tile,
      );
    }

    return tile;
  }
}

