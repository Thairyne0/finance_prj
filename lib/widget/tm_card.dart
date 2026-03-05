import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Card container modulare con stile dark theme, glassmorphism opzionale e glow.
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

  const TmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 20,
    this.gradient,
    this.onTap,
    this.enableGlass = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(borderRadius);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppTheme.card(context) : AppTheme.cardLight;
    final defaultBorder = isDark ? AppTheme.border(context) : AppTheme.borderLight;

    final decoration = BoxDecoration(
      color: gradient == null
          ? (enableGlass
              ? AppTheme.surfaceGlass
              : (backgroundColor ?? defaultBg))
          : null,
      gradient: gradient,
      borderRadius: br,
      border: Border.all(
        color: enableGlass
            ? AppTheme.borderGlass
            : (borderColor ?? defaultBorder),
        width: enableGlass ? 0.8 : 1,
      ),
      boxShadow: glowColor != null ? AppTheme.glowShadow(glowColor!) : null,
    );

    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    // Glassmorphism: wrap con backdrop blur
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
      return _TapScaleWrapper(onTap: onTap!, borderRadius: br, child: content);
    }
    return content;
  }
}

/// Micro-interazione: leggero scale-down al tap
class _TapScaleWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Widget child;

  const _TapScaleWrapper({
    required this.onTap,
    required this.borderRadius,
    required this.child,
  });

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
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
