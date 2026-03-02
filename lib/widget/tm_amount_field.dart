import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/// Campo di input per importi monetari, modulare e riutilizzabile.
class TmAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final Color? amountColor;
  final bool showLabel;
  final String? Function(String?)? validator;
  const TmAmountField({
    super.key,
    required this.controller,
    this.label,
    this.hintText = '0.00',
    this.amountColor,
    this.showLabel = true,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel && label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,2}')),
          ],
          style: amountColor != null
              ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  )
              : null,
          decoration: InputDecoration(
            prefixText: '€ ',
            prefixStyle: amountColor != null
                ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white38,
                    )
                : null,
            hintText: hintText,
            labelText: showLabel ? null : label,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
