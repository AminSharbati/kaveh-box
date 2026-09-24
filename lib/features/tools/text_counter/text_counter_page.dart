import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TextCounterPage extends StatefulWidget {
  const TextCounterPage({super.key});

  @override
  State<TextCounterPage> createState() => _TextCounterPageState();
}

class _TextCounterPageState extends State<TextCounterPage> {
  final TextEditingController _controller = TextEditingController();

  int get _characters => _controller.text.length;

  int get _charactersWithoutSpaces =>
      _controller.text.replaceAll(RegExp(r'\s'), '').length;

  int get _words {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _lines {
    if (_controller.text.isEmpty) return 0;
    return _controller.text.split('\n').length;
  }

  int get _spaces =>
      RegExp(r' ').allMatches(_controller.text).length;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  void _update() {
    setState(() {});
  }

  void _clear() {
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
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
          title: const Text('شمارش کلمات و حروف'),
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
                  'متنت رو وارد کن',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'کاوه تعداد کلمات، حروف و خطوط متن رو برات حساب می‌کنه.',
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
                    decoration: const InputDecoration(
                      hintText: 'اینجا متن خودت رو بنویس یا وارد کن...',
                      hintStyle: AppTypography.bodySecondary,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.text_fields_rounded,
                        title: 'حروف',
                        value: '$_characters',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.space_bar_rounded,
                        title: 'بدون فاصله',
                        value: '$_charactersWithoutSpaces',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book_rounded,
                        title: 'کلمات',
                        value: '$_words',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.notes_rounded,
                        title: 'خطوط',
                        value: '$_lines',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _StatCard(
                  icon: Icons.space_bar,
                  title: 'فاصله‌ها',
                  value: '$_spaces',
                  wide: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool wide;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment:
        wide ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.goldBright,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.bodySecondary,
              ),
            ],
          ),
          if (wide) const Spacer(),
          Text(
            value,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.goldBright,
            ),
          ),
        ],
      ),
    );
  }
}