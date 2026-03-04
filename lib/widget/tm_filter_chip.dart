import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Filter chip Marathon-style con bordo neon quando selezionato.
class TmFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const TmFilterChip({
    super.key, required this.label, required this.isSelected,
    this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? c.withValues(alpha: 0.1) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            top: BorderSide(
              color: isSelected ? c.withValues(alpha: 0.5) : AppTheme.borderDark,
              width: isSelected ? 1 : 0.5,
            ),
            left: BorderSide(color: (isSelected ? c : AppTheme.borderDark).withValues(alpha: 0.3), width: 0.5),
            right: BorderSide(color: (isSelected ? c : AppTheme.borderDark).withValues(alpha: 0.3), width: 0.5),
            bottom: BorderSide(color: (isSelected ? c : AppTheme.borderDark).withValues(alpha: 0.15), width: 0.5),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: c.withValues(alpha: 0.12), blurRadius: 10, spreadRadius: -3)]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isSelected ? c : AppTheme.textTertiary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 12, letterSpacing: 0.5,
          ),
          child: Text(label.toUpperCase()),
        ),
      ),
    );
  }
}
