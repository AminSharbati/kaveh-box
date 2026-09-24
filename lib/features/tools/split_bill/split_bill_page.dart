import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SplitBillPage extends StatefulWidget {
  const SplitBillPage({super.key});

  @override
  State<SplitBillPage> createState() => _SplitBillPageState();
}

class _SplitBillPageState extends State<SplitBillPage> {
  final TextEditingController _amountController =
  TextEditingController();

  final TextEditingController _peopleController =
  TextEditingController(text: '2');

  final TextEditingController _tipController =
  TextEditingController(text: '0');

  String _tipAmount = '0';
  String _totalAmount = '0';
  String _perPerson = '0';
  bool _hasResult = false;

  @override
  void dispose() {
    _amountController.dispose();
    _peopleController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', ''),
    );

    final people = int.tryParse(
      _peopleController.text.replaceAll(',', ''),
    );

    final tipPercent = double.tryParse(
      _tipController.text.replaceAll(',', ''),
    );

    if (amount == null ||
        amount < 0 ||
        people == null ||
        people <= 0 ||
        tipPercent == null ||
        tipPercent < 0) {
      setState(() {
        _hasResult = false;
      });

      _showMessage('لطفاً اطلاعات را درست وارد کن.');
      return;
    }

    if (tipPercent > 100) {
      setState(() {
        _hasResult = false;
      });

      _showMessage(
        'درصد انعام نمی‌تواند بیشتر از ۱۰۰ باشد.',
      );
      return;
    }

    final tip = amount * tipPercent / 100;
    final total = amount + tip;
    final perPerson = total / people;

    setState(() {
      _tipAmount = _formatNumber(tip);
      _totalAmount = _formatNumber(total);
      _perPerson = _formatNumber(perPerson);
      _hasResult = true;
    });
  }

  void _clear() {
    setState(() {
      _amountController.clear();
      _peopleController.text = '2';
      _tipController.text = '0';

      _tipAmount = '0';
      _totalAmount = '0';
      _perPerson = '0';
      _hasResult = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatNumber(double value) {
    final raw = value == value.roundToDouble()
        ? value.toInt().toString()
        : value
        .toStringAsFixed(2)
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
            'تقسیم هزینه',
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
                  'هزینه را بین همه تقسیم کن',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'مبلغ کل، تعداد افراد و در صورت نیاز درصد انعام را وارد کن.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 26),
                _InputField(
                  controller: _amountController,
                  label: 'مبلغ کل',
                  hint: 'مثلاً 1,200,000',
                  icon: Icons.payments_outlined,
                  formatNumber: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        controller: _peopleController,
                        label: 'تعداد نفرات',
                        hint: 'مثلاً 4',
                        icon: Icons.groups_outlined,
                        formatNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputField(
                        controller: _tipController,
                        label: 'انعام',
                        hint: 'مثلاً 10',
                        icon:
                        Icons.volunteer_activism_outlined,
                        suffixText: '%',
                      ),
                    ),
                  ],
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
                            'تقسیم هزینه',
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
                AnimatedSwitcher(
                  duration:
                  const Duration(milliseconds: 250),
                  child: _hasResult
                      ? _ResultCard(
                    key: const ValueKey('result'),
                    tipAmount: _tipAmount,
                    totalAmount: _totalAmount,
                    perPerson: _perPerson,
                  )
                      : const _EmptyResultCard(
                    key: ValueKey('empty'),
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

class _ResultCard extends StatelessWidget {
  final String tipAmount;
  final String totalAmount;
  final String perPerson;

  const _ResultCard({
    super.key,
    required this.tipAmount,
    required this.totalAmount,
    required this.perPerson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'سهم هر نفر',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              perPerson,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: AppColors.goldBright,
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'مبلغ قابل پرداخت برای هر نفر',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 18),
          _ResultRow(
            icon: Icons.receipt_long_outlined,
            title: 'مبلغ کل با انعام',
            value: totalAmount,
          ),
          const SizedBox(height: 14),
          _ResultRow(
            icon: Icons.volunteer_activism_outlined,
            title: 'مبلغ انعام',
            value: tipAmount,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.gold,
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodySecondary,
          ),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: AppTypography.subtitle,
        ),
      ],
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.groups_outlined,
            color: AppColors.gold,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'نتیجه تقسیم هزینه اینجا نمایش داده می‌شود',
            style: AppTypography.bodySecondary,
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
  final IconData icon;
  final String? suffixText;
  final bool formatNumber;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixText,
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
        suffixText: suffixText,
        labelStyle: AppTypography.bodySecondary,
        hintStyle: AppTypography.bodySecondary,
        suffixStyle: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
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

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}