import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PercentagePage extends StatefulWidget {
  const PercentagePage({super.key});

  @override
  State<PercentagePage> createState() => _PercentagePageState();
}

class _PercentagePageState extends State<PercentagePage> {
  final TextEditingController _numberController =
  TextEditingController();

  final TextEditingController _percentController =
  TextEditingController();

  int _selectedMode = 0;

  String _result = '0';
  String _description =
      'نتیجه اینجا نمایش داده می‌شود';

  @override
  void dispose() {
    _numberController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  void _calculate() {
    final number = double.tryParse(
      _numberController.text.replaceAll(',', ''),
    );

    final percent = double.tryParse(
      _percentController.text.replaceAll(',', ''),
    );

    if (number == null || percent == null) {
      setState(() {
        _result = '—';
        _description = 'لطفاً هر دو مقدار را وارد کن';
      });
      return;
    }

    double result;
    String description;

    switch (_selectedMode) {
      case 0:
        result = number * percent / 100;
        description =
        '$percent٪ از ${_formatNumber(number)} برابر است با';
        break;

      case 1:
        result = number + (number * percent / 100);
        description =
        '${_formatNumber(number)} با $percent٪ افزایش برابر است با';
        break;

      case 2:
        result = number - (number * percent / 100);
        description =
        '${_formatNumber(number)} با $percent٪ کاهش برابر است با';
        break;

      default:
        return;
    }

    setState(() {
      _result = _formatNumber(result);
      _description = description;
    });
  }

  void _clear() {
    setState(() {
      _numberController.clear();
      _percentController.clear();
      _result = '0';
      _description =
      'نتیجه اینجا نمایش داده می‌شود';
    });
  }

  String _formatNumber(double value) {
    final raw = value == value.roundToDouble()
        ? value.toInt().toString()
        : value
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');

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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'محاسبه درصد',
            style: AppTypography.subtitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'درصد را سریع و ساده محاسبه کن',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'یکی از حالت‌های زیر را انتخاب کن و مقدارها را وارد کن.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 24),
                _ModeSelector(
                  selectedMode: _selectedMode,
                  onChanged: (mode) {
                    setState(() {
                      _selectedMode = mode;
                      _result = '0';
                      _description =
                      'نتیجه اینجا نمایش داده می‌شود';
                    });
                  },
                ),
                const SizedBox(height: 24),
                _InputField(
                  controller: _numberController,
                  label: 'عدد',
                  hint: 'مثلاً 500,000',
                  icon: Icons.numbers_rounded,
                  formatNumber: true,
                ),
                const SizedBox(height: 14),
                _InputField(
                  controller: _percentController,
                  label: 'درصد',
                  hint: 'مثلاً 20',
                  icon: Icons.percent_rounded,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _calculate,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor:
                            AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'محاسبه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.textSecondary,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.percent_rounded,
                        color: AppColors.gold,
                        size: 30,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _description,
                        textAlign: TextAlign.center,
                        style:
                        AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        child: Text(
                          _result,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: AppColors.goldBright,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onChanged;

  const _ModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const modes = [
      'درصد یک عدد',
      'افزایش درصدی',
      'کاهش درصدی',
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: List.generate(
          modes.length,
              (index) {
            final selected =
                selectedMode == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 180),
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.gold.withValues(
                      alpha: 0.14,
                    )
                        : Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.gold.withValues(
                        alpha: 0.4,
                      )
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    modes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? AppColors.goldBright
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool formatNumber;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.formatNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      inputFormatters: [
        _NumberInputFormatter(
          groupThousands: formatNumber,
        ),
      ],
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTypography.bodySecondary,
        hintStyle: AppTypography.bodySecondary,
        prefixIcon: Icon(
          icon,
          color: AppColors.gold,
        ),
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
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _NumberInputFormatter
    extends TextInputFormatter {
  final bool groupThousands;

  _NumberInputFormatter({
    this.groupThousands = true,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9')
        .replaceAll(',', '')
        .replaceAll('،', '');

    final isNegative = text.startsWith('-');
    text = text.replaceAll('-', '');

    final dotIndex = text.indexOf('.');

    if (dotIndex != -1) {
      final integerPart =
      text.substring(0, dotIndex);
      final decimalPart =
      text.substring(dotIndex + 1)
          .replaceAll('.', '');

      text = '$integerPart.$decimalPart';
    }

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    if (groupThousands) {
      final parts = text.split('.');
      var integerPart = parts[0];
      final decimalPart =
      parts.length > 1 ? parts[1] : '';

      if (integerPart.isNotEmpty) {
        integerPart = integerPart.replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (_) => ',',
        );
      }

      text = '$integerPart'
          '${text.contains('.') ? '.$decimalPart' : ''}';
    }

    if (isNegative && text.isNotEmpty) {
      text = '-$text';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}