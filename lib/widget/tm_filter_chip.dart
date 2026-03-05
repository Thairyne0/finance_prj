import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Chip/filtro modulare con stile animato, glow quando selezionato e micro-interazione.
class TmFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const TmFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgDefault = isDark ? AppTheme.card(context) : AppTheme.cardLightAlt;
    final borderDefault = isDark ? AppTheme.border(context) : AppTheme.borderLight;
    final textDefault = isDark ? Colors.white54 : AppTheme.textLightTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : bgDefault,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? chipColor.withValues(alpha: 0.5) : borderDefault,
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            color: isSelected ? chipColor : textDefault,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
