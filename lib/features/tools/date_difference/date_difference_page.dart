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

class DateDifferencePage extends StatefulWidget {
  const DateDifferencePage({super.key});

  @override
  State<DateDifferencePage> createState() =>
      _DateDifferencePageState();
}

class _DateDifferencePageState extends State<DateDifferencePage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  _CalendarType _calendarType = _CalendarType.shamsi;

  void _calculateDifference() {
    setState(() {});
  }

  Future<void> _selectDate({
    required bool isStart,
  }) async {
    switch (_calendarType) {
      case _CalendarType.shamsi:
        await _selectShamsiDate(isStart: isStart);
        break;

      case _CalendarType.gregorian:
        await _selectGregorianDate(isStart: isStart);
        break;

      case _CalendarType.hijri:
        await _selectHijriDate(isStart: isStart);
        break;
    }
  }

  Future<void> _selectShamsiDate({
    required bool isStart,
  }) async {
    final currentDate = isStart ? _startDate : _endDate;
    final currentJalali = Jalali.fromDateTime(currentDate);

    final selected = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _ShamsiDateDialog(
          initialYear: currentJalali.year,
          initialMonth: currentJalali.month,
          initialDay: currentJalali.day,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _selectGregorianDate({
    required bool isStart,
  }) async {
    final initialDate = isStart ? _startDate : _endDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isStart ? 'انتخاب تاریخ اول' : 'انتخاب تاریخ دوم',
      cancelText: 'لغو',
      confirmText: 'انتخاب',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _selectHijriDate({
    required bool isStart,
  }) async {
    final currentDate = isStart ? _startDate : _endDate;
    final currentHijri = HijriDate.fromDate(currentDate);

    final selected = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _HijriDateDialog(
          initialYear: currentHijri.hYear,
          initialMonth: currentHijri.hMonth,
          initialDay: currentHijri.hDay,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  int get _totalDays {
    return _endDate.difference(_startDate).inDays.abs();
  }

  String _formatDate(DateTime date) {
    switch (_calendarType) {
      case _CalendarType.shamsi:
        final jalali = Jalali.fromDateTime(date);

        return '${jalali.year}/'
            '${jalali.month.toString().padLeft(2, '0')}/'
            '${jalali.day.toString().padLeft(2, '0')}';

      case _CalendarType.gregorian:
        return '${date.year}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.day.toString().padLeft(2, '0')}';

      case _CalendarType.hijri:
        final hijri = HijriDate.fromDate(date);

        return '${hijri.hYear}/'
            '${hijri.hMonth.toString().padLeft(2, '0')}/'
            '${hijri.hDay.toString().padLeft(2, '0')}';
    }
  }

  String get _calendarTitle {
    switch (_calendarType) {
      case _CalendarType.shamsi:
        return 'شمسی';

      case _CalendarType.gregorian:
        return 'میلادی';

      case _CalendarType.hijri:
        return 'قمری';
    }
  }

  String get _calendarDescription {
    switch (_calendarType) {
      case _CalendarType.shamsi:
        return 'تقویم خورشیدی ایران';

      case _CalendarType.gregorian:
        return 'تقویم میلادی';

      case _CalendarType.hijri:
        return 'تقویم اسلامی قمری';
    }
  }

  String _differenceText() {
    if (_startDate.isAfter(_endDate)) {
      return 'تاریخ اول بعد از تاریخ دوم است';
    }

    switch (_calendarType) {
      case _CalendarType.shamsi:
        return _shamsiDifferenceText();

      case _CalendarType.gregorian:
        return _gregorianDifferenceText();

      case _CalendarType.hijri:
        return _gregorianDifferenceText();
    }
  }

  String _gregorianDifferenceText() {
    var years = _endDate.year - _startDate.year;
    var months = _endDate.month - _startDate.month;
    var days = _endDate.day - _startDate.day;

    if (days < 0) {
      months--;

      final previousMonth = DateTime(
        _endDate.year,
        _endDate.month,
        0,
      );

      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years سال، $months ماه، $days روز';
  }

  String _shamsiDifferenceText() {
    final start = Jalali.fromDateTime(_startDate);
    final end = Jalali.fromDateTime(_endDate);

    var years = end.year - start.year;
    var months = end.month - start.month;
    var days = end.day - start.day;

    if (days < 0) {
      months--;

      final previousMonth = start.month == 1
          ? Jalali(end.year - 1, 12, 1)
          : Jalali(end.year, end.month - 1, 1);

      days += _shamsiDaysInMonth(
        previousMonth.year,
        previousMonth.month,
      );
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years سال، $months ماه، $days روز';
  }

  Future<void> _changeCalendar(_CalendarType type) async {
    if (_calendarType == type) return;

    setState(() {
      _calendarType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('اختلاف دو تاریخ'),
          backgroundColor: AppColors.background,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'فاصله بین دو تاریخ را محاسبه کن',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'تقویم موردنظر را انتخاب کن و سپس دو تاریخ را وارد کن.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 22),

              _CalendarSelector(
                selected: _calendarType,
                onChanged: _changeCalendar,
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تقویم فعال: $_calendarTitle — $_calendarDescription',
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              _DateCard(
                title: 'تاریخ اول',
                date: _formatDate(_startDate),
                calendarTitle: _calendarTitle,
                onTap: () => _selectDate(isStart: true),
              ),

              const SizedBox(height: 14),

              _DateCard(
                title: 'تاریخ دوم',
                date: _formatDate(_endDate),
                calendarTitle: _calendarTitle,
                onTap: () => _selectDate(isStart: false),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _calculateDifference,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'محاسبه اختلاف',
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
                    const Icon(
                      Icons.date_range_rounded,
                      size: 36,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'فاصله زمانی',
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _differenceText(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldBright,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'مجموعاً $_totalDays روز',
                        style: AppTypography.body,
                      ),
                    ),
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

int _shamsiDaysInMonth(int year, int month) {
  if (month <= 6) return 31;
  if (month <= 11) return 30;

  return Jalali(year, 1, 1).isLeapYear() ? 30 : 29;}

class _ShamsiDateDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int initialDay;

  const _ShamsiDateDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
  });

  @override
  State<_ShamsiDateDialog> createState() => _ShamsiDateDialogState();
}

class _ShamsiDateDialogState extends State<_ShamsiDateDialog> {
  late int _year;
  late int _month;
  late int _day;

  static const int _minYear = 1300;
  static const int _maxYear = 1499;

  static const List<String> _monthNames = [
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

  @override
  void initState() {
    super.initState();

    _year = widget.initialYear;
    _month = widget.initialMonth;
    _day = widget.initialDay;

    _normalizeDay();
  }

  int get _daysInMonth {
    return _shamsiDaysInMonth(_year, _month);
  }

  void _normalizeDay() {
    if (_day > _daysInMonth) {
      _day = _daysInMonth;
    }

    if (_day < 1) {
      _day = 1;
    }
  }

  DateTime? _selectedDate() {
    try {
      return Jalali(
        _year,
        _month,
        _day,
      ).toDateTime();
    } catch (_) {
      return null;
    }
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        if (_year > _minYear) {
          _year--;
          _month = 12;
        }
      } else {
        _month--;
      }

      _normalizeDay();
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        if (_year < _maxYear) {
          _year++;
          _month = 1;
        }
      } else {
        _month++;
      }

      _normalizeDay();
    });
  }

  void _selectDay(int day) {
    setState(() {
      _day = day;
    });
  }

  void _goToToday() {
    final today = Jalali.now();

    if (today.year < _minYear || today.year > _maxYear) {
      return;
    }

    setState(() {
      _year = today.year;
      _month = today.month;
      _day = today.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = Jalali(_year, _month, 1).toDateTime();

    // Dart: Monday = 1 ... Sunday = 7
    // Persian calendar week starts on Saturday.
    final firstDayOffset = (firstDay.weekday + 1) % 7;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        14,
      ),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'انتخاب تاریخ شمسی',
              style: AppTypography.title,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    tooltip: 'ماه قبل',
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _monthNames[_month - 1],
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_year',
                          textDirection: TextDirection.ltr,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.goldBright,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    tooltip: 'ماه بعد',
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: const [
                  _WeekDayLabel('ش'),
                  _WeekDayLabel('ی'),
                  _WeekDayLabel('د'),
                  _WeekDayLabel('س'),
                  _WeekDayLabel('چ'),
                  _WeekDayLabel('پ'),
                  _WeekDayLabel('ج'),
                ],
              ),

              const SizedBox(height: 6),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: firstDayOffset + _daysInMonth,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  if (index < firstDayOffset) {
                    return const SizedBox.shrink();
                  }

                  final day = index - firstDayOffset + 1;
                  final isSelected = day == _day;

                  final today = Jalali.now();
                  final isToday = today.year == _year &&
                      today.month == _month &&
                      today.day == day;

                  return Material(
                    color: isSelected
                        ? AppColors.gold
                        : isToday
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    child: InkWell(
                      onTap: () => _selectDay(day),
                      borderRadius: BorderRadius.circular(11),
                      child: Center(
                        child: Text(
                          '$day',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.black
                                : isToday
                                ? AppColors.goldBright
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _goToToday,
                  icon: const Icon(
                    Icons.today_rounded,
                    size: 18,
                  ),
                  label: const Text('امروز'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'لغو',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            final date = _selectedDate();

            if (date == null) {
              return;
            }

            Navigator.of(context).pop(date);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
          ),
          child: const Text(
            'انتخاب',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekDayLabel extends StatelessWidget {
  final String title;

  const _WeekDayLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          title,
          style: AppTypography.caption.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CalendarSelector extends StatelessWidget {
  final _CalendarType selected;
  final ValueChanged<_CalendarType> onChanged;

  const _CalendarSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          Expanded(
            child: _CalendarButton(
              title: 'شمسی',
              icon: Icons.wb_sunny_outlined,
              selected: selected == _CalendarType.shamsi,
              onTap: () => onChanged(_CalendarType.shamsi),
            ),
          ),
          Expanded(
            child: _CalendarButton(
              title: 'میلادی',
              icon: Icons.public_rounded,
              selected: selected == _CalendarType.gregorian,
              onTap: () => onChanged(_CalendarType.gregorian),
            ),
          ),
          Expanded(
            child: _CalendarButton(
              title: 'قمری',
              icon: Icons.nightlight_round,
              selected: selected == _CalendarType.hijri,
              onTap: () => onChanged(_CalendarType.hijri),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CalendarButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.gold.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.gold
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: selected
                      ? AppColors.goldBright
                      : AppColors.textSecondary,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String date;
  final String calendarTitle;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.date,
    required this.calendarTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            calendarTitle,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.subtitle,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HijriDateDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int initialDay;

  const _HijriDateDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
  });

  @override
  State<_HijriDateDialog> createState() => _HijriDateDialogState();
}

class _HijriDateDialogState extends State<_HijriDateDialog> {
  late int _year;
  late int _month;
  late int _day;

  @override
  void initState() {
    super.initState();

    _year = widget.initialYear;
    _month = widget.initialMonth;
    _day = widget.initialDay;

    _normalizeDay();
  }

  int _daysInMonth(int year, int month) {
    try {
      final firstDay = HijriDate.fromHijri(
        year,
        month,
        1,
      );

      final nextMonth = month == 12
          ? HijriDate.fromHijri(
        year + 1,
        1,
        1,
      )
          : HijriDate.fromHijri(
        year,
        month + 1,
        1,
      );

      return nextMonth
          .hijriToGregorian(
        nextMonth.hYear,
        nextMonth.hMonth,
        nextMonth.hDay,
      )
          .difference(
        firstDay.hijriToGregorian(
          firstDay.hYear,
          firstDay.hMonth,
          firstDay.hDay,
        ),
      )
          .inDays;
    } catch (_) {
      return 30;
    }
  }

  void _normalizeDay() {
    final maxDay = _daysInMonth(_year, _month);

    if (_day > maxDay) {
      _day = maxDay;
    }

    if (_day < 1) {
      _day = 1;
    }
  }

  DateTime? _toGregorian() {
    try {
      final hijri = HijriDate.fromHijri(
        _year,
        _month,
        _day,
      );

      return hijri.hijriToGregorian(
        _year,
        _month,
        _day,
      );
    } catch (_) {
      return null;
    }
  }

  String _monthName(int month) {
    const names = [
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
      'ذی‌القعده',
      'ذی‌الحجه',
    ];

    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final maxDay = _daysInMonth(_year, _month);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'انتخاب تاریخ قمری',
        style: AppTypography.title,
        textAlign: TextAlign.right,
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سال، ماه و روز قمری را انتخاب کن.',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _HijriDropdown<int>(
                    value: _year,
                    label: 'سال',
                    items: List.generate(
                      151,
                          (index) => 1350 + index,
                    ),
                    itemLabel: (value) => value.toString(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _year = value;
                        _normalizeDay();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _HijriDropdown<int>(
                    value: _month,
                    label: 'ماه',
                    items: List.generate(
                      12,
                          (index) => index + 1,
                    ),
                    itemLabel: _monthName,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _month = value;
                        _normalizeDay();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HijriDropdown<int>(
                    value: _day,
                    label: 'روز',
                    items: List.generate(
                      maxDay,
                          (index) => index + 1,
                    ),
                    itemLabel: (value) => value.toString(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _day = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'لغو',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            final date = _toGregorian();

            if (date == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تاریخ قمری انتخاب‌شده معتبر نیست.',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );

              return;
            }

            Navigator.of(context).pop(date);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
          ),
          child: const Text(
            'انتخاب',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HijriDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  const _HijriDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.gold,
          ),
        ),
      ),
      dropdownColor: AppColors.surfaceElevated,
      style: AppTypography.body,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}