import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Progress bar Marathon — barra neon con glow e sfondo incassato.
class TmProgressBar extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final Gradient? gradient;
  final Duration duration;

  const TmProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 6,
    this.borderRadius = 2,
    this.gradient,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<TmProgressBar> createState() => _TmProgressBarState();
}

class _TmProgressBarState extends State<TmProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  double _prevValue = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _progress = Tween<double>(begin: 0, end: widget.value.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(TmProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _prevValue = _progress.value;
      _progress = Tween<double>(
        begin: _prevValue,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppTheme.primaryColor;
    final bg = widget.backgroundColor ?? AppTheme.borderDark;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress.value,
            child: Container(
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8),
                  BoxShadow(
                      color: c.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: -4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
