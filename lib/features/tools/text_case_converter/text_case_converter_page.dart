import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TextCaseConverterPage extends StatefulWidget {
  const TextCaseConverterPage({super.key});

  @override
  State<TextCaseConverterPage> createState() =>
      _TextCaseConverterPageState();
}

class _TextCaseConverterPageState extends State<TextCaseConverterPage> {
  final TextEditingController _controller = TextEditingController();

  String? _originalText;

  int get _letterCount {
    return _controller.text
        .replaceAll(RegExp(r'\s'), '')
        .length;
  }

  int get _wordCount {
    final text = _controller.text.trim();

    if (text.isEmpty) return 0;

    return text.split(RegExp(r'\s+')).length;
  }

  void _convert(String mode) {
    final text = _controller.text;

    if (text.isEmpty) {
      _showMessage('اول متن خودت را وارد کن');
      return;
    }

    _originalText ??= text;

    String result;

    switch (mode) {
      case 'upper':
        result = text.toUpperCase();
        break;

      case 'lower':
        result = text.toLowerCase();
        break;

      case 'title':
        result = text
            .split(RegExp(r'(\s+)'))
            .map(
              (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}',
        )
            .join();
        break;

      case 'toggle':
        result = String.fromCharCodes(
          text.runes.map((code) {
            final char = String.fromCharCode(code);
            final upper = char.toUpperCase();
            final lower = char.toLowerCase();

            if (char == upper && char != lower) {
              return lower.runes.first;
            }

            if (char == lower && char != upper) {
              return upper.runes.first;
            }

            return code;
          }),
        );
        break;

      default:
        result = text;
    }

    setState(() {
      _controller.text = result;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: result.length),
      );
    });
  }

  void _restoreOriginal() {
    if (_originalText == null) return;

    setState(() {
      _controller.text = _originalText!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  Future<void> _copy() async {
    if (_controller.text.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: _controller.text),
    );

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

  void _clear() {
    _controller.clear();

    setState(() {
      _originalText = null;
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
    final hasText = _controller.text.isNotEmpty;
    final canRestore =
        _originalText != null && _originalText != _controller.text;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تغییر حروف متن'),
          actions: [
            if (hasText)
              IconButton(
                onPressed: _copy,
                tooltip: 'کپی',
                icon: const Icon(Icons.copy_rounded),
              ),
            if (hasText)
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
                  'حروف متن رو تغییر بده 🔠',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'حالت حروف انگلیسی را تغییر بده؛ متن فارسی بدون تغییر باقی می‌ماند.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 16),

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
                    minLines: 9,
                    maxLines: 15,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: AppTypography.body,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Write your English text here...',
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
                      Icons.text_fields_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'حروف: $_letterCount',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.notes_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'کلمات: $_wordCount',
                      style: AppTypography.caption,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'انتخاب حالت',
                  style: AppTypography.subtitle,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _CaseButton(
                        label: 'UPPERCASE',
                        icon: Icons.arrow_upward_rounded,
                        onPressed: () => _convert('upper'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CaseButton(
                        label: 'lowercase',
                        icon: Icons.arrow_downward_rounded,
                        onPressed: () => _convert('lower'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _CaseButton(
                        label: 'Title Case',
                        icon: Icons.title_rounded,
                        onPressed: () => _convert('title'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CaseButton(
                        label: 'tOGGLE',
                        icon: Icons.swap_vert_rounded,
                        onPressed: () => _convert('toggle'),
                      ),
                    ),
                  ],
                ),

                if (canRestore) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _restoreOriginal,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('بازگردانی متن اولیه'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldBright,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.goldBright,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تغییر حروف فقط روی حروف قابل تبدیل اعمال می‌شود و ساختار چندخطی متن حفظ خواهد شد.',
                          style: AppTypography.bodySecondary,
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

class _CaseButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _CaseButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: AppColors.goldBright,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(
            color: AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}