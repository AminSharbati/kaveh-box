import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_config.dart';
import '../../core/security/app_lock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

// ============================================================
// اطلاعات ارتباطی تیم کاوه
// ============================================================

const String kavehPhone = '09963997114';
const String kavehEmail = 'm.aminsharbati@gmail.com';

const String kavehWhatsApp = '989963997114';

const String kavehGooglePlayUrl = 'X';
const String kavehBazaarUrl = 'Y';
const String kavehMyketUrl = 'Z';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _lockEnabled = false;
  bool _biometricEnabled = false;
  bool _securityLoading = true;

  @override
  void initState() {
    super.initState();

    _loadSecurityState();
  }

  Future<void> _loadSecurityState() async {
    final lockEnabled =
    await AppLockService.instance.isLockEnabled();

    final biometricEnabled =
    await AppLockService.instance.isBiometricEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _lockEnabled = lockEnabled;
      _biometricEnabled = biometricEnabled;
      _securityLoading = false;
    });
  }

  Future<void> _setLock() async {
    final hasPin =
    await AppLockService.instance.hasPin();

    if (!mounted) {
      return;
    }

    if (hasPin) {
      await _showSecurityManager();
      return;
    }

    await _showSetPin();
  }

  Future<void> _showSetPin() async {
    final firstPinController = TextEditingController();
    final secondPinController = TextEditingController();

    bool obscureFirst = true;
    bool obscureSecond = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('تعیین رمز ورود'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'یک رمز ۴ رقمی برای ورود به کاوه تعیین کن.',
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: firstPinController,
                      obscureText: obscureFirst,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'رمز ۴ رقمی',
                        counterText: '',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureFirst = !obscureFirst;
                            });
                          },
                          icon: Icon(
                            obscureFirst
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: secondPinController,
                      obscureText: obscureSecond,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'تکرار رمز',
                        counterText: '',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureSecond = !obscureSecond;
                            });
                          },
                          icon: Icon(
                            obscureSecond
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('انصراف'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final pin = firstPinController.text;
                      final confirmation =
                          secondPinController.text;

                      if (pin.length != 4 ||
                          confirmation.length != 4) {
                        _showMessage(
                          'رمز باید دقیقاً ۴ رقم باشد.',
                        );
                        return;
                      }

                      if (pin != confirmation) {
                        _showMessage(
                          'رمز و تکرار رمز یکسان نیستند.',
                        );
                        return;
                      }

                      await AppLockService.instance.setPin(pin);

                      if (!dialogContext.mounted) {
                        return;
                      }

                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('ذخیره رمز'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    firstPinController.dispose();
    secondPinController.dispose();

    if (result == true && mounted) {
      setState(() {
        _lockEnabled = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _showMessage(
          'رمز ورود با موفقیت فعال شد.',
        );
      });
    }
  }

  Future<void> _showSecurityManager() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _SecurityActionsSheet();
      },
    );

    if (!mounted || action == null) {
      return;
    }

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case 'change':
        await _showChangePin();
        break;

      case 'disable':
        await _disableLock();
        break;

      case 'biometric':
        await _toggleBiometric();
        break;
    }
  }

  Future<void> _showChangePin() async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تغییر رمز'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'رمز فعلی',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'رمز جدید',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'تکرار رمز جدید',
                    counterText: '',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () async {
                  final oldPin = oldPinController.text;
                  final newPin = newPinController.text;
                  final confirmation =
                      confirmPinController.text;

                  if (oldPin.length != 4 ||
                      newPin.length != 4 ||
                      confirmation.length != 4) {
                    _showMessage(
                      'همه رمزها باید ۴ رقمی باشند.',
                    );
                    return;
                  }

                  if (newPin != confirmation) {
                    _showMessage(
                      'رمز جدید و تکرار آن یکسان نیستند.',
                    );
                    return;
                  }

                  final changed =
                  await AppLockService.instance.changePin(
                    oldPin,
                    newPin,
                  );

                  if (!changed) {
                    _showMessage(
                      'رمز فعلی اشتباه است.',
                    );
                    return;
                  }

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('تغییر رمز'),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();

    if (result == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _showMessage(
          'رمز با موفقیت تغییر کرد.',
        );
      });
    }
  }

  Future<void> _disableLock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('غیرفعال کردن قفل'),
            content: const Text(
              'با غیرفعال کردن قفل، رمز ورود حذف می‌شود. ادامه می‌دهی؟',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('غیرفعال کردن'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await AppLockService.instance.removePin();

    if (!mounted) {
      return;
    }

    setState(() {
      _lockEnabled = false;
      _biometricEnabled = false;
    });

    _showMessage(
      'قفل برنامه غیرفعال شد.',
    );
  }

  Future<void> _toggleBiometric() async {
    final service = AppLockService.instance;

    final currentlyEnabled =
    await service.isBiometricEnabled();

    if (currentlyEnabled) {
      await service.setBiometricEnabled(false);

      if (!mounted) {
        return;
      }

      setState(() {
        _biometricEnabled = false;
      });

      _showMessage(
        'ورود با اثر انگشت غیرفعال شد.',
      );

      return;
    }

    final authenticated =
    await service.authenticateWithBiometrics();

    if (!authenticated) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'تأیید اثر انگشت انجام نشد. مطمئن شو اثر انگشت یا قفل صفحه روی گوشی فعال است.',
      );

      return;
    }

    await service.setBiometricEnabled(true);

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricEnabled = true;
    });

    _showMessage(
      'ورود با اثر انگشت فعال شد.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _showAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _AboutPage(),
      ),
    );
  }

  void _showTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _TermsPage(),
      ),
    );
  }

  void _showContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _ContactPage(),
      ),
    );
  }

  Future<void> _showShare() async {
    const shareText =
        'یک جعبه‌ابزار کاربردی برای محاسبات، ریاضی، امنیت، متن، زمان و کلی ابزار روزمره.\n'
        '📲 دانلود از Google Play:\n'
        '$kavehGooglePlayUrl\n'
        '📲 دانلود از کافه‌بازار:\n'
        '$kavehBazaarUrl\n'
        '📲 دانلود از مایکت:\n'
        '$kavehMyketUrl\n'
        'ساخته‌شده توسط داتین آریا 🖤💛';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: '🖤💛 کاوه؛ جعبه‌ابزار روزمره',
      ),
    );
  }

  Future<void> _showUpdateCheck() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            content: _UpdateCheckContent(),
          ),
        );
      },
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                SizedBox(width: 10),
                Text('بررسی بروزرسانی'),
              ],
            ),
            content: Text(
              'نسخه فعلی کاوه: ${AppConfig.appVersion}\n\n'
                  'در حال حاضر کاوه هنوز در فروشگاه‌ها منتشر نشده است؛ بنابراین منبع رسمی بررسی نسخه جدید فعال نیست.\n\n'
                  'بخش بررسی بروزرسانی آماده است و بعد از انتشار، می‌توان منبع رسمی نسخه جدید را به آن متصل کرد.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('باشه'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'تنظیمات',
            style: AppTypography.title,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            30,
          ),
          children: [
            const Text(
              'ظاهر برنامه',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              'ظاهر کاوه را مطابق هویت اصلی خودش نگه داشته‌ایم.',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 18),

            const _ThemeComingSoonCard(),

            const SizedBox(height: 30),

            const Text(
              'امنیت و حریم خصوصی',
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),

            if (_securityLoading)
              const _SecurityLoadingCard()
            else
              _SettingsCard(
                icon: _lockEnabled
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                title: _lockEnabled
                    ? 'قفل برنامه فعال است'
                    : 'قفل برنامه',
                subtitle: _lockEnabled
                    ? (_biometricEnabled
                    ? 'رمز فعال • ورود با اثر انگشت فعال'
                    : 'رمز فعال • ورود با اثر انگشت غیرفعال')
                    : 'برای ورود به کاوه یک رمز ۴ رقمی تعیین کن',
                onTap: _setLock,
              ),

            const SizedBox(height: 30),

            const Text(
              'ارتباط با ما',
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.support_agent_rounded,
              title: 'ارسال پیام به تیم داتین آریا',
              subtitle:
              'انتقاد، پیشنهاد، گزارش مشکل و نظر',
              onTap: _showContact,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              icon: Icons.share_rounded,
              title: 'معرفی کاوه به دوستان',
              subtitle:
              'اشتراک‌گذاری کاوه با دوستان و آشنایان',
              onTap: _showShare,
            ),

            const SizedBox(height: 30),

            const Text(
              'برنامه',
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.system_update_rounded,
              title: 'بررسی بروزرسانی',
              subtitle: 'بررسی آخرین نسخه کاوه',
              onTap: _showUpdateCheck,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              icon: Icons.description_outlined,
              title: 'قوانین و مقررات',
              subtitle: 'شرایط استفاده از کاوه',
              onTap: _showTerms,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              icon: Icons.info_outline_rounded,
              title: 'درباره ما',
              subtitle: 'داستان داتین آریا و کاوه',
              onTap: _showAbout,
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'نسخه ${AppConfig.appVersion}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeComingSoonCard extends StatelessWidget {
  const _ThemeComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.62,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تنظیم تم',
                        style: AppTypography.subtitle,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'به‌زودی...',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: AppColors.gold,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'قفل',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated
                    .withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border
                      .withValues(alpha: 0.75),
                ),
              ),
              child: const Text(
                'فعلاً کاوه رنگش همیشه مشکی طلایی میمونه 🖤💛',
                style: AppTypography.bodySecondary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'اگر نظرت اینه تم‌های دیگه‌ای اضافه کنیم، '
                  'خوشحال می‌شیم نظرتو بهمون بگی ⬇️',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityLoadingCard extends StatelessWidget {
  const _SecurityLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 14),
          Text('در حال بررسی وضعیت امنیت...'),
        ],
      ),
    );
  }
}

