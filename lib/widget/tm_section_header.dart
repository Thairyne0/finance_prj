import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Section header Marathon — titolo uppercase con linea rossa e action.
class TmSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TmSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Linea d'accento rossa
        Container(width: 3, height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.2), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1.5, fontSize: 16),
        )),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(actionLabel!.toUpperCase(),
                style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w600,
                  fontSize: 11, letterSpacing: 0.8)),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.secondaryColor),
            ]),
          ),
      ],
    );
  }
}
