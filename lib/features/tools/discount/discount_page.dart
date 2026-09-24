import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  String _result = '';
  String _savedPrice = '';
  String _savedDiscount = '';

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final price = _parseNumber(_priceController.text);
    final discount = _parseNumber(_discountController.text);

    if (price == null || discount == null) {
      setState(() {
        _result = 'لطفاً مبلغ و درصد تخفیف را وارد کن.';
      });
      return;
    }

    if (price < 0 || discount < 0 || discount > 100) {
      setState(() {
        _result = 'مقادیر واردشده معتبر نیستند.';
      });
      return;
    }

    final discountAmount = price * discount / 100;
    final finalPrice = price - discountAmount;

    setState(() {
      _savedPrice = _formatNumber(price);
      _savedDiscount = _formatNumber(discount);

      _result =
      'مبلغ تخفیف: ${_formatNumber(discountAmount)}\n'
          'مبلغ نهایی: ${_formatNumber(finalPrice)}';
    });
  }

  double? _parseNumber(String value) {
    final normalized = _normalizeDigits(value)
        .replaceAll(',', '')
        .replaceAll('،', '')
        .trim();

    return double.tryParse(normalized);
  }

  String _normalizeDigits(String value) {
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const englishDigits = '0123456789';

    var result = value;

    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(
        persianDigits[i],
        englishDigits[i],
      );
      result = result.replaceAll(
        arabicDigits[i],
        englishDigits[i],
      );
    }

    return result;
  }

  String _formatNumber(double value) {
    final isInteger = value == value.roundToDouble();

    final raw = isInteger
        ? value.toInt().toString()
        : value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');

    final parts = raw.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final sign = integerPart.startsWith('-') ? '-' : '';
    final unsignedInteger =
    sign.isEmpty ? integerPart : integerPart.substring(1);

    final groupedInteger = unsignedInteger.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );

    return decimalPart.isEmpty
        ? '$sign$groupedInteger'
        : '$sign$groupedInteger.$decimalPart';
  }

  void _clear() {
    setState(() {
      _priceController.clear();
      _discountController.clear();
      _result = '';
      _savedPrice = '';
      _savedDiscount = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'محاسبه تخفیف',
            style: AppTypography.subtitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _clear,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'قیمت و درصد تخفیف را وارد کن',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'اعداد بزرگ به‌صورت خودکار سه‌رقمی جدا می‌شوند.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 24),

                _InputField(
                  controller: _priceController,
                  label: 'قیمت اصلی',
                  hint: 'مثلاً 1,250,000',
                  suffix: 'تومان',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    _ThousandsSeparatorFormatter(),
                  ],
                ),

                const SizedBox(height: 16),

                _InputField(
                  controller: _discountController,
                  label: 'درصد تخفیف',
                  hint: 'مثلاً 20',
                  suffix: '%',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    _ThousandsSeparatorFormatter(),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'محاسبه تخفیف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (_result.isNotEmpty) ...[
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'نتیجه',
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: 16),

                        if (_savedPrice.isNotEmpty)
                          _ResultRow(
                            title: 'قیمت اصلی',
                            value: '$_savedPrice تومان',
                          ),

                        if (_savedDiscount.isNotEmpty)
                          _ResultRow(
                            title: 'درصد تخفیف',
                            value: '$_savedDiscount٪',
                          ),

                        const Divider(height: 28),

                        ..._buildResultRows(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultRows() {
    final lines = _result.split('\n');

    return lines.map((line) {
      final parts = line.split(':');

      if (parts.length < 2) {
        return Text(
          line,
          style: AppTypography.body,
        );
      }

      return _ResultRow(
        title: parts.first.trim(),
        value: parts.sublist(1).join(':').trim(),
      );
    }).toList();
  }
}

class _ResultRow extends StatelessWidget {
  final String title;
  final String value;

  const _ResultRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodySecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.goldBright,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffix,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
        ),
        suffixStyle: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
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
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var raw = _normalizeDigits(newValue.text);

    if (raw.isEmpty || raw == '-' || raw == '.' || raw == '-.') {
      return newValue.copyWith(
        text: raw,
        selection: TextSelection.collapsed(
          offset: raw.length,
        ),
        composing: TextRange.empty,
      );
    }

    raw = raw.replaceAll(',', '');

    final match = RegExp(
      r'^(-?)(\d*)(\.\d*)?$',
    ).firstMatch(raw);

    if (match == null) {
      return oldValue;
    }

    final sign = match.group(1) ?? '';
    final integerPart = match.group(2) ?? '';
    final decimalPart = match.group(3) ?? '';

    if (integerPart.isEmpty) {
      return newValue.copyWith(
        text: '$sign$decimalPart',
        selection: TextSelection.collapsed(
          offset: ('$sign$decimalPart').length,
        ),
        composing: TextRange.empty,
      );
    }

    final groupedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );

    final formatted = '$sign$groupedInteger$decimalPart';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
      composing: TextRange.empty,
    );
  }

  String _normalizeDigits(String value) {
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const englishDigits = '0123456789';

    var result = value;

    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(
        persianDigits[i],
        englishDigits[i],
      );
      result = result.replaceAll(
        arabicDigits[i],
        englishDigits[i],
      );
    }

    return result;
  }
}