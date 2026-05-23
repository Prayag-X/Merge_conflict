import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double widthFactor;
  final double fontSize;
  final bool isActive;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.numberButton,
    this.textColor = AppColors.numberText,
    this.widthFactor = 1,
    this.fontSize = 28,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackground =
        isActive ? AppColors.activeOperator : backgroundColor;
    final effectiveTextColor =
        isActive ? AppColors.activeOperatorText : textColor;

    return Expanded(
      flex: widthFactor.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox.expand(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBackground,
              foregroundColor: effectiveTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
