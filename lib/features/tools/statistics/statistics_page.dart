import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TextEditingController _numbersController =
  TextEditingController();

  String _count = '0';
  String _sum = '0';
  String _average = '0';
  String _minimum = '0';
  String _maximum = '0';
  bool _hasResult = false;

  @override
  void dispose() {
    _numbersController.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _numbersController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _hasResult = false;
      });

      _showMessage('لطفاً چند عدد وارد کن.');
      return;
    }

    final normalizedText = _normalizeDigits(text);

    final parts = normalizedText
        .split(RegExp(r'[\s\n;؛]+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    final numbers = <double>[];

    for (final part in parts) {
      final cleanedPart = part
          .replaceAll(',', '')
          .replaceAll('،', '');

      final value = double.tryParse(cleanedPart);

      if (value == null) {
        setState(() {
          _hasResult = false;
        });

        _showMessage(
          'عدد نامعتبر پیدا شد: «$part»',
        );
        return;
      }

      numbers.add(value);
    }

    if (numbers.isEmpty) {
      setState(() {
        _hasResult = false;
      });

      _showMessage('عدد معتبری پیدا نشد.');
      return;
    }

    final sum =
    numbers.reduce((a, b) => a + b);

    final average = sum / numbers.length;

    final minimum = numbers.reduce(
          (a, b) => a < b ? a : b,
    );

    final maximum = numbers.reduce(
          (a, b) => a > b ? a : b,
    );

    setState(() {
      _count = numbers.length.toString();
      _sum = _formatNumber(sum);
      _average = _formatNumber(average);
      _minimum = _formatNumber(minimum);
      _maximum = _formatNumber(maximum);
      _hasResult = true;
    });
  }

  String _normalizeDigits(String text) {
    return text
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');
  }

  void _clear() {
    setState(() {
      _numbersController.clear();
      _count = '0';
      _sum = '0';
      _average = '0';
      _minimum = '0';
      _maximum = '0';
      _hasResult = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

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
            'میانگین و آمار',
            style: AppTypography.subtitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'چند عدد را تحلیل کن',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'اعداد را با فاصله، خط جدید یا سمی‌کالن از هم جدا کن.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _numbersController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    _StatisticsInputFormatter(),
                  ],
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  maxLines: 5,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    labelText: 'اعداد',
                    hintText:
                    'مثلاً 1,250,000  20,000  350,000',
                    labelStyle:
                    AppTypography.bodySecondary,
                    hintStyle:
                    AppTypography.bodySecondary,
                    prefixIcon: const Icon(
                      Icons.numbers_rounded,
                      color: AppColors.gold,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.gold,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _calculate,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                            AppColors.gold,
                            foregroundColor:
                            AppColors.background,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'محاسبه آمار',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
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
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.textSecondary,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape:
                          RoundedRectangleBorder(
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
                const SizedBox(height: 26),
                AnimatedSwitcher(
                  duration:
                  const Duration(milliseconds: 250),
                  child: _hasResult
                      ? _ResultCard(
                    key: const ValueKey('result'),
                    count: _count,
                    sum: _sum,
                    average: _average,
                    minimum: _minimum,
                    maximum: _maximum,
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

class _StatisticsInputFormatter
    extends TextInputFormatter {
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
        .replaceAll('۹', '9');

    final lines = text.split(RegExp(r'[\s\n;؛]+'));

    for (var i = 0; i < lines.length; i++) {
      var part = lines[i];

      if (part.isEmpty) continue;

      final isNegative = part.startsWith('-');
      part = part.replaceAll('-', '');

      part = part.replaceAll(',', '');

      if (!RegExp(r'^\d*\.?\d*$').hasMatch(part)) {
        return oldValue;
      }

      final pieces = part.split('.');
      var integerPart = pieces[0];
      final decimalPart =
      pieces.length > 1 ? pieces[1] : '';

      if (integerPart.isNotEmpty) {
        integerPart = integerPart.replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (_) => ',',
        );
      }

      lines[i] = '${isNegative ? '-' : ''}$integerPart'
          '${part.contains('.') ? '.$decimalPart' : ''}';
    }

    final formatted = _rebuildWithOriginalSeparators(
      text,
      lines,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }

  String _rebuildWithOriginalSeparators(
      String original,
      List<String> formattedParts,
      ) {
    final separators =
    RegExp(r'[\s\n;؛]+').allMatches(original);

    if (separators.isEmpty) {
      return formattedParts.isEmpty
          ? ''
          : formattedParts.first;
    }

    final buffer = StringBuffer();
    var partIndex = 0;
    var lastEnd = 0;

    for (final match in separators) {
      if (partIndex < formattedParts.length) {
        buffer.write(formattedParts[partIndex]);
        partIndex++;
      }

      buffer.write(
        original.substring(
          match.start,
          match.end,
        ),
      );

      lastEnd = match.end;
    }

    if (partIndex < formattedParts.length) {
      buffer.write(formattedParts[partIndex]);
    } else if (lastEnd < original.length) {
      buffer.write(original.substring(lastEnd));
    }

    return buffer.toString();
  }
}

class _ResultCard extends StatelessWidget {
  final String count;
  final String sum;
  final String average;
  final String minimum;
  final String maximum;

  const _ResultCard({
    super.key,
    required this.count,
    required this.sum,
    required this.average,
    required this.minimum,
    required this.maximum,
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
            'میانگین',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              average,
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
            'میانگین اعداد واردشده',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: AppColors.border,
          ),
          const SizedBox(height: 18),
          _ResultRow(
            icon: Icons.tag_rounded,
            title: 'تعداد اعداد',
            value: count,
          ),
          const SizedBox(height: 14),
          _ResultRow(
            icon: Icons.add_rounded,
            title: 'مجموع',
            value: sum,
          ),
          const SizedBox(height: 14),
          _ResultRow(
            icon: Icons.arrow_downward_rounded,
            title: 'کمترین',
            value: minimum,
          ),
          const SizedBox(height: 14),
          _ResultRow(
            icon: Icons.arrow_upward_rounded,
            title: 'بیشترین',
            value: maximum,
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
            Icons.bar_chart_rounded,
            color: AppColors.gold,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'نتیجه آمار اینجا نمایش داده می‌شود',
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}