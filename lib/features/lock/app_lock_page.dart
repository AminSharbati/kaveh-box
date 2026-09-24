import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/security/app_lock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppLockPage extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockPage({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final AppLockService _lockService = AppLockService.instance;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _loading = true;
  bool _verifyingPin = false;
  bool _verifyingBiometric = false;
  bool _biometricEnabled = false;
  bool _biometricAttempted = false;

  String? _errorMessage;

  bool get _busy => _verifyingPin || _verifyingBiometric;

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    final biometricEnabled =
    await _lockService.isBiometricEnabled();

    if (!mounted) return;

    setState(() {
      _biometricEnabled = biometricEnabled;
      _loading = false;
    });

    if (biometricEnabled) {
      // اجازه می‌دهیم صفحه قفل کامل ساخته شود،
      // سپس فقط یک بار درخواست اثر انگشت را نمایش می‌دهیم.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        if (!mounted) return;

        await _authenticateWithBiometrics(
          automatic: true,
        );
      });
    } else {
      _focusPin();
    }
  }

  void _focusPin() {
    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      _pinFocusNode.requestFocus();
    });
  }

  Future<void> _verifyPin() async {
    if (_busy) return;

    final pin = _pinController.text;

    if (pin.length != 4) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'رمز ورود باید ۴ رقم باشد.';
      });

      _focusPin();
      return;
    }

    setState(() {
      _verifyingPin = true;
      _errorMessage = null;
    });

    try {
      final isCorrect = await _lockService.verifyPin(pin);

      if (!mounted) return;

      if (isCorrect) {
        widget.onUnlocked();
        return;
      }

      _pinController.clear();

      setState(() {
        _verifyingPin = false;
        _errorMessage = 'رمز واردشده صحیح نیست.';
      });

      _focusPin();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _verifyingPin = false;
        _errorMessage = 'خطایی در بررسی رمز رخ داد.';
      });

      _focusPin();
    }
  }

  Future<void> _authenticateWithBiometrics({
    bool automatic = false,
  }) async {
    if (_busy) return;

    // درخواست خودکار فقط یک بار انجام شود.
    if (automatic && _biometricAttempted) {
      _focusPin();
      return;
    }

    if (automatic) {
      _biometricAttempted = true;
    }

    setState(() {
      _verifyingBiometric = true;
      _errorMessage = null;
    });

    bool authenticated = false;

    try {
      authenticated =
      await _lockService.authenticateWithBiometrics();
    } catch (_) {
      authenticated = false;
    }

    if (!mounted) return;

    if (authenticated) {
      widget.onUnlocked();
      return;
    }

    // خیلی مهم:
    // بعد از Cancel یا شکست بیومتریک،
    // هیچ‌چیز نباید در حالت قفل/غیرفعال باقی بماند.
    setState(() {
      _verifyingBiometric = false;
      _errorMessage =
      'احراز هویت انجام نشد. می‌توانی رمز ۴ رقمی را وارد کنی.';
    });

    _focusPin();
  }

  void _onPinChanged(String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (value.length == 4) {
      _verifyPin();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              child: _loading
                  ? const CircularProgressIndicator(
                color: AppColors.gold,
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/kaveh_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'کاوه',
                    style: AppTypography.headline,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'برای ورود، هویت خود را تأیید کن',
                    style: AppTypography.bodySecondary,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  _buildPinField(),

                  const SizedBox(height: 14),

                  if (_errorMessage != null)
                    Padding(
                      padding:
                      const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed:
                      _verifyingPin || _verifyingBiometric
                          ? null
                          : _verifyPin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      child: _verifyingPin
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'ورود با رمز',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  if (_biometricEnabled) ...[
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed:
                        _busy
                            ? null
                            : () =>
                            _authenticateWithBiometrics(),
                        icon: _verifyingBiometric
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            AppColors.goldBright,
                          ),
                        )
                            : const Icon(
                          Icons.fingerprint_rounded,
                        ),
                        label: Text(
                          _verifyingBiometric
                              ? 'در حال تأیید...'
                              : 'ورود با اثر انگشت',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          AppColors.goldBright,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  const Text(
                    'قفل برنامه فعال است',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinField() {
    return TextField(
      controller: _pinController,
      focusNode: _pinFocusNode,
      autofocus: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      obscureText: true,
      maxLength: 4,
      enabled: !_verifyingPin,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: _onPinChanged,
      onSubmitted: (_) => _verifyPin(),
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 10,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '••••',
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
          letterSpacing: 8,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}