import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _firstNumber;
  String? _operator;
  bool _waitingForSecondNumber = false;

  void _inputNumber(String number) {
    setState(() {
      if (_waitingForSecondNumber) {
        _display = number;
        _waitingForSecondNumber = false;
        return;
      }

      if (_display == '0' || _display == 'خطا') {
        _display = number;
      } else {
        _display += number;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForSecondNumber) {
        _display = '0.';
        _waitingForSecondNumber = false;
        return;
      }

      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _selectOperator(String operator) {
    final value = double.tryParse(_display.replaceAll(',', ''));
    if (value == null) return;

    setState(() {
      if (_firstNumber != null && _operator != null) {
        _calculate();
      }

      _firstNumber = double.tryParse(_display.replaceAll(',', ''));
      _operator = operator;
      _expression =
      '${_formatNumber(_firstNumber!)} $operator';
      _waitingForSecondNumber = true;
    });
  }

  void _calculate() {
    if (_firstNumber == null || _operator == null) return;

    final secondNumber =
    double.tryParse(_display.replaceAll(',', ''));

    if (secondNumber == null) return;

    double result;

    switch (_operator) {
      case '+':
        result = _firstNumber! + secondNumber;
        break;

      case '−':
        result = _firstNumber! - secondNumber;
        break;

      case '×':
        result = _firstNumber! * secondNumber;
        break;

      case '÷':
        if (secondNumber == 0) {
          _display = 'خطا';
          _expression = 'تقسیم بر صفر';
          _firstNumber = null;
          _operator = null;
          _waitingForSecondNumber = true;
          return;
        }

        result = _firstNumber! / secondNumber;
        break;

      default:
        return;
    }

    _expression =
    '${_formatNumber(_firstNumber!)} $_operator ${_formatNumber(secondNumber)} =';

    // مقدار داخلی بدون کاما نگه داشته می‌شود.
    _display = _rawNumber(result);

    _firstNumber = result;
    _operator = null;
    _waitingForSecondNumber = true;
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstNumber = null;
      _operator = null;
      _waitingForSecondNumber = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_display == 'خطا' || _display.length <= 1) {
        _display = '0';
        return;
      }

      _display = _display.substring(
        0,
        _display.length - 1,
      );

      if (_display == '-' || _display.isEmpty) {
        _display = '0';
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0' || _display == 'خطا') return;

      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _percentage() {
    final value =
    double.tryParse(_display.replaceAll(',', ''));

    if (value == null) return;

    setState(() {
      _display = _rawNumber(value / 100);
    });
  }

  String _rawNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatNumber(double value) {
    final raw = _rawNumber(value);
    final parts = raw.split('.');

    var integerPart = parts[0];
    final decimalPart =
    parts.length > 1 ? parts[1] : '';

    var sign = '';

    if (integerPart.startsWith('-')) {
      sign = '-';
      integerPart = integerPart.substring(1);
    }

    integerPart = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );

    return '$sign$integerPart'
        '${decimalPart.isNotEmpty ? '.$decimalPart' : ''}';
  }

  String _displayText() {
    if (_display == 'خطا') return _display;

    final value =
    double.tryParse(_display.replaceAll(',', ''));

    if (value == null) return _display;

    return _formatNumber(value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'ماشین‌حساب',
            style: AppTypography.subtitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 28,
                        child: Text(
                          _expression,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _displayText(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  child: GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    children: [
                      _Button(
                        text: 'AC',
                        type: _ButtonType.action,
                        onTap: _clear,
                      ),
                      _Button(
                        text: '⌫',
                        type: _ButtonType.action,
                        onTap: _backspace,
                      ),
                      _Button(
                        text: '%',
                        type: _ButtonType.action,
                        onTap: _percentage,
                      ),
                      _Button(
                        text: '÷',
                        type: _ButtonType.operator,
                        onTap: () => _selectOperator('÷'),
                      ),
                      _Button(
                        text: '7',
                        onTap: () => _inputNumber('7'),
                      ),
                      _Button(
                        text: '8',
                        onTap: () => _inputNumber('8'),
                      ),
                      _Button(
                        text: '9',
                        onTap: () => _inputNumber('9'),
                      ),
                      _Button(
                        text: '×',
                        type: _ButtonType.operator,
                        onTap: () => _selectOperator('×'),
                      ),
                      _Button(
                        text: '4',
                        onTap: () => _inputNumber('4'),
                      ),
                      _Button(
                        text: '5',
                        onTap: () => _inputNumber('5'),
                      ),
                      _Button(
                        text: '6',
                        onTap: () => _inputNumber('6'),
                      ),
                      _Button(
                        text: '−',
                        type: _ButtonType.operator,
                        onTap: () => _selectOperator('−'),
                      ),
                      _Button(
                        text: '1',
                        onTap: () => _inputNumber('1'),
                      ),
                      _Button(
                        text: '2',
                        onTap: () => _inputNumber('2'),
                      ),
                      _Button(
                        text: '3',
                        onTap: () => _inputNumber('3'),
                      ),
                      _Button(
                        text: '+',
                        type: _ButtonType.operator,
                        onTap: () => _selectOperator('+'),
                      ),
                      _Button(
                        text: '±',
                        type: _ButtonType.action,
                        onTap: _toggleSign,
                      ),
                      _Button(
                        text: '0',
                        onTap: () => _inputNumber('0'),
                      ),
                      _Button(
                        text: '.',
                        onTap: _inputDecimal,
                      ),
                      _Button(
                        text: '=',
                        type: _ButtonType.equals,
                        onTap: () {
                          setState(() {
                            _calculate();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ButtonType {
  number,
  action,
  operator,
  equals,
}

class _Button extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final _ButtonType type;

  const _Button({
    required this.text,
    required this.onTap,
    this.type = _ButtonType.number,
  });

  @override
  Widget build(BuildContext context) {
    Color background;

    switch (type) {
      case _ButtonType.number:
        background = AppColors.surface;
        break;
      case _ButtonType.action:
        background = AppColors.surfaceElevated;
        break;
      case _ButtonType.operator:
        background = AppColors.goldDeep;
        break;
      case _ButtonType.equals:
        background = AppColors.gold;
        break;
    }

    final textColor = type == _ButtonType.equals
        ? AppColors.background
        : AppColors.textPrimary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor:
        AppColors.gold.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: type == _ButtonType.operator ||
                  type == _ButtonType.equals
                  ? AppColors.gold.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}