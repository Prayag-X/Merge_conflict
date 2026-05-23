import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/operator_type.dart';
import '../services/calculator_engine.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_button_row.dart';
import '../widgets/calculator_display.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _engine = CalculatorEngine();

  void _onDigitPressed(String digit) {
    setState(() => _engine.inputDigit(digit));
  }

  void _onOperatorPressed(OperatorType operator_) {
    setState(() => _engine.setOperator(operator_));
  }

  void _onEqualsPressed() {
    setState(() => _engine.calculateEquals());
  }

  void _onClearPressed() {
    setState(() => _engine.clear());
  }

  void _onToggleSignPressed() {
    setState(() => _engine.toggleSign());
  }

  void _onPercentPressed() {
    setState(() => _engine.inputPercent());
  }

  void _onDecimalPressed() {
    setState(() => _engine.inputDecimal());
  }

  bool _isOperatorActive(OperatorType operator_) {
    return _engine.state.currentOperator == operator_ &&
        _engine.state.shouldResetDisplay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CalculatorDisplay(text: _engine.displayText),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  children: [
                  CalculatorButtonRow(
                    buttons: [
                      CalculatorButton(
                        label: AppStrings.clear,
                        onPressed: _onClearPressed,
                        backgroundColor: AppColors.functionButton,
                        textColor: AppColors.functionText,
                      ),
                      CalculatorButton(
                        label: AppStrings.toggleSign,
                        onPressed: _onToggleSignPressed,
                        backgroundColor: AppColors.functionButton,
                        textColor: AppColors.functionText,
                      ),
                      CalculatorButton(
                        label: AppStrings.percent,
                        onPressed: _onPercentPressed,
                        backgroundColor: AppColors.functionButton,
                        textColor: AppColors.functionText,
                      ),
                      CalculatorButton(
                        label: AppStrings.divide,
                        onPressed: () =>
                            _onOperatorPressed(OperatorType.divide),
                        backgroundColor: AppColors.operatorButton,
                        isActive: _isOperatorActive(OperatorType.divide),
                      ),
                    ],
                  ),
                  CalculatorButtonRow(
                    buttons: [
                      CalculatorButton(
                        label: '7',
                        onPressed: () => _onDigitPressed('7'),
                      ),
                      CalculatorButton(
                        label: '8',
                        onPressed: () => _onDigitPressed('8'),
                      ),
                      CalculatorButton(
                        label: '9',
                        onPressed: () => _onDigitPressed('9'),
                      ),
                      CalculatorButton(
                        label: AppStrings.multiply,
                        onPressed: () =>
                            _onOperatorPressed(OperatorType.multiply),
                        backgroundColor: AppColors.operatorButton,
                        isActive: _isOperatorActive(OperatorType.multiply),
                      ),
                    ],
                  ),
                  CalculatorButtonRow(
                    buttons: [
                      CalculatorButton(
                        label: '4',
                        onPressed: () => _onDigitPressed('4'),
                      ),
                      CalculatorButton(
                        label: '5',
                        onPressed: () => _onDigitPressed('5'),
                      ),
                      CalculatorButton(
                        label: '6',
                        onPressed: () => _onDigitPressed('6'),
                      ),
                      CalculatorButton(
                        label: AppStrings.subtract,
                        onPressed: () =>
                            _onOperatorPressed(OperatorType.subtract),
                        backgroundColor: AppColors.operatorButton,
                        isActive: _isOperatorActive(OperatorType.subtract),
                      ),
                    ],
                  ),
                  CalculatorButtonRow(
                    buttons: [
                      CalculatorButton(
                        label: '1',
                        onPressed: () => _onDigitPressed('1'),
                      ),
                      CalculatorButton(
                        label: '2',
                        onPressed: () => _onDigitPressed('2'),
                      ),
                      CalculatorButton(
                        label: '3',
                        onPressed: () => _onDigitPressed('3'),
                      ),
                      CalculatorButton(
                        label: AppStrings.add,
                        onPressed: () => _onOperatorPressed(OperatorType.add),
                        backgroundColor: AppColors.operatorButton,
                        isActive: _isOperatorActive(OperatorType.add),
                      ),
                    ],
                  ),
                  CalculatorButtonRow(
                    buttons: [
                      CalculatorButton(
                        label: AppStrings.zero,
                        onPressed: () => _onDigitPressed('0'),
                        widthFactor: 2,
                      ),
                      CalculatorButton(
                        label: AppStrings.decimal,
                        onPressed: _onDecimalPressed,
                      ),
                      CalculatorButton(
                        label: AppStrings.equals,
                        onPressed: _onEqualsPressed,
                        backgroundColor: AppColors.operatorButton,
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
