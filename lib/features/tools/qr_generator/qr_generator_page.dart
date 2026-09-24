import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  String _qrData = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateQr() {
    FocusScope.of(context).unfocus();

    setState(() {
      _qrData = _controller.text.trim();
    });
  }

  void _clear() {
    _controller.clear();

    setState(() {
      _qrData = '';
    });
  }

  Future<void> _copyText() async {
    if (_qrData.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: _qrData));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'متن کپی شد',
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
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
          title: const Text(
            'ساخت QR Code',
            style: AppTypography.subtitle,
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'متن یا لینک موردنظر را وارد کن',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'کاوه آن را به یک QR Code تبدیل می‌کند.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _controller,
                maxLines: 4,
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'مثلاً https://example.com',
                  hintStyle: AppTypography.bodySecondary,
                  filled: true,
                  fillColor: AppColors.surface,
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
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _generateQr,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ساخت QR Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _clear,
                    tooltip: 'پاک کردن',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (_qrData.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
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
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 240,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'QR Code آماده است',
                        style: AppTypography.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _qrData,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _copyText,
                        icon: const Icon(Icons.copy),
                        label: const Text('کپی متن'),
                      ),
                    ],
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 64,
                        color: AppColors.gold,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'هنوز QR Code ساخته نشده',
                        style: AppTypography.subtitle,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'یک متن یا لینک وارد کن و روی دکمه ساخت بزن.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySecondary,
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