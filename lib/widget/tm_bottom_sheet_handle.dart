import 'package:flutter/material.dart';

/// Handle Marathon-style per bottom sheet — linea rossa sottile.
class TmBottomSheetHandle extends StatelessWidget {
  const TmBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 3,
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4432F).withValues(alpha: 0.1),
              const Color(0xFFD4432F).withValues(alpha: 0.4),
              const Color(0xFFD4432F).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
