import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TextCleanerPage extends StatefulWidget {
  const TextCleanerPage({super.key});

  @override
  State<TextCleanerPage> createState() => _TextCleanerPageState();
}

class _TextCleanerPageState extends State<TextCleanerPage> {
  final TextEditingController _controller = TextEditingController();

  bool _removeExtraSpaces = true;
  bool _removeEmptyLines = true;
  bool _trimLines = true;

  String _cleanText() {
    String text = _controller.text;

    if (_trimLines) {
      text = text
          .split('\n')
          .map((line) => line.trim())
          .join('\n');
    }

    if (_removeExtraSpaces) {
      text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    }

    if (_removeEmptyLines) {
      text = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .join('\n');
    }

    return text.trim();
  }

  void _clean() {
    final cleaned = _cleanText();

    setState(() {
      _controller.text = cleaned;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'متن با موفقیت پاک‌سازی شد',
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clear() {
    _controller.clear();
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
          title: const Text('پاک‌سازی متن'),
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
                  'متنت رو مرتب کن ✨',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'فاصله‌های اضافی و خطوط خالی رو حذف کن و متن تمیزتری داشته باش.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 10,
                    maxLines: 16,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: AppTypography.body,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'متن خودت رو اینجا وارد کن...',
                      hintStyle: AppTypography.bodySecondary,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _OptionTile(
                  title: 'حذف فاصله‌های اضافی',
                  subtitle: 'چند فاصله پشت سر هم به یک فاصله تبدیل می‌شود',
                  value: _removeExtraSpaces,
                  onChanged: (value) {
                    setState(() {
                      _removeExtraSpaces = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                _OptionTile(
                  title: 'حذف خطوط خالی',
                  subtitle: 'خطوطی که هیچ متنی ندارند حذف می‌شوند',
                  value: _removeEmptyLines,
                  onChanged: (value) {
                    setState(() {
                      _removeEmptyLines = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                _OptionTile(
                  title: 'مرتب کردن ابتدا و انتهای خطوط',
                  subtitle: 'فاصله‌های ابتدا و انتهای هر خط حذف می‌شوند',
                  value: _trimLines,
                  onChanged: (value) {
                    setState(() {
                      _trimLines = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _controller.text.trim().isEmpty ? null : _clean,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text(
                      'پاک‌سازی متن',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: AppColors.surfaceElevated,
                      disabledForegroundColor: AppColors.textDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.goldBright,
            activeTrackColor: AppColors.goldDeep,
          ),
        ],
      ),
    );
  }
}