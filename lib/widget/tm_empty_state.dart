import 'package:flutter/material.dart';

/// Widget modulare per mostrare uno stato vuoto con animazione breathing.
class TmEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;

  const TmEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 56,
  });

  @override
  State<TmEmptyState> createState() => _TmEmptyStateState();
}

class _TmEmptyStateState extends State<TmEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _breathe = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, fadeVal, child) {
          return Opacity(
            opacity: fadeVal,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - fadeVal)),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona con cerchi concentrici e breathing
            AnimatedBuilder(
              animation: _breathe,
              builder: (context, child) {
                final v = _breathe.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cerchio esterno
                    Container(
                      width: widget.iconSize * 2.2,
                      height: widget.iconSize * 2.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.03 + v * 0.02),
                          width: 1,
                        ),
                      ),
                    ),
                    // Cerchio medio
                    Container(
                      width: widget.iconSize * 1.6,
                      height: widget.iconSize * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05 + v * 0.03),
                          width: 1,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.95 + v * 0.1,
                      child: Icon(
                        widget.icon,
                        size: widget.iconSize,
                        color: Colors.white.withValues(alpha: 0.10 + v * 0.08),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF6C7086)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF454A5C)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
