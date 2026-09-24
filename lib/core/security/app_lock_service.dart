import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const String _pinKey = 'app_lock_pin';
  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _biometricEnabledKey = 'app_lock_biometric_enabled';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  final LocalAuthentication _localAuth =
  LocalAuthentication();

  // =========================
  // وضعیت قفل
  // =========================

  Future<bool> isLockEnabled() async {
    final value = await _storage.read(
      key: _lockEnabledKey,
    );

    return value == 'true';
  }

  Future<void> setLockEnabled(bool enabled) async {
    await _storage.write(
      key: _lockEnabledKey,
      value: enabled.toString(),
    );
  }

  // =========================
  // رمز ورود
  // =========================

  Future<bool> hasPin() async {
    final pin = await _storage.read(
      key: _pinKey,
    );

    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError(
        'رمز ورود باید دقیقاً ۴ رقم باشد.',
      );
    }

    await _storage.write(
      key: _pinKey,
      value: pin,
    );

    await setLockEnabled(true);
  }

  Future<bool> verifyPin(String pin) async {
    if (!_isValidPin(pin)) {
      return false;
    }

    final savedPin = await _storage.read(
      key: _pinKey,
    );

    return savedPin == pin;
  }

  Future<void> removePin() async {
    await _storage.delete(
      key: _pinKey,
    );

    await _storage.delete(
      key: _lockEnabledKey,
    );

    await setBiometricEnabled(false);
  }

  Future<bool> changePin(
      String oldPin,
      String newPin,
      ) async {
    final oldPinIsCorrect =
    await verifyPin(oldPin);

    if (!oldPinIsCorrect) {
      return false;
    }

    if (!_isValidPin(newPin)) {
      return false;
    }

    await _storage.write(
      key: _pinKey,
      value: newPin,
    );

    await setLockEnabled(true);

    return true;
  }

  // =========================
  // بیومتریک
  // =========================

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck =
      await _localAuth.canCheckBiometrics;

      final isSupported =
      await _localAuth.isDeviceSupported();

      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(
      key: _biometricEnabledKey,
    );

    return value == 'true';
  }

  Future<void> setBiometricEnabled(
      bool enabled,
      ) async {
    if (enabled) {
      final available =
      await isBiometricAvailable();

      if (!available) {
        throw Exception(
          'احراز هویت بیومتریک روی این دستگاه در دسترس نیست.',
        );
      }
    }

    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final available =
      await isBiometricAvailable();

      if (!available) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason:
        'برای ورود به کاوه هویت خود را تأیید کن.',
        biometricOnly: true,
      );
    } on PlatformException {
      return false;
    }
  }

  // =========================
  // اعتبارسنجی
  // =========================

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }
}