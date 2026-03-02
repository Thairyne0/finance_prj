import 'package:flutter/material.dart';

/// Wrapper che aggiunge un gradiente di sfumatura in alto e/o in basso
/// al contenuto scrollabile, creando l'effetto di fade-out ai bordi.
class TmFadeScroll extends StatelessWidget {
  const TmFadeScroll({
    super.key,
    required this.child,
    this.fadeTop = true,
    this.fadeBottom = true,
    this.topFadeHeight = 32.0,
    this.bottomFadeHeight = 48.0,
    this.color,
  });

  final Widget child;
  final bool fadeTop;
  final bool fadeBottom;
  final double topFadeHeight;
  final double bottomFadeHeight;

  /// Colore base della sfumatura. Se null, usa lo scaffold background.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        child,
        if (fadeTop)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      baseColor,
                      baseColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        if (fadeBottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomFadeHeight,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      baseColor,
                      baseColor.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }
}

