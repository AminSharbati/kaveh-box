import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _start() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
          (_) {
        setState(() {
          _elapsed = _stopwatch.elapsed;
        });
      },
    );

    setState(() {});
  }

  void _pause() {
    _stopwatch.stop();
    _timer?.cancel();

    setState(() {
      _elapsed = _stopwatch.elapsed;
    });
  }

  void _reset() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();

    setState(() {
      _elapsed = Duration.zero;
    });
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final hundredths = duration.inMilliseconds % 1000 ~/ 10;

    return '${_twoDigits(minutes)}:'
        '${_twoDigits(seconds)}.'
        '${_twoDigits(hundredths)}';
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _stopwatch.isRunning;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('کرنومتر'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اندازه‌گیری دقیق زمان',
                    style: AppTypography.title,
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'برای اندازه‌گیری مدت زمان از کرنومتر استفاده کن.',
                    style: AppTypography.bodySecondary,
                  ),
                ),
                const SizedBox(height: 40),

                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 42,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            size: 42,
                            color: AppColors.gold,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _formatTime(_elapsed),
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isRunning ? 'در حال اندازه‌گیری' : 'آماده',
                            style: AppTypography.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isRunning ? _pause : _start,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isRunning ? 'توقف' : 'شروع',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size.fromHeight(54),
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ریست',
                          style: TextStyle(
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