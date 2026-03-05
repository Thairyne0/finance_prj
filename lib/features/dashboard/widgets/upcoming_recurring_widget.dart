import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';

/// Widget dashboard che mostra le prossime transazioni ricorrenti
class UpcomingRecurringWidget extends ConsumerWidget {
  const UpcomingRecurringWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingRecurringProvider);
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmSectionHeader(
          title: '📅 Prossime Scadenze',
          actionLabel: 'Gestisci',
          onAction: () => context.push('/recurring'),
        ),
        const SizedBox(height: 10),
        ...upcoming.map((item) {
          final r = item.recurring;
          final days = item.daysUntil;
          final cat = HiveService.getCategoryById(r.categoryId);
          final isExpense = r.type == 1;
          final amountColor = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;

          // Urgenza
          final Color urgencyColor;
          final String urgencyLabel;
          if (days == 0) {
            urgencyColor = AppTheme.expenseColor;
            urgencyLabel = 'Oggi';
          } else if (days == 1) {
            urgencyColor = AppTheme.warningColor;
            urgencyLabel = 'Domani';
          } else if (days <= 3) {
            urgencyColor = AppTheme.warningColor;
            urgencyLabel = 'Tra $days gg';
          } else {
            urgencyColor = AppTheme.textMutedC(context);
            urgencyLabel = 'Tra $days gg';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Row(
              children: [
                // Icona categoria
                TmIconBadge.fromCodePoint(
                  iconCodePoint: cat.iconCodePoint,
                  colorValue: cat.colorValue,
                  size: 38,
                  iconSize: 17,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.description.isNotEmpty ? r.description : cat.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              urgencyLabel,
                              style: TextStyle(
                                color: urgencyColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'il ${r.dayOfMonth} del mese',
                            style: TextStyle(
                              color: AppTheme.textMutedC(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Importo
                Text(
                  '${isExpense ? '-' : '+'}${Formatters.formatCurrency(r.amount)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

