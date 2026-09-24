import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri_date/hijri.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum _CalendarType {
  shamsi,
  gregorian,
  hijri,
}

class DateConverterPage extends StatefulWidget {
  const DateConverterPage({super.key});

  @override
  State<DateConverterPage> createState() => _DateConverterPageState();
}

class _DateConverterPageState extends State<DateConverterPage> {
  _CalendarType _calendarType = _CalendarType.shamsi;

  final TextEditingController _yearController =
  TextEditingController();
  final TextEditingController _monthController =
  TextEditingController();
  final TextEditingController _dayController =
  TextEditingController();

  String? _error;
  _ConvertedDate? _result;

  @override
  void initState() {
    super.initState();
    _setToday();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _setToday() {
    final now = DateTime.now();

    switch (_calendarType) {
      case _CalendarType.shamsi:
        final date = Jalali.fromDateTime(now);
        _setFields(date.year, date.month, date.day);
        break;

      case _CalendarType.gregorian:
        _setFields(now.year, now.month, now.day);
        break;

      case _CalendarType.hijri:
        final date = HijriDate.fromDate(now);
        _setFields(
          date.hYear,
          date.hMonth,
          date.hDay,
        );
        break;
    }

    _error = null;
    _result = null;
  }

  void _setFields(int year, int month, int day) {
    _yearController.text = year.toString();
    _monthController.text = month.toString();
    _dayController.text = day.toString();
  }

  void _changeCalendar(_CalendarType type) {
    setState(() {
      _calendarType = type;
      _setToday();
    });
  }

  void _convert() {
    FocusScope.of(context).unfocus();

    final year = _parseNumber(_yearController.text);
    final month = _parseNumber(_monthController.text);
    final day = _parseNumber(_dayController.text);

    if (year == null || month == null || day == null) {
      setState(() {
        _error = 'لطفاً سال، ماه و روز را کامل وارد کنید.';
        _result = null;
      });
      return;
    }

    try {
      late DateTime gregorian;

      switch (_calendarType) {
        case _CalendarType.shamsi:
          final date = Jalali(year, month, day);
          gregorian = date.toDateTime();
          break;

        case _CalendarType.gregorian:
          final date = DateTime(year, month, day);

          if (date.year != year ||
              date.month != month ||
              date.day != day) {
            throw Exception();
          }

          gregorian = date;
          break;

        case _CalendarType.hijri:
          final date = HijriDate.fromHijri(
            year,
            month,
            day,
          );

          gregorian = date.hijriToGregorian(
            date.hYear,
            date.hMonth,
            date.hDay,
          );
          break;
      }

      final shamsi = Jalali.fromDateTime(gregorian);
      final hijri = HijriDate.fromDate(gregorian);

      setState(() {
        _error = null;
        _result = _ConvertedDate(
          gregorian: gregorian,
          shamsi: shamsi,
          hijri: hijri,
        );
      });
    } catch (_) {
      setState(() {
        _error =
        'این تاریخ معتبر نیست. لطفاً تاریخ را بررسی کنید.';
        _result = null;
      });
    }
  }

  int? _parseNumber(String value) {
    final normalized = value
        .trim()
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

    return int.tryParse(normalized);
  }

  String _calendarTitle(_CalendarType type) {
    switch (type) {
      case _CalendarType.shamsi:
        return 'شمسی';
      case _CalendarType.gregorian:
        return 'میلادی';
      case _CalendarType.hijri:
        return 'قمری';
    }
  }

  String _shamsiMonthName(int month) {
    const months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _hijriMonthName(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربیع‌الاول',
      'ربیع‌الثانی',
      'جمادی‌الاول',
      'جمادی‌الثانی',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذوالقعده',
      'ذوالحجه',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _gregorianMonthName(int month) {
    const months = [
      'ژانویه',
      'فوریه',
      'مارس',
      'آوریل',
      'مه',
      'ژوئن',
      'ژوئیه',
      'اوت',
      'سپتامبر',
      'اکتبر',
      'نوامبر',
      'دسامبر',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _formatGregorian(DateTime date) {
    return '${date.day} '
        '${_gregorianMonthName(date.month)} '
        '${date.year}';
  }

  String _formatShamsi(Jalali date) {
    return '${date.day} '
        '${_shamsiMonthName(date.month)} '
        '${date.year}';
  }

  String _formatHijri(HijriDate date) {
    return '${date.hDay} '
        '${_hijriMonthName(date.hMonth)} '
        '${date.hYear}';
  }

  String _inputPreview() {
    final year = _parseNumber(_yearController.text);
    final month = _parseNumber(_monthController.text);
    final day = _parseNumber(_dayController.text);

    if (year == null || month == null || day == null) {
      return '';
    }

    switch (_calendarType) {
      case _CalendarType.shamsi:
        final monthName = _shamsiMonthName(month);
        if (monthName.isEmpty) {
          return '$day / $month / $year';
        }
        return '$day $monthName $year';

      case _CalendarType.gregorian:
        final monthName = _gregorianMonthName(month);
        if (monthName.isEmpty) {
          return '$day / $month / $year';
        }
        return '$day $monthName $year';

      case _CalendarType.hijri:
        final monthName = _hijriMonthName(month);
        if (monthName.isEmpty) {
          return '$day / $month / $year';
        }
        return '$day $monthName $year';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تبدیل تاریخ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCalendarSelector(),
              const SizedBox(height: 20),
              _buildInputCard(),
              const SizedBox(height: 16),
              _buildConvertButton(),
              if (_error != null) ...[
                const SizedBox(height: 14),
                _buildError(),
              ],
              if (_result != null) ...[
                const SizedBox(height: 20),
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تقویم تاریخ ورودی',
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              _calendarButton(
                _CalendarType.shamsi,
                '☀️  شمسی',
              ),
              _calendarButton(
                _CalendarType.gregorian,
                '🌍  میلادی',
              ),
              _calendarButton(
                _CalendarType.hijri,
                '🌙  قمری',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calendarButton(
      _CalendarType type,
      String title,
      ) {
    final selected = _calendarType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeCalendar(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.gold.withValues(
              alpha: 0.16,
            )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
              color: AppColors.gold.withValues(
                alpha: 0.45,
              ),
            )
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppColors.goldBright
                  : AppColors.textSecondary,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تاریخ ${_calendarTitle(_calendarType)}',
                  style: AppTypography.subtitle,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _setToday();
                  });
                },
                child: const Text('امروز'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller: _yearController,
                  label: 'سال',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateField(
                  controller: _monthController,
                  label: 'ماه',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateField(
                  controller: _dayController,
                  label: 'روز',
                ),
              ),
            ],
          ),
          if (_inputPreview().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _inputPreview(),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
      ),
      onChanged: (_) {
        setState(() {
          _result = null;
          _error = null;
        });
      },
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _convert,
        icon: const Icon(Icons.sync_rounded),
        label: const Text(
          'تبدیل تاریخ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'نتیجه تبدیل',
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: 16),
          _resultRow(
            icon: '☀️',
            title: 'شمسی',
            value: _formatShamsi(result.shamsi),
          ),
          const SizedBox(height: 10),
          _resultRow(
            icon: '🌍',
            title: 'میلادی',
            value: _formatGregorian(result.gregorian),
          ),
          const SizedBox(height: 10),
          _resultRow(
            icon: '🌙',
            title: 'قمری',
            value: _formatHijri(result.hijri),
          ),
        ],
      ),
    );
  }

  Widget _resultRow({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTypography.bodySecondary,
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConvertedDate {
  final DateTime gregorian;
  final Jalali shamsi;
  final HijriDate hijri;

  const _ConvertedDate({
    required this.gregorian,
    required this.shamsi,
    required this.hijri,
  });
}