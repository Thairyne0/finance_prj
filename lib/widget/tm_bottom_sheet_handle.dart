import 'package:flutter/material.dart';

/// Handle modulare premium per la parte superiore dei BottomSheet.
class TmBottomSheetHandle extends StatelessWidget {
  const TmBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

