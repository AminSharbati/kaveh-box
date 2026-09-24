import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TemperatureConverterPage extends StatefulWidget {
  const TemperatureConverterPage({super.key});

  @override
  State<TemperatureConverterPage> createState() =>
      _TemperatureConverterPageState();
}

class _TemperatureConverterPageState
    extends State<TemperatureConverterPage> {
  final TextEditingController _controller = TextEditingController();

  String _fromUnit = 'سانتی‌گراد';
  String _toUnit = 'فارنهایت';
  String _result = '—';

  final List<String> _units = [
    'سانتی‌گراد',
    'فارنهایت',
    'کلوین',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _toCelsius(double value, String unit) {
    switch (unit) {
      case 'فارنهایت':
        return (value - 32) * 5 / 9;
      case 'کلوین':
        return value - 273.15;
      default:
        return value;
    }
  }

  double _fromCelsius(double value, String unit) {
    switch (unit) {
      case 'فارنهایت':
        return value * 9 / 5 + 32;
      case 'کلوین':
        return value + 273.15;
      default:
        return value;
    }
  }

  void _convert() {
    final value = double.tryParse(_controller.text.trim());

    if (value == null) {
      setState(() {
        _result = 'عدد معتبر وارد کنید';
      });
      return;
    }

    final celsius = _toCelsius(value, _fromUnit);
    final converted = _fromCelsius(celsius, _toUnit);

    setState(() {
      _result = _formatNumber(converted);
    });
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _result = '—';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تبدیل دما'),
          backgroundColor: AppColors.background,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تبدیل سریع واحدهای دما',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'سانتی‌گراد، فارنهایت و کلوین را به یکدیگر تبدیل کن.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 28),

              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                style: AppTypography.title,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'مقدار دما',
                  hintText: 'مثلاً 25',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                    ),
                  ),
                ),
                onSubmitted: (_) => _convert(),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _UnitDropdown(
                      label: 'از',
                      value: _fromUnit,
                      units: _units,
                      onChanged: (value) {
                        setState(() {
                          _fromUnit = value;
                          _result = '—';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_horiz_rounded),
                    color: AppColors.gold,
                    iconSize: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _UnitDropdown(
                      label: 'به',
                      value: _toUnit,
                      units: _units,
                      onChanged: (value) {
                        setState(() {
                          _toUnit = value;
                          _result = '—';
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _convert,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'تبدیل کن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'نتیجه',
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldBright,
                      ),
                    ),
                    if (_result != '—' &&
                        _result != 'عدد معتبر وارد کنید') ...[
                      const SizedBox(height: 8),
                      Text(
                        _toUnit,
                        style: AppTypography.bodySecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> units;
  final ValueChanged<String> onChanged;

  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(
        fontFamily: 'B Yekan',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.gold,
          ),
        ),
      ),
      items: units
          .map(
            (unit) => DropdownMenuItem<String>(
          value: unit,
              child: Text(
                unit,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'B Yekan',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
        ),
      )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}