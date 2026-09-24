import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum _Shape {
  square,
  rectangle,
  triangle,
  circle,
}

class AreaCalculatorPage extends StatefulWidget {
  const AreaCalculatorPage({super.key});

  @override
  State<AreaCalculatorPage> createState() =>
      _AreaCalculatorPageState();
}

class _AreaCalculatorPageState
    extends State<AreaCalculatorPage> {
  final TextEditingController _firstController =
  TextEditingController();

  final TextEditingController _secondController =
  TextEditingController();

  _Shape _selectedShape = _Shape.square;

  String _result = '0';

  String get _shapeTitle {
    switch (_selectedShape) {
      case _Shape.square:
        return 'مربع';
      case _Shape.rectangle:
        return 'مستطیل';
      case _Shape.triangle:
        return 'مثلث';
      case _Shape.circle:
        return 'دایره';
    }
  }

  String get _firstLabel {
    switch (_selectedShape) {
      case _Shape.square:
        return 'طول ضلع';
      case _Shape.rectangle:
        return 'طول';
      case _Shape.triangle:
        return 'قاعده';
      case _Shape.circle:
        return 'شعاع';
    }
  }

  String get _secondLabel {
    switch (_selectedShape) {
      case _Shape.square:
        return '';
      case _Shape.rectangle:
        return 'عرض';
      case _Shape.triangle:
        return 'ارتفاع';
      case _Shape.circle:
        return '';
    }
  }

  void _calculate() {
    final first = double.tryParse(
      _firstController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final second = double.tryParse(
      _secondController.text
          .trim()
          .replaceAll(',', '.'),
    );

    if (first == null || first <= 0) {
      _showMessage('لطفاً مقدار معتبر وارد کن');
      return;
    }

    if (_selectedShape != _Shape.square &&
        _selectedShape != _Shape.circle &&
        (second == null || second <= 0)) {
      _showMessage('لطفاً مقدار دوم را هم وارد کن');
      return;
    }

    double area;

    switch (_selectedShape) {
      case _Shape.square:
        area = first * first;
        break;

      case _Shape.rectangle:
        area = first * second!;
        break;

      case _Shape.triangle:
        area = (first * second!) / 2;
        break;

      case _Shape.circle:
        area = 3.141592653589793 * first * first;
        break;
    }

    setState(() {
      _result = _formatNumber(area);
    });
  }

  String _formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number
        .toStringAsFixed(4)
        .replaceFirst(
      RegExp(r'0+$'),
      '',
    )
        .replaceFirst(
      RegExp(r'\.$'),
      '',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        duration:
        const Duration(seconds: 1),
      ),
    );
  }

  void _selectShape(_Shape shape) {
    setState(() {
      _selectedShape = shape;
      _result = '0';

      _firstController.clear();
      _secondController.clear();
    });
  }

  void _clear() {
    _firstController.clear();
    _secondController.clear();

    setState(() {
      _result = '0';
    });
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('محاسبه مساحت'),
          actions: [
            IconButton(
              onPressed: _clear,
              tooltip: 'پاک کردن',
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'مساحت شکل رو حساب کن 📏',
                  style: AppTypography.title,
                ),

                const SizedBox(height: 8),

                const Text(
                  'شکل موردنظر رو انتخاب کن و اندازه‌های آن را وارد کن.',
                  style:
                  AppTypography.bodySecondary,
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ShapeChip(
                      title: 'مربع',
                      icon:
                      Icons.crop_square_rounded,
                      selected:
                      _selectedShape ==
                          _Shape.square,
                      onTap: () => _selectShape(
                        _Shape.square,
                      ),
                    ),

                    _ShapeChip(
                      title: 'مستطیل',
                      icon:
                      Icons.rectangle_outlined,
                      selected:
                      _selectedShape ==
                          _Shape.rectangle,
                      onTap: () => _selectShape(
                        _Shape.rectangle,
                      ),
                    ),

                    _ShapeChip(
                      title: 'مثلث',
                      icon:
                      Icons.change_history_rounded,
                      selected:
                      _selectedShape ==
                          _Shape.triangle,
                      onTap: () => _selectShape(
                        _Shape.triangle,
                      ),
                    ),

                    _ShapeChip(
                      title: 'دایره',
                      icon:
                      Icons.circle_outlined,
                      selected:
                      _selectedShape ==
                          _Shape.circle,
                      onTap: () => _selectShape(
                        _Shape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _InputField(
                  controller: _firstController,
                  label: _firstLabel,
                ),

                if (_selectedShape !=
                    _Shape.square &&
                    _selectedShape !=
                        _Shape.circle) ...[
                  const SizedBox(height: 12),

                  _InputField(
                    controller:
                    _secondController,
                    label: _secondLabel,
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(
                      Icons.calculate_rounded,
                    ),
                    label: const Text(
                      'محاسبه مساحت',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      AppColors.gold,
                      foregroundColor:
                      Colors.black,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'مساحت $_shapeTitle',
                        style: AppTypography
                            .bodySecondary,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$_result واحد²',
                        style: AppTypography
                            .display
                            .copyWith(
                          color:
                          AppColors.goldBright,
                        ),
                        textAlign:
                        TextAlign.center,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _InputField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        AppTypography.bodySecondary,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ShapeChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ShapeChip({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(14),
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        decoration:
        BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(
            alpha: 0.14,
          )
              : AppColors.surface,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? AppColors.goldBright
                  : AppColors.textSecondary,
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}