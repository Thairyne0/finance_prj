import 'package:flutter/material.dart';

/// Icona circolare/arrotondata con sfondo colorato, usata per categorie, obiettivi etc.
class TmIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final double opacity;

  const TmIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = 14,
    this.opacity = 0.15,
  });

  /// Crea da un codice icona (es. da Hive/model)
  factory TmIconBadge.fromCodePoint({
    Key? key,
    required int iconCodePoint,
    required int colorValue,
    double size = 44,
    double iconSize = 22,
    double borderRadius = 14,
    double opacity = 0.15,
  }) {
    return TmIconBadge(
      key: key,
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      size: size,
      iconSize: iconSize,
      borderRadius: borderRadius,
      opacity: opacity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}


