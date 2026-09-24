import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  Timer? _timer;

  DateTime _targetDate = DateTime.now().add(
    const Duration(hours: 1),
  );

  Duration _remaining = const Duration(hours: 1);

  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final nowJalali = Jalali.fromDateTime(now);
    final targetJalali = Jalali.fromDateTime(_targetDate);

    final Jalali? selectedDate = await showPersianDatePicker(
      context: context,

      // تاریخ فعلی انتخاب‌شده
      initialDate: targetJalali,

      // کمترین تاریخ مجاز
      firstDate: nowJalali,

      // بیشترین تاریخ مجاز
      lastDate: Jalali(1500, 12, 29),

      // مشخص کردن امروز
      currentDate: nowJalali,

      // فقط حالت تقویم؛ بدون حالت ورود دستی
      initialEntryMode:
      PersianDatePickerEntryMode.calendarOnly,

      // تقویم شمسی
      initialDatePickerMode: PersianDatePickerMode.day,

      // فارسی
      locale: const Locale('fa', 'IR'),

      // راست‌چین
      textDirection: TextDirection.rtl,

      helpText: 'انتخاب تاریخ',
      cancelText: 'لغو',
      confirmText: 'تأیید',

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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (selectedDate == null) return;

    if (!mounted) return;

    // تبدیل تاریخ شمسی انتخاب‌شده به میلادی
    // فقط برای محاسبات داخلی DateTime
    final selectedGregorian = selectedDate.toDateTime();

    setState(() {
      _targetDate = DateTime(
        selectedGregorian.year,
        selectedGregorian.month,
        selectedGregorian.day,
        _targetDate.hour,
        _targetDate.minute,
      );

      _updateRemaining();
    });
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_targetDate),
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

    if (selectedTime == null) return;

    if (!mounted) return;

    setState(() {
      _targetDate = DateTime(
        _targetDate.year,
        _targetDate.month,
        _targetDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final difference = _targetDate.difference(
      DateTime.now(),
    );

    _remaining = difference.isNegative
        ? Duration.zero
        : difference;
  }

  void _start() {
    _timer?.cancel();

    _updateRemaining();

    if (_remaining == Duration.zero) {
      setState(() {
        _isRunning = false;
      });
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        final difference = _targetDate.difference(
          DateTime.now(),
        );

        if (difference <= Duration.zero) {
          _timer?.cancel();

          setState(() {
            _remaining = Duration.zero;
            _isRunning = false;
          });

          return;
        }

        setState(() {
          _remaining = difference;
        });
      },
    );
  }

  void _pause() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;

      _targetDate = DateTime.now().add(
        const Duration(hours: 1),
      );

      _remaining = const Duration(hours: 1);
    });
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatRemaining() {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (days > 0) {
      return '$days روز\n'
          '${_twoDigits(hours)}:'
          '${_twoDigits(minutes)}:'
          '${_twoDigits(seconds)}';
    }

    return '${_twoDigits(hours)}:'
        '${_twoDigits(minutes)}:'
        '${_twoDigits(seconds)}';
  }

  String _formatTargetDate() {
    final jalaliDate = Jalali.fromDateTime(
      _targetDate,
    );

    return '${jalaliDate.year}/'
        '${jalaliDate.month.toString().padLeft(2, '0')}/'
        '${jalaliDate.day.toString().padLeft(2, '0')}';
  }

  String _formatTargetTime() {
    return '${_targetDate.hour.toString().padLeft(2, '0')}:'
        '${_targetDate.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isFinished = _remaining == Duration.zero;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('شمارش معکوس'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'شمارش تا یک زمان مشخص',
                  style: AppTypography.title,
                ),

                const SizedBox(height: 8),

                const Text(
                  'یک تاریخ و ساعت مشخص کن و شمارش معکوس را شروع کن.',
                  style: AppTypography.bodySecondary,
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 42,
                        color: AppColors.gold,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        isFinished
                            ? 'زمان به پایان رسید'
                            : _formatRemaining(),
                        textAlign: TextAlign.center,
                        textDirection:
                        TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'B Yekan',
                          fontSize:
                          isFinished ? 24 : 42,
                          fontWeight: FontWeight.w700,
                          color: isFinished
                              ? AppColors.goldBright
                              : AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _TargetCard(
                        icon:
                        Icons.calendar_month_rounded,
                        title: 'تاریخ',
                        value: _formatTargetDate(),
                        onTap: _selectDate,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _TargetCard(
                        icon:
                        Icons.access_time_rounded,
                        title: 'ساعت',
                        value: _formatTargetTime(),
                        onTap: _selectTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed:
                        _isRunning ? _pause : _start,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          AppColors.gold,
                          foregroundColor: Colors.black,
                          minimumSize:
                          const Size.fromHeight(54),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isRunning
                              ? 'توقف'
                              : 'شروع',
                          style: const TextStyle(
                            fontFamily: 'B Yekan',
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.textPrimary,
                          minimumSize:
                          const Size.fromHeight(54),
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ریست',
                          style: TextStyle(
                            fontFamily: 'B Yekan',
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _TargetCard({
    required this.icon,
    required this.title,
    required this.value,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.gold,
                size: 28,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: AppTypography.caption,
              ),

              const SizedBox(height: 6),

              Text(
                value,
                textDirection:
                TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'B Yekan',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}