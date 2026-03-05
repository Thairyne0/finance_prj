import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Notifica overlay premium che appare dall'alto con animazione slide+fade.
/// Sostituisce le SnackBar di default per un look più moderno.
class TmTopNotification {
  TmTopNotification._();

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Color? iconColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _AnimatedNotification(
        message: message,
        icon: icon,
        iconColor: iconColor ?? AppTheme.incomeColor,
        backgroundColor: backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppTheme.card(context)
                : AppTheme.cardLight),
        duration: duration,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  /// Notifica di successo (verde)
  static void success(BuildContext context, String message) {
    show(context, message: message, icon: Icons.check_circle_rounded, iconColor: AppTheme.incomeColor);
  }

  /// Notifica di errore (rosso)
  static void error(BuildContext context, String message) {
    show(context, message: message, icon: Icons.error_outline_rounded, iconColor: AppTheme.expenseColor);
  }

  /// Notifica di avviso (giallo)
  static void warning(BuildContext context, String message) {
    show(context, message: message, icon: Icons.warning_amber_rounded, iconColor: AppTheme.warningColor);
  }

  /// Notifica informativa
  static void info(BuildContext context, String message) {
    show(context, message: message, icon: Icons.info_outline_rounded, iconColor: AppTheme.primaryColor);
  }
}

// ─── Widget animato interno che gestisce il proprio TickerProvider ───

class _AnimatedNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDone;

  const _AnimatedNotification({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < -100) _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(Icons.close_rounded, color: Colors.white24, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
