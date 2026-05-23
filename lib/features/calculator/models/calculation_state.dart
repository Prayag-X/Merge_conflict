import '../../../core/enums/operator_type.dart';

class CalculationState {
  final String display;
  final double firstOperand;
  final double secondOperand;
  final OperatorType? currentOperator;
  final bool shouldResetDisplay;
  final bool hasDecimal;

  const CalculationState({
    this.display = '0',
    this.firstOperand = 0,
    this.secondOperand = 0,
    this.currentOperator,
    this.shouldResetDisplay = false,
    this.hasDecimal = false,
  });

  CalculationState copyWith({
    String? display,
    double? firstOperand,
    double? secondOperand,
    OperatorType? Function()? currentOperator,
    bool? shouldResetDisplay,
    bool? hasDecimal,
  }) {
    return CalculationState(
      display: display ?? this.display,
      firstOperand: firstOperand ?? this.firstOperand,
      secondOperand: secondOperand ?? this.secondOperand,
      currentOperator:
          currentOperator != null ? currentOperator() : this.currentOperator,
      shouldResetDisplay: shouldResetDisplay ?? this.shouldResetDisplay,
      hasDecimal: hasDecimal ?? this.hasDecimal,
    );
  }
}
