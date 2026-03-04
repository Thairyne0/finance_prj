import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

/// Chip riassuntivo Marathon HUD — bordo luminoso, angoli duri, glow neon.
class TmSummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool compact;

  const TmSummaryChip({
    super.key, required this.label, required this.amount,
    required this.color, required this.icon, this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.4), width: 0.5),
          left: BorderSide(color: color.withValues(alpha: 0.12), width: 0.5),
          right: BorderSide(color: color.withValues(alpha: 0.12), width: 0.5),
          bottom: BorderSide(color: color.withValues(alpha: 0.04), width: 0.5),
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, spreadRadius: -4)],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(label.toUpperCase(),
          style: TextStyle(color: AppTheme.textTertiary, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        FittedBox(fit: BoxFit.scaleDown, child: Text(
          compact ? Formatters.formatCompact(amount) : Formatters.formatCurrency(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14,
            shadows: [Shadow(color: color.withValues(alpha: 0.3), blurRadius: 6)]),
        )),
      ]),
    );
  }
}
