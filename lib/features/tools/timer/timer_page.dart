import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;

  int _totalSeconds = 60;
  int _remainingSeconds = 60;

  bool _isRunning = false;

  final TextEditingController _hoursController =
  TextEditingController(text: '0');
  final TextEditingController _minutesController =
  TextEditingController(text: '1');
  final TextEditingController _secondsController =
  TextEditingController(text: '0');

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _setTimerFromInputs() {
    if (_isRunning) return;

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;

    if (hours < 0 || minutes < 0 || seconds < 0) {
      _showMessage('زمان واردشده معتبر نیست.');
      return;
    }

    if (minutes > 59 || seconds > 59) {
      _showMessage('دقیقه و ثانیه باید بین ۰ تا ۵۹ باشند.');
      return;
    }

    final totalSeconds =
        (hours * 3600) + (minutes * 60) + seconds;

    if (totalSeconds <= 0) {
      _showMessage('لطفاً یک زمان بیشتر از صفر وارد کن.');
      return;
    }

    setState(() {
      _totalSeconds = totalSeconds;
      _remainingSeconds = totalSeconds;
    });
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    _timer?.cancel();

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (_remainingSeconds <= 1) {
          _timer?.cancel();

          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
          });

          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return _remainingSeconds / _totalSeconds;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'B Yekan',
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تایمر'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'زمان‌سنج ساده و سریع',
                    style: AppTypography.title,
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'زمان موردنظرت را وارد کن و شروع کن.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _TimeInput(
                        controller: _hoursController,
                        label: 'ساعت',
                        enabled: !_isRunning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TimeInput(
                        controller: _minutesController,
                        label: 'دقیقه',
                        enabled: !_isRunning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TimeInput(
                        controller: _secondsController,
                        label: 'ثانیه',
                        enabled: !_isRunning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isRunning
                        ? null
                        : _setTimerFromInputs,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(
                        color: AppColors.gold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'تنظیم زمان',
                      style: TextStyle(
                        fontFamily: 'B Yekan',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 330,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 10,
                            backgroundColor:
                            AppColors.surfaceElevated,
                            color: AppColors.gold,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              child: Text(
                                _formatTime(_remainingSeconds),
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontFamily: 'B Yekan',
                                  fontSize: 46,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRunning
                                  ? 'در حال اجرا'
                                  : _remainingSeconds == 0
                                  ? 'تمام شد'
                                  : 'آماده',
                              style: AppTypography.bodySecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _isRunning
                            ? _pauseTimer
                            : _remainingSeconds > 0
                            ? _startTimer
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          minimumSize:
                          const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isRunning ? 'توقف' : 'شروع',
                          style: const TextStyle(
                            fontFamily: 'B Yekan',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetTimer,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.textPrimary,
                          minimumSize:
                          const Size.fromHeight(54),
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ریست',
                          style: TextStyle(
                            fontFamily: 'B Yekan',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const _TimeInput({
    required this.controller,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      style: const TextStyle(
        fontFamily: 'B Yekan',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'B Yekan',
          color: AppColors.textSecondary,
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