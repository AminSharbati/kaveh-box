import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/security/app_lock_service.dart';
import '../core/theme/app_theme.dart';
import '../features/lock/app_lock_page.dart';
import '../features/splash/splash_page.dart';
import '../core/navigation/main_navigation.dart';

class KavehApp extends StatefulWidget {
  static final GlobalKey<KavehAppState> globalKey =
  GlobalKey<KavehAppState>();

  const KavehApp({
    super.key,
  });

  @override
  State<KavehApp> createState() => KavehAppState();
}

class KavehAppState extends State<KavehApp>
    with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;

  bool _showSplash = true;
  bool _isLocked = false;
  bool _hasEnteredMainApp = false;
  bool _lockChecking = false;

  // فقط وقتی واقعاً برنامه به پس‌زمینه رفته باشد،
  // بازگشت به برنامه باعث قفل شدن می‌شود.
  bool _wasInBackground = false;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');

    ThemeMode themeMode;

    switch (savedTheme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;

      case 'dark':
        themeMode = ThemeMode.dark;
        break;

      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    if (!mounted) return;

    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    String value;

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.dark:
        value = 'dark';
        break;

      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString('theme_mode', value);

    if (!mounted) return;

    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _finishSplash() async {
    if (!_showSplash) return;

    final lockService = AppLockService.instance;

    final lockEnabled = await lockService.isLockEnabled();
    final hasPin = await lockService.hasPin();

    if (!mounted) return;

    final shouldLock = lockEnabled && hasPin;

    setState(() {
      _showSplash = false;
      _hasEnteredMainApp = true;
      _isLocked = shouldLock;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasEnteredMainApp) return;
    if (_showSplash) return;

    // این حالت‌ها یعنی برنامه واقعاً از صفحه خارج شده
    // و به پس‌زمینه رفته است.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasInBackground = true;
      return;
    }

    // فقط بعد از یک خروج واقعی از برنامه، هنگام برگشت قفل کن.
    if (state == AppLifecycleState.resumed &&
        _wasInBackground) {
      _wasInBackground = false;
      _lockAppIfNeeded();
    }
  }

  Future<void> _lockAppIfNeeded() async {
    if (_lockChecking || _isLocked) return;

    _lockChecking = true;

    final lockService = AppLockService.instance;

    final lockEnabled = await lockService.isLockEnabled();
    final hasPin = await lockService.hasPin();

    if (!mounted) {
      _lockChecking = false;
      return;
    }

    if (lockEnabled && hasPin) {
      setState(() {
        _isLocked = true;
      });
    }

    _lockChecking = false;
  }

  void _unlockApp() {
    if (!mounted) return;

    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaveh Box',

      // زبان اصلی برنامه
      locale: const Locale('fa', 'IR'),

      // زبان‌هایی که برنامه پشتیبانی می‌کند
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],

      // Localization مورد نیاز تقویم فارسی و ویجت‌های Flutter
      localizationsDelegates: const [
        PersianMaterialLocalizations.delegate,
        PersianCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,

      home: Stack(
        children: [
          if (_showSplash)
            SplashPage(
              onFinished: _finishSplash,
            )
          else
            const MainNavigation(),

          if (_isLocked)
            Positioned.fill(
              child: AppLockPage(
                key: const ValueKey('app_lock_page'),
                onUnlocked: _unlockApp,
              ),
            ),
        ],
      ),
    );
  }
}