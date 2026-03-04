import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../widget/tm_widgets.dart';

class BalanceCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String period;

  const BalanceCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.period,
  });

  double get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.primaryColor.withValues(alpha: 0.4),
            AppTheme.cardDarkAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bilancio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(balance),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceDetail(
                  label: 'Entrate',
                  amount: totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppTheme.incomeColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BalanceDetail(
                  label: 'Uscite',
                  amount: totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppTheme.expenseColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceDetail extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _BalanceDetail({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          TmIconBadge(
            icon: icon,
            color: color,
            size: 32,
            iconSize: 16,
            borderRadius: 10,
            opacity: 0.2,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Formatters.formatCurrency(amount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

