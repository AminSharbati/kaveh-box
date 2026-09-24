import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _scannerController =
  MobileScannerController();

  String? _result;
  BarcodeFormat? _resultFormat;
  bool _isScanned = false;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    _startScanner();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _startScanner() async {
    try {
      await _scannerController.start();

      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isScanned) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value != null && value.trim().isNotEmpty) {
        setState(() {
          _result = value.trim();
          _resultFormat = barcode.format;
          _isScanned = true;
        });

        _scannerController.stop();
        break;
      }
    }
  }

  String _formatName(BarcodeFormat? format) {
    if (format == null) {
      return 'کد شناسایی‌شده';
    }

    switch (format.name) {
      case 'qrCode':
        return 'QR Code';
      case 'ean13':
        return 'EAN-13';
      case 'ean8':
        return 'EAN-8';
      case 'upcA':
        return 'UPC-A';
      case 'upcE':
        return 'UPC-E';
      case 'code128':
        return 'Code 128';
      case 'code39':
        return 'Code 39';
      case 'code93':
        return 'Code 93';
      case 'codabar':
        return 'Codabar';
      case 'dataMatrix':
        return 'Data Matrix';
      case 'aztec':
        return 'Aztec';
      case 'pdf417':
        return 'PDF417';
      case 'itf':
      case 'itf14':
      case 'itf2of5':
      case 'itf2of5WithChecksum':
        return 'ITF';
      case 'maxiCode':
        return 'MaxiCode';
      case 'microQrCode':
        return 'Micro QR Code';
      case 'dataBar':
        return 'DataBar';
      case 'dataBarExpanded':
        return 'DataBar Expanded';
      case 'dataBarLimited':
        return 'DataBar Limited';
      default:
        return 'کد شناسایی‌شده';
    }
  }

  Future<void> _copyResult() async {
    if (_result == null) return;

    await Clipboard.setData(
      ClipboardData(text: _result!),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'نتیجه کپی شد',
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _scanAgain() async {
    setState(() {
      _result = null;
      _resultFormat = null;
      _isScanned = false;
      _isStarting = true;
    });

    await _startScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'اسکنر QR و بارکد',
            style: AppTypography.subtitle,
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'QR یا بارکد را مقابل دوربین بگیر',
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'کاوه به‌صورت خودکار کد را شناسایی می‌کند.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 360,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _handleBarcode,
                      ),

                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScannerOverlayPainter(),
                        ),
                      ),

                      if (_isStarting)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          ),
                        ),

                      if (!_isScanned && !_isStarting)
                        const Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: _ScannerHint(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_result != null) ...[
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
                          color: AppColors.success.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 42,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'کد با موفقیت شناسایی شد',
                        style: AppTypography.subtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatName(_resultFormat),
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: SelectableText(
                          _result!,
                          textAlign: TextAlign.center,
                          style: AppTypography.body,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyResult,
                              icon: const Icon(Icons.copy),
                              label: const Text('کپی نتیجه'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _scanAgain,
                              icon: const Icon(
                                Icons.qr_code_scanner,
                              ),
                              label: const Text('اسکن دوباره'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.center_focus_strong,
                        color: AppColors.gold,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'منتظر شناسایی QR Code یا بارکد هستیم…',
                          style: AppTypography.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerHint extends StatelessWidget {
  const _ScannerHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            color: AppColors.gold,
            size: 22,
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'کد را داخل کادر قرار بده',
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const margin = 42.0;
    const cornerLength = 34.0;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - margin * 2,
      height: size.width - margin * 2,
    );

    final overlayPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(18),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    final path = Path();

    // بالا راست
    path.moveTo(rect.right - cornerLength, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerLength);

    // بالا چپ
    path.moveTo(rect.left + cornerLength, rect.top);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left, rect.top + cornerLength);

    // پایین راست
    path.moveTo(rect.right, rect.bottom - cornerLength);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right - cornerLength, rect.bottom);

    // پایین چپ
    path.moveTo(rect.left, rect.bottom - cornerLength);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left + cornerLength, rect.bottom);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}