import 'package:flutter/material.dart';

class CalculatorButtonRow extends StatelessWidget {
  final List<Widget> buttons;

  const CalculatorButtonRow({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }
}
