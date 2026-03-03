import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../widget/tm_widgets.dart';

/// Card riepilogativa totale obiettivi di risparmio
class SavingsSummaryCard extends ConsumerWidget {
  const SavingsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(allSavingsProvider);
    if (goals.isEmpty) return const SizedBox.shrink();

    final total = goals.fold<double>(0, (s, g) => s + g.targetAmount);
    final saved = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    final completed = goals.where((g) => g.isCompleted).length;
    final overallProgress = total > 0 ? (saved / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riepilogo Risparmi',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (completed > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.incomeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completed completati',
                    style: const TextStyle(
                      color: AppTheme.incomeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Risparmiato',
                  value: Formatters.formatCurrency(saved),
                  color: AppTheme.incomeColor,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Target totale',
                  value: Formatters.formatCurrency(total),
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Rimanente',
                  value: Formatters.formatCurrency((total - saved).clamp(0, total)),
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TmProgressBar(
            value: overallProgress,
            color: AppTheme.incomeColor,
            height: 8,
            borderRadius: 6,
          ),
          const SizedBox(height: 8),
          Text(
            '${(overallProgress * 100).toStringAsFixed(1)}% del totale risparmiato',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

