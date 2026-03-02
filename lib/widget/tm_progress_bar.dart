import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Barra di progresso modulare con label e percentuale.
class TmProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;

  const TmProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: backgroundColor ?? AppTheme.borderDark,
        valueColor: AlwaysStoppedAnimation(color ?? AppTheme.primaryColor),
      ),
    );
  }
}
