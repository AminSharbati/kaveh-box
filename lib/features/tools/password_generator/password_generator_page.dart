import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() =>
      _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  final Random _random = Random.secure();

  int _length = 16;
  bool _useUppercase = true;
  bool _useNumbers = true;
  bool _useSymbols = true;

  String _password = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    var characters = _lowercase;

    if (_useUppercase) {
      characters += _uppercase;
    }

    if (_useNumbers) {
      characters += _numbers;
    }

    if (_useSymbols) {
      characters += _symbols;
    }

    final password = List.generate(
      _length,
          (_) => characters[_random.nextInt(characters.length)],
    ).join();

    setState(() {
      _password = password;
    });
  }

  Future<void> _copyPassword() async {
    if (_password.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: _password),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'رمز در کلیپ‌بورد کپی شد',
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _strengthText() {
    var score = 1;

    if (_length >= 12) score++;
    if (_useUppercase) score++;
    if (_useNumbers) score++;
    if (_useSymbols) score++;

    if (score >= 5) return 'خیلی قوی';
    if (score >= 4) return 'قوی';
    if (score >= 3) return 'متوسط';
    return 'ضعیف';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تولید رمز امن'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'یک رمز تصادفی و امن بساز',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'طول و نوع کاراکترهای رمز را انتخاب کن.',
                  style: AppTypography.bodySecondary,
                ),
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
                    children: [
                      const Text(
                        'رمز تولیدشده',
                        style: AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: 14),
                      SelectableText(
                        _password,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldBright,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyPassword,
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                              ),
                              label: const Text('کپی'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.border,
                                ),
                                minimumSize:
                                const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _generatePassword,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 20,
                              ),
                              label: const Text('تولید مجدد'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.black,
                                minimumSize:
                                const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
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
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'طول رمز',
                            style: AppTypography.subtitle,
                          ),
                          Text(
                            '$_length کاراکتر',
                            style: AppTypography.bodySecondary,
                          ),
                        ],
                      ),
                      Slider(
                        value: _length.toDouble(),
                        min: 8,
                        max: 32,
                        divisions: 24,
                        activeColor: AppColors.gold,
                        inactiveColor: AppColors.surfaceElevated,
                        label: '$_length',
                        onChanged: (value) {
                          setState(() {
                            _length = value.round();
                          });
                          _generatePassword();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _OptionTile(
                  title: 'حروف بزرگ انگلیسی',
                  subtitle: 'A-Z',
                  value: _useUppercase,
                  onChanged: (value) {
                    setState(() {
                      _useUppercase = value;
                    });
                    _generatePassword();
                  },
                ),

                const SizedBox(height: 10),

                _OptionTile(
                  title: 'اعداد',
                  subtitle: '0-9',
                  value: _useNumbers,
                  onChanged: (value) {
                    setState(() {
                      _useNumbers = value;
                    });
                    _generatePassword();
                  },
                ),

                const SizedBox(height: 10),

                _OptionTile(
                  title: 'نمادها',
                  subtitle: '!@#\$%^&*',
                  value: _useSymbols,
                  onChanged: (value) {
                    setState(() {
                      _useSymbols = value;
                    });
                    _generatePassword();
                  },
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'قدرت رمز: ${_strengthText()}',
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
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.gold,
        activeTrackColor: AppColors.gold.withValues(
          alpha: 0.35,
        ),
        title: Text(
          title,
          style: AppTypography.body,
        ),
        subtitle: Text(
          subtitle,
          textDirection: TextDirection.ltr,
          style: AppTypography.caption,
        ),
      ),
    );
  }
}