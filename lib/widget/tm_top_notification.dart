import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Notifica overlay Marathon HUD — pannello con bordo neon top e glow.
class TmTopNotification {
  TmTopNotification._();

  static void show(BuildContext context, {
    required String message, IconData icon = Icons.check_circle_rounded,
    Color? iconColor, Color? backgroundColor, Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(builder: (ctx) => _AnimatedNotification(
      message: message, icon: icon, iconColor: iconColor ?? AppTheme.incomeColor,
      backgroundColor: backgroundColor ?? AppTheme.cardDark, duration: duration,
      onDone: () => entry.remove(),
    ));
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
    show(context, message: message, icon: Icons.check_circle_rounded, iconColor: AppTheme.incomeColor);
  static void error(BuildContext context, String message) =>
    show(context, message: message, icon: Icons.error_outline_rounded, iconColor: AppTheme.expenseColor);
  static void warning(BuildContext context, String message) =>
    show(context, message: message, icon: Icons.warning_amber_rounded, iconColor: AppTheme.warningColor);
  static void info(BuildContext context, String message) =>
    show(context, message: message, icon: Icons.info_outline_rounded, iconColor: AppTheme.secondaryColor);
}

class _AnimatedNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDone;

  const _AnimatedNotification({
    required this.message, required this.icon, required this.iconColor,
    required this.backgroundColor, required this.duration, required this.onDone,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _ctrl.reverse().then((_) { if (mounted) widget.onDone(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: top + 8, left: 16, right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (d) { if (d.velocity.pixelsPerSecond.dy < -100) _dismiss(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    top: BorderSide(color: widget.iconColor.withValues(alpha: 0.5), width: 1),
                    left: BorderSide(color: widget.iconColor.withValues(alpha: 0.15), width: 0.5),
                    right: BorderSide(color: widget.iconColor.withValues(alpha: 0.15), width: 0.5),
                    bottom: BorderSide(color: widget.iconColor.withValues(alpha: 0.05), width: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6)),
                    BoxShadow(color: widget.iconColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border(top: BorderSide(color: widget.iconColor.withValues(alpha: 0.3), width: 0.5)),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.message,
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _dismiss,
                    child: Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 16)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
