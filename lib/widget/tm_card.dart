import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Pannello HUD Marathon-style con bordo luminoso top, ombre dure, angoli tagliati.
class TmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool enableGlass;
  final Color? glowColor;
  final double elevation;

  const TmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 4,
    this.gradient,
    this.onTap,
    this.enableGlass = false,
    this.glowColor,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(borderRadius);
    final accent = glowColor ?? AppTheme.primaryColor;
    final bgColor = enableGlass ? AppTheme.surfaceGlass : (backgroundColor ?? AppTheme.cardDark);

    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: br,
        border: Border(
          top: BorderSide(
            color: (borderColor ?? accent).withValues(alpha: glowColor != null ? 0.5 : 0.2),
            width: 1,
          ),
          left: BorderSide(
            color: (borderColor ?? AppTheme.borderDark).withValues(alpha: 0.4),
            width: 0.5,
          ),
          right: BorderSide(
            color: (borderColor ?? AppTheme.borderDark).withValues(alpha: 0.4),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: (borderColor ?? AppTheme.borderDark).withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          ...AppTheme.realisticShadow(elevation: elevation),
          if (glowColor != null) ...AppTheme.neonGlow(glowColor!, intensity: 0.15),
        ],
      ),
      child: child,
    );

    if (enableGlass) {
      content = ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      return _TapScaleWrapper(onTap: onTap!, child: content);
    }
    return content;
  }
}

class _TapScaleWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TapScaleWrapper({required this.onTap, required this.child});

  @override
  State<_TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<_TapScaleWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut, reverseCurve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