class _SecurityActionsSheet extends StatelessWidget {
  const _SecurityActionsSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'امنیت برنامه',
                style: AppTypography.title,
              ),
              const SizedBox(height: 16),
              _SecurityAction(
                icon: Icons.password_rounded,
                title: 'تغییر رمز',
                subtitle: 'تغییر رمز ۴ رقمی ورود',
                onTap: () {
                  Navigator.of(context).pop('change');
                },
              ),
              const SizedBox(height: 10),
              _SecurityAction(
                icon: Icons.fingerprint_rounded,
                title: 'ورود با اثر انگشت',
                subtitle:
                'فعال‌سازی یا غیرفعال‌سازی ورود بیومتریک',
                onTap: () {
                  Navigator.of(context).pop('biometric');
                },
              ),
              const SizedBox(height: 10),
              _SecurityAction(
                icon: Icons.lock_open_rounded,
                title: 'غیرفعال کردن قفل',
                subtitle: 'حذف رمز و قفل ورود برنامه',
                onTap: () {
                  Navigator.of(context).pop('disable');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecurityAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.transparent,
                size: 18,
              ),
              const SizedBox(width: 2),
              Icon(
                icon,
                color: AppColors.gold,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.gold,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption,
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

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('درباره ما', style: AppTypography.title),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
          children: [
            const _AboutHero(),
            const SizedBox(height: 18),
            const _AboutSectionCard(
              icon: Icons.park_rounded,
              title: 'داتین آریا؛ یک تیم کوچک با اهدافی بزرگ 🔜',
              paragraphs: [
                'داتین آریا تازه شروع شده؛ مثل درختی که خیلی وقت نیست کاشته شده، اما اولین میوه‌های کوچک خودش را داده و قرار است با گذر زمان، بزرگ‌تر، پربارتر و پرثمرتر شود. 🌳',
                'قصه امروز داتین آریا هم همین است؛ یک تیم تازه‌تأسیس، جوان، جویای نام و تازه‌نفس که قرار است قدم‌به‌قدم رشد کند و روزبه‌روز اعضای بیشتری را در کنار خودش ببیند. 😎',
              ],
            ),
            const SizedBox(height: 14),
            const _AboutFounderCard(),
            const SizedBox(height: 14),
            const _AboutSectionCard(
              icon: Icons.inventory_2_rounded,
              title: 'کاوه؛ یکی از اعضای کوچک داتین آریا 🖤💛',
              paragraphs: [
                'کاوه یکی از اولین قدم‌های این مسیر است؛ عضوی کوچک از داتین آریا که خودش هم مثل تیمی که از آن آمده، حرف‌های زیادی برای گفتن دارد.',
                'کاوه یک جعبه‌ابزار روزمره است؛ مجموعه‌ای از ابزارهای کاربردی که در موضوعات مختلف طراحی شده‌اند تا شاید در یک روز، در یک لحظه و برای کاری که حتی از قبل نمی‌دانستیم به آن نیاز پیدا خواهیم کرد، به کمکمان بیایند.',
                'از ابزارهای محاسباتی و ریاضی گرفته تا ابزارهای امنیتی، نگارشی، عمومی و کاربردی؛ همه در یک جعبه جمع شده‌اند. 🗃️',
              ],
            ),
            const SizedBox(height: 14),
            const _AboutStatsCard(),
            const SizedBox(height: 14),
            const _AboutSectionCard(
              icon: Icons.auto_awesome_rounded,
              title: 'امروز؛ شروع یک مسیر',
              paragraphs: [
                'امروز، ۲۲ شهریور ۱۴۰۵، آخرین ویرایش نسخه نهایی و رسمی 1.0.0 کاوه انجام می‌شود.',
                'این چند خط هم نوشته می‌شوند تا به یادگار بمانند؛ یادگاری از روزهایی که کاوه هنوز کوچک بود، داتین آریا تازه متولد شده بود و مسیر آینده هنوز پر از اتفاق‌های ناشناخته بود. ❤️',
                'شاید سال‌ها بعد، وقتی به این صفحه نگاه کنیم، تعداد ابزارها، اعضای تیم و حتی خود کاوه با امروز قابل مقایسه نباشد.',
                'و این دقیقاً همان چیزی است که جذابش می‌کند.',
              ],
            ),
            const SizedBox(height: 14),
            const _AboutSectionCard(
              icon: Icons.rocket_launch_rounded,
              title: 'منتظر سورپرایزهای کاوه باشید... 🚀',
              paragraphs: [
                'کاوه مثل داتین آریا، هنوز اول راه است.',
                'قرار است به مرور بزرگ‌تر شود، ابزارهای بیشتری داشته باشد و امکانات جدیدی به آن اضافه شوند.',
                'پس باید منتظر گذر زمان بود... و مدام سورپرایز شد. 😎',
              ],
            ),
            const SizedBox(height: 14),
            const _AboutIranCard(),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/kaveh_logo.png', width: 58, height: 58),
                  const SizedBox(height: 10),
                  Text(
                    'نسخه ${AppConfig.appVersion}',
                    style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppConfig.developerName,
                    style: AppTypography.caption.copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.surfaceElevated, AppColors.surface],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold,
            blurRadius: 28,
            spreadRadius: -24,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            child: Image.asset('assets/images/kaveh_logo.png'),
          ),
          const SizedBox(height: 16),
          const Text('درباره ما', style: AppTypography.headline, textAlign: TextAlign.center),
          const SizedBox(height: 7),
          Text(
            AppConfig.appSubtitle,
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
            ),
            child: const Text(
              'یک شروع کوچک برای یک مسیر بزرگ 🖤💛',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> paragraphs;

  const _AboutSectionCard({
    required this.icon,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.16)),
                ),
                child: Icon(icon, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(title, style: AppTypography.subtitle.copyWith(height: 1.45)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...paragraphs.asMap().entries.map(
                (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == paragraphs.length - 1 ? 0 : 12,
              ),
              child: Text(
                entry.value,
                style: AppTypography.bodySecondary.copyWith(height: 1.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutFounderCard extends StatelessWidget {
  const _AboutFounderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'یک تیم کوچک، با هم‌تیمی‌های متفاوت 🙋‍♂️',
                  style: AppTypography.subtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text('و امروز، داتین آریا منم. 🙋‍♂️', style: AppTypography.body),
          const SizedBox(height: 10),
          Text(
            'هم‌تیمی‌هایم یک لپ‌تاپ، دوره‌ها و کتاب‌های آموزشی و البته یک یاور همیشه‌مؤمن به نام AI هستند! 😜',
            style: AppTypography.bodySecondary.copyWith(height: 1.85),
          ),
          const SizedBox(height: 12),
          Text(
            'شاید امروز این تیم کوچک به نظر برسد، اما هدف‌هایش کوچک نیستند.',
            style: AppTypography.body.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }
}

class _AboutStatsCard extends StatelessWidget {
  const _AboutStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.widgets_rounded, color: AppColors.gold),
              SizedBox(width: 10),
              Text('کاوه امروز', style: AppTypography.subtitle),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _AboutStat(
                  value: '۲۱',
                  label: 'ابزار فعلی',
                  icon: Icons.build_circle_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AboutStat(
                  value: '1.0.0',
                  label: 'نسخه رسمی',
                  icon: Icons.verified_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AboutStat(
                  value: '∞',
                  label: 'برای آینده',
                  icon: Icons.all_inclusive_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'امروز تعداد ابزارهای کاوه ۲۱ ابزار است؛ اما این تازه شروع ماجراست. 😍',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }
}

class _AboutStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _AboutStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.subtitle.copyWith(color: AppColors.goldBright),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AboutIranCard extends StatelessWidget {
  const _AboutIranCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Text('کاوه، تقدیم به شما', style: AppTypography.title, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text(
            'کاوه با تمام سادگی‌اش، برای یک هدف ساخته شده:',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'اینکه یک روز، یک ابزار کوچک در جعبه‌ابزارش بتواند کار شما را راحت‌تر کند.',
            style: AppTypography.bodySecondary.copyWith(height: 1.8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            'کاوه تقدیم به شما، مردم دوست‌داشتنی و شایسته ایران. 🖤💛',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'به امید ساختن و دیدن یک ایران جذاب‌تر.\n💚🤍❤️',
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ContactPage extends StatefulWidget {
  const _ContactPage();

  @override
  State<_ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<_ContactPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _type = 'پیشنهاد';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _openUri(
      Uri uri,
      String errorMessage,
      ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage(errorMessage);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(errorMessage);
      }
    }
  }

  Future<void> _callUs() async {
    if (kavehPhone == 'YOUR_PHONE_NUMBER') {
      _showMessage('ابتدا شماره تماس تیم کاوه را وارد کن.');
      return;
    }

    await _openUri(
      Uri(
        scheme: 'tel',
        path: kavehPhone,
      ),
      'امکان برقراری تماس وجود ندارد.',
    );
  }

  Future<void> _sendSms() async {
    if (kavehPhone == 'YOUR_PHONE_NUMBER') {
      _showMessage('ابتدا شماره تماس تیم کاوه را وارد کن.');
      return;
    }

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final body = _buildMessage(
      subject: subject,
      message: message,
    );

    await _openUri(
      Uri(
        scheme: 'sms',
        path: kavehPhone,
        queryParameters: {
          'body': body,
        },
      ),
      'برنامه پیامک روی گوشی در دسترس نیست.',
    );
  }

  Future<void> _openWhatsApp() async {
    if (kavehWhatsApp == 'YOUR_WHATSAPP_NUMBER') {
      _showMessage('ابتدا شماره واتساپ تیم کاوه را وارد کن.');
      return;
    }

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final body = _buildMessage(
      subject: subject,
      message: message,
    );

    final encodedMessage = Uri.encodeComponent(body);

    await _openUri(
      Uri.parse(
        'https://wa.me/$kavehWhatsApp?text=$encodedMessage',
      ),
      'واتساپ روی گوشی در دسترس نیست.',
    );
  }

  Future<void> _sendEmail() async {
    if (kavehEmail == 'YOUR_EMAIL@example.com') {
      _showMessage('ابتدا ایمیل تیم کاوه را وارد کن.');
      return;
    }

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final finalSubject = subject.isEmpty
        ? 'پیام از داخل برنامه کاوه'
        : 'کاوه | $subject';

    final body = _buildMessage(
      subject: subject,
      message: message,
    );

    await _openUri(
      Uri(
        scheme: 'mailto',
        path: kavehEmail,
        queryParameters: {
          'subject': finalSubject,
          'body': body,
        },
      ),
      'برنامه ایمیل روی گوشی در دسترس نیست.',
    );
  }

  String _buildMessage({
    required String subject,
    required String message,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('سلام تیم کاوه');
    buffer.writeln();
    buffer.writeln('نوع پیام: $_type');

    if (subject.isNotEmpty) {
      buffer.writeln('موضوع: $subject');
    }

    buffer.writeln();

    if (message.isNotEmpty) {
      buffer.writeln(message);
    } else {
      buffer.writeln(
        'این پیام از بخش ارتباط با ما در برنامه کاوه ارسال شده است.',
      );
    }

    return buffer.toString();
  }

  Future<void> _copyPhone() async {
    if (kavehPhone == 'YOUR_PHONE_NUMBER') {
      _showMessage('ابتدا شماره تماس را وارد کن.');
      return;
    }

    await Clipboard.setData(
      const ClipboardData(
        text: kavehPhone,
      ),
    );

    _showMessage('شماره تماس کپی شد.');
  }

  Future<void> _copyEmail() async {
    if (kavehEmail == 'YOUR_EMAIL@example.com') {
      _showMessage('ابتدا ایمیل را وارد کن.');
      return;
    }

    await Clipboard.setData(
      const ClipboardData(
        text: kavehEmail,
      ),
    );

    _showMessage('ایمیل کپی شد.');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ارتباط با ما',
            style: AppTypography.title,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            30,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.gold,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'در ارتباط باشیم',
                    style: AppTypography.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'اگر پیشنهاد، انتقاد، گزارش مشکل یا سوالی داری، '
                        'از یکی از راه‌های زیر با تیم کاوه در ارتباط باش.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'راه‌های ارتباطی',
              style: AppTypography.title,
            ),

            const SizedBox(height: 12),

            _ContactMethodCard(
              icon: Icons.phone_rounded,
              title: 'تماس تلفنی',
              subtitle: kavehPhone,
              onTap: _callUs,
              onCopy: _copyPhone,
            ),

            const SizedBox(height: 10),

            _ContactMethodCard(
              icon: Icons.sms_outlined,
              title: 'پیامک',
              subtitle: 'ارسال پیام مستقیم به تیم کاوه',
              onTap: _sendSms,
            ),

            const SizedBox(height: 10),

            _ContactMethodCard(
              icon: Icons.chat_rounded,
              title: 'واتساپ',
              subtitle: 'گفت‌وگو با تیم کاوه در واتساپ',
              onTap: _openWhatsApp,
            ),

            const SizedBox(height: 10),

            _ContactMethodCard(
              icon: Icons.email_outlined,
              title: 'ایمیل',
              subtitle: kavehEmail,
              onTap: _sendEmail,
              onCopy: _copyEmail,
            ),

            const SizedBox(height: 30),

            const Text(
              'ارسال پیام',
              style: AppTypography.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'پیامت را بنویس و بعد یکی از روش‌های ارسال را انتخاب کن.',
              style: AppTypography.bodySecondary,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'نوع پیام',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'انتقاد',
                  child: Text('انتقاد'),
                ),
                DropdownMenuItem(
                  value: 'پیشنهاد',
                  child: Text('پیشنهاد'),
                ),
                DropdownMenuItem(
                  value: 'گزارش مشکل',
                  child: Text('گزارش مشکل'),
                ),
                DropdownMenuItem(
                  value: 'درخواست',
                  child: Text('درخواست'),
                ),
                DropdownMenuItem(
                  value: 'سایر',
                  child: Text('سایر'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'موضوع',
                hintText: 'مثلاً مشکل در محاسبه...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _messageController,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'متن پیام',
                hintText: 'پیامت را اینجا بنویس...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sendEmail,
                    icon: const Icon(
                      Icons.email_outlined,
                    ),
                    label: const Text('ارسال با ایمیل'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendSms,
                    icon: const Icon(
                      Icons.sms_outlined,
                    ),
                    label: const Text('ارسال با پیامک'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(
                  Icons.chat_rounded,
                ),
                label: const Text('ارسال از طریق واتساپ'),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
              child: const Text(
                'با انتخاب هر روش، برنامه مربوط به همان سرویس روی گوشی باز می‌شود و ارسال نهایی توسط خودت انجام خواهد شد.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onCopy;

  const _ContactMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  tooltip: 'کپی',
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: AppColors.textSecondary,
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

class _UpdateCheckContent extends StatelessWidget {
  const _UpdateCheckContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'در حال بررسی بروزرسانی...',
          textAlign: TextAlign.center,
          style: AppTypography.subtitle,
        ),
        SizedBox(height: 6),
        Text(
          'لطفاً چند لحظه صبر کن.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySecondary,
        ),
      ],
    );
  }
}

class _TermsPage extends StatelessWidget {
  const _TermsPage();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'قوانین و مقررات',
            style: AppTypography.title,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            36,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: AppColors.gold,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'قبل از استفاده، یک نگاه کوتاه',
                    textAlign: TextAlign.center,
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'این بخش شرایط استفاده از کاوه، مسئولیت‌های کاربر و حدود استفاده از ابزارهای برنامه را توضیح می‌دهد.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _TermsSection(
              icon: Icons.check_circle_outline_rounded,
              title: '۱. پذیرش شرایط',
              text:
              'استفاده از برنامه کاوه به منزله پذیرش قوانین و مقررات استفاده از برنامه است.',
            ),
            const _TermsSection(
              icon: Icons.apps_rounded,
              title: '۲. هدف برنامه',
              text:
              'کاوه یک جعبه‌ابزار عمومی برای انجام محاسبات، تبدیل‌ها، مدیریت زمان، ابزارهای متنی و سایر امور روزمره است.',
            ),
            const _TermsSection(
              icon: Icons.fact_check_outlined,
              title: '۳. مسئولیت استفاده از نتایج',
              text:
              'نتایج ابزارهای برنامه برای استفاده عمومی ارائه می‌شوند. در امور حساس و تخصصی، کاربر باید نتایج را بررسی و صحت آن‌ها را از منابع معتبر تأیید کند.',
            ),
            const _TermsSection(
              icon: Icons.privacy_tip_outlined,
              title: '۴. حریم خصوصی',
              text:
              'اطلاعاتی که ابزارهای برنامه به صورت محلی پردازش می‌کنند، تا حد امکان روی دستگاه کاربر نگهداری می‌شوند. قابلیت‌هایی که نیازمند سرویس خارجی باشند، ممکن است مطابق عملکرد همان سرویس اطلاعاتی را منتقل کنند.',
            ),
            const _TermsSection(
              icon: Icons.lock_outline_rounded,
              title: '۵. امنیت رمز عبور',
              text:
              'در صورت فعال‌سازی قفل برنامه، مسئولیت حفظ و نگهداری رمز ورود بر عهده کاربر است.',
            ),
            const _TermsSection(
              icon: Icons.edit_note_rounded,
              title: '۶. محتوای کاربر',
              text:
              'مسئولیت محتوایی که کاربر در یادداشت‌ها و سایر بخش‌های برنامه وارد می‌کند، بر عهده خود کاربر است.',
            ),
            const _TermsSection(
              icon: Icons.update_rounded,
              title: '۷. تغییرات برنامه',
              text:
              'تیم داتین آریا می‌تواند برای بهبود عملکرد، امنیت و قابلیت‌های برنامه، امکانات و بخش‌های مختلف آن را در نسخه‌های آینده تغییر دهد.',
            ),
            const _TermsSection(
              icon: Icons.support_agent_rounded,
              title: '۸. پشتیبانی و گزارش مشکلات',
              text:
              'کاربران می‌توانند مشکلات، انتقادات و پیشنهادهای خود را از طریق بخش ارتباط با ما برای تیم کاوه ارسال کنند.',
            ),
            const _TermsSection(
              icon: Icons.warning_amber_rounded,
              title: '۹. محدودیت مسئولیت',
              text:
              'کاوه برای استفاده عمومی طراحی شده است و نباید به عنوان جایگزین مشاوره تخصصی مالی، پزشکی، حقوقی یا سایر خدمات حرفه‌ای مورد استفاده قرار گیرد.',
            ),
            const _TermsSection(
              icon: Icons.copyright_outlined,
              title: '۱۰. مالکیت فکری',
              text:
              'نام، نشان، طراحی و اجزای اختصاصی برنامه متعلق به صاحبان قانونی آن است و استفاده غیرمجاز از آن‌ها مجاز نیست.',
            ),
            const _TermsSection(
              icon: Icons.balance_rounded,
              title: '۱۱. قوانین حاکم',
              text:
              'استفاده از برنامه تابع قوانین و مقررات قابل اعمال در حوزه فعالیت ارائه‌دهنده برنامه خواهد بود.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.gold,
                    size: 25,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'یک نکته مهم',
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'کاوه برای ساده‌تر کردن کارهای روزمره ساخته شده است؛ در استفاده‌های حساس و تخصصی، بررسی نهایی اطلاعات و نتایج بر عهده کاربر است.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Column(
                children: [
                  Text(
                    'نسخه ${AppConfig.appVersion}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'آخرین به‌روزرسانی: ۲۲ شهریور ۱۴۰۵',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'کاوه • جعبه‌ابزار روزمره 🖤💛',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TermsSection({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: AppTypography.bodySecondary.copyWith(
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
