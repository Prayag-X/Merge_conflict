import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CalculatorDisplay extends StatelessWidget {
  final String text;

  const CalculatorDisplay({
    super.key,
    required this.text,
  });

  double _calculateFontSize() {
    if (text.length <= 6) return 80;
    if (text.length <= 9) return 60;
    if (text.length <= 12) return 45;
    return 35;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      alignment: Alignment.bottomRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            color: AppColors.displayText,
            fontSize: _calculateFontSize(),
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
