import '../../../core/enums/operator_type.dart';
import '../models/calculation_state.dart';

class CalculatorEngine {
  CalculationState _state = const CalculationState();

  CalculationState get state => _state;

  String get displayText => _formatDisplay(_state.display);

  void inputDigit(String digit) {
    if (_state.shouldResetDisplay) {
      _state = _state.copyWith(
        display: digit,
        shouldResetDisplay: false,
        hasDecimal: false,
      );
    } else {
      if (_state.display == '0' && digit != '.') {
        _state = _state.copyWith(display: digit);
      } else {
        _state = _state.copyWith(display: _state.display + digit);
      }
    }
  }

  void inputDecimal() {
    if (_state.shouldResetDisplay) {
      _state = _state.copyWith(
        display: '0.',
        shouldResetDisplay: false,
        hasDecimal: true,
      );
      return;
    }

    if (!_state.hasDecimal) {
      _state = _state.copyWith(
        display: '${_state.display}.',
        hasDecimal: true,
      );
    }
  }

  void setOperator(OperatorType operator_) {
    if (_state.currentOperator != null && !_state.shouldResetDisplay) {
      _calculateResult();
    }

    _state = _state.copyWith(
      firstOperand: double.parse(_state.display),
      currentOperator: () => operator_,
      shouldResetDisplay: true,
      hasDecimal: false,
    );
  }

  void calculateEquals() {
    if (_state.currentOperator == null) return;
    _calculateResult();
    _state = _state.copyWith(
      currentOperator: () => null,
      shouldResetDisplay: true,
    );
  }

  void clear() {
    _state = const CalculationState();
  }

  void toggleSign() {
    final currentValue = double.parse(_state.display);
    if (currentValue == 0) return;

    final toggled = -currentValue;
    _state = _state.copyWith(display: _formatNumber(toggled));
  }

  void inputPercent() {
    final currentValue = double.parse(_state.display);
    final result = currentValue / 100;
    _state = _state.copyWith(
      display: _formatNumber(result),
      shouldResetDisplay: true,
    );
  }

  void _calculateResult() {
    final second = double.parse(_state.display);
    final first = _state.firstOperand;
    double result;

    switch (_state.currentOperator!) {
      case OperatorType.add:
        result = first + second;
      case OperatorType.subtract:
        result = first - second;
      case OperatorType.multiply:
        result = first * second;
      case OperatorType.divide:
        if (second == 0) {
          _state = _state.copyWith(
            display: 'Error',
            shouldResetDisplay: true,
            currentOperator: () => null,
          );
          return;
        }
        result = first / second;
    }

    _state = _state.copyWith(
      display: _formatNumber(result),
      firstOperand: result,
    );
  }

  String _formatNumber(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _formatDisplay(String display) {
    if (display == 'Error') return display;

    if (display.contains('.')) return display;

    final number = int.tryParse(display);
    if (number == null) return display;

    final isNegative = number < 0;
    final absString = number.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < absString.length; i++) {
      if (i > 0 && (absString.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(absString[i]);
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }
}
