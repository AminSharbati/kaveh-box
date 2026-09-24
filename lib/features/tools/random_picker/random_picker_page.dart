import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class RandomPickerPage extends StatefulWidget {
  const RandomPickerPage({super.key});

  @override
  State<RandomPickerPage> createState() => _RandomPickerPageState();
}

class _RandomPickerPageState extends State<RandomPickerPage> {
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();

  String _result = 'هنوز چیزی انتخاب نشده';
  int _optionCount = 0;

  List<String> _getOptions() {
    return _controller.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _updateOptionCount() {
    final options = _getOptions();

    setState(() {
      _optionCount = options.length;
    });
  }

  void _pickRandom() {
    final options = _getOptions();

    if (options.isEmpty) {
      _showMessage('حداقل دو گزینه وارد کن');
      return;
    }

    if (options.length == 1) {
      _showMessage('برای انتخاب تصادفی حداقل دو گزینه لازم است');
      return;
    }

    setState(() {
      _optionCount = options.length;
      _result = options[_random.nextInt(options.length)];
    });
  }

  void _clear() {
    _controller.clear();

    setState(() {
      _result = 'هنوز چیزی انتخاب نشده';
      _optionCount = 0;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('انتخاب تصادفی'),
          actions: [
            if (_controller.text.isNotEmpty)
              IconButton(
                onPressed: _clear,
                tooltip: 'پاک کردن',
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'بذار کاوه انتخاب کنه 🎲',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'هر گزینه را در یک خط بنویس و اجازه بده کاوه یکی را تصادفی انتخاب کند.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 8,
                    maxLines: 14,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: AppTypography.body,
                    onChanged: (_) => _updateOptionCount(),
                    decoration: const InputDecoration(
                      hintText: 'مثلاً:\nپیتزا\nبرگر\nپاستا\nکباب',
                      hintStyle: AppTypography.bodySecondary,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.list_alt_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'تعداد گزینه‌ها: $_optionCount',
                      style: AppTypography.caption,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _pickRandom,
                    icon: const Icon(Icons.casino_rounded),
                    label: const Text(
                      'انتخاب تصادفی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.goldBright,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'نتیجه انتخاب',
                        style: AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _result,
                          key: ValueKey(_result),
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.goldBright,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  '💡 می‌توانی برای انتخاب غذا، اسم، کار روزانه یا هر لیست دیگری از این ابزار استفاده کنی.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}