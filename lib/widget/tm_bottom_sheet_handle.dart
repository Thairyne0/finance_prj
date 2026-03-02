import 'package:flutter/material.dart';

/// Handle modulare per la parte superiore dei BottomSheet.
class TmBottomSheetHandle extends StatelessWidget {
  const TmBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

