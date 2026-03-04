import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

/// Month selector Marathon HUD con angoli duri e bordo neon.
class TmMonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const TmMonthSelector({
    super.key,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          top: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.2), width: 0.5),
          left: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5), width: 0.5),
          right: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.5), width: 0.5),
          bottom: BorderSide(color: AppTheme.borderDark.withValues(alpha: 0.2), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ArrowBtn(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: Text(
              Formatters.formatMonthYear(selectedDate).toUpperCase(),
              key: ValueKey(selectedDate.month * 100 + selectedDate.year),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, letterSpacing: 1.5,
              ),
            ),
          ),
          _ArrowBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
      ),
    );
  }
}
