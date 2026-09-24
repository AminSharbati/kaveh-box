import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum UnitCategory {
  length,
  weight,
  volume,
  area,
}

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  UnitCategory _category = UnitCategory.length;

  final TextEditingController _valueController =
  TextEditingController();

  String _fromUnit = 'متر';
  String _toUnit = 'کیلومتر';

  String _result = '0';
  bool _hasResult = false;

  final Map<UnitCategory, List<String>> _units = {
    UnitCategory.length: [
      'متر',
      'کیلومتر',
      'سانتی‌متر',
      'میلی‌متر',
      'مایل',
      'فوت',
      'اینچ',
    ],
    UnitCategory.weight: [
      'کیلوگرم',
      'گرم',
      'میلی‌گرم',
      'تن',
      'پوند',
    ],
    UnitCategory.volume: [
      'لیتر',
      'میلی‌لیتر',
      'متر مکعب',
      'گالن',
    ],
    UnitCategory.area: [
      'متر مربع',
      'کیلومتر مربع',
      'سانتی‌متر مربع',
      'هکتار',
      'فوت مربع',
    ],
  };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _changeCategory(UnitCategory category) {
    setState(() {
      _category = category;

      final units = _units[category]!;

      _fromUnit = units.first;
      _toUnit = units.length > 1 ? units[1] : units.first;

      _result = '0';
      _hasResult = false;
    });
  }

  void _convert() {
    final value = double.tryParse(
      _valueController.text.replaceAll(',', '.'),
    );

    if (value == null) {
      setState(() {
        _hasResult = false;
      });

      _showMessage('لطفاً یک عدد معتبر وارد کن.');
      return;
    }

    final result = _convertValue(
      value,
      _fromUnit,
      _toUnit,
      _category,
    );

    setState(() {
      _result = _formatNumber(result);
      _hasResult = true;
    });
  }

  double _convertValue(
      double value,
      String from,
      String to,
      UnitCategory category,
      ) {
    if (from == to) {
      return value;
    }

    switch (category) {
      case UnitCategory.length:
        final meters = _lengthToMeters(value, from);
        return _metersToLength(meters, to);

      case UnitCategory.weight:
        final grams = _weightToGrams(value, from);
        return _gramsToWeight(grams, to);

      case UnitCategory.volume:
        final liters = _volumeToLiters(value, from);
        return _litersToVolume(liters, to);

      case UnitCategory.area:
        final squareMeters = _areaToSquareMeters(value, from);
        return _squareMetersToArea(squareMeters, to);
    }
  }

  double _lengthToMeters(double value, String unit) {
    switch (unit) {
      case 'کیلومتر':
        return value * 1000;
      case 'سانتی‌متر':
        return value / 100;
      case 'میلی‌متر':
        return value / 1000;
      case 'مایل':
        return value * 1609.344;
      case 'فوت':
        return value * 0.3048;
      case 'اینچ':
        return value * 0.0254;
      default:
        return value;
    }
  }

  double _metersToLength(double value, String unit) {
    switch (unit) {
      case 'کیلومتر':
        return value / 1000;
      case 'سانتی‌متر':
        return value * 100;
      case 'میلی‌متر':
        return value * 1000;
      case 'مایل':
        return value / 1609.344;
      case 'فوت':
        return value / 0.3048;
      case 'اینچ':
        return value / 0.0254;
      default:
        return value;
    }
  }

  double _weightToGrams(double value, String unit) {
    switch (unit) {
      case 'کیلوگرم':
        return value * 1000;
      case 'میلی‌گرم':
        return value / 1000;
      case 'تن':
        return value * 1000000;
      case 'پوند':
        return value * 453.59237;
      default:
        return value;
    }
  }

  double _gramsToWeight(double value, String unit) {
    switch (unit) {
      case 'کیلوگرم':
        return value / 1000;
      case 'میلی‌گرم':
        return value * 1000;
      case 'تن':
        return value / 1000000;
      case 'پوند':
        return value / 453.59237;
      default:
        return value;
    }
  }

  double _volumeToLiters(double value, String unit) {
    switch (unit) {
      case 'میلی‌لیتر':
        return value / 1000;
      case 'متر مکعب':
        return value * 1000;
      case 'گالن':
        return value * 3.785411784;
      default:
        return value;
    }
  }

  double _litersToVolume(double value, String unit) {
    switch (unit) {
      case 'میلی‌لیتر':
        return value * 1000;
      case 'متر مکعب':
        return value / 1000;
      case 'گالن':
        return value / 3.785411784;
      default:
        return value;
    }
  }

  double _areaToSquareMeters(double value, String unit) {
    switch (unit) {
      case 'کیلومتر مربع':
        return value * 1000000;
      case 'سانتی‌متر مربع':
        return value / 10000;
      case 'هکتار':
        return value * 10000;
      case 'فوت مربع':
        return value * 0.09290304;
      default:
        return value;
    }
  }

  double _squareMetersToArea(double value, String unit) {
    switch (unit) {
      case 'کیلومتر مربع':
        return value / 1000000;
      case 'سانتی‌متر مربع':
        return value * 10000;
      case 'هکتار':
        return value / 10000;
      case 'فوت مربع':
        return value / 0.09290304;
      default:
        return value;
    }
  }

  void _clear() {
    setState(() {
      _valueController.clear();
      _result = '0';
      _hasResult = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _categoryTitle(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return 'طول';
      case UnitCategory.weight:
        return 'وزن';
      case UnitCategory.volume:
        return 'حجم';
      case UnitCategory.area:
        return 'مساحت';
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = _units[_category]!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'تبدیل واحد',
            style: AppTypography.subtitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'واحدها را به‌سرعت تبدیل کن',
                  style: AppTypography.title,
                ),

                const SizedBox(height: 8),

                const Text(
                  'نوع واحد و مقدار موردنظر را انتخاب کن.',
                  style: AppTypography.bodySecondary,
                ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: UnitCategory.values.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(
                            _categoryTitle(category),
                          ),
                          selected: _category == category,
                          onSelected: (_) =>
                              _changeCategory(category),
                          selectedColor: AppColors.gold,
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: _category == category
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 22),

                TextField(
                  controller: _valueController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'B Yekan',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'مقدار',
                    hintText: 'مثلاً 100',
                    labelStyle: AppTypography.bodySecondary,
                    hintStyle: AppTypography.bodySecondary,
                    prefixIcon: const Icon(
                      Icons.calculate_outlined,
                      color: AppColors.gold,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.gold,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _UnitDropdown(
                        label: 'از',
                        value: _fromUnit,
                        items: units,
                        onChanged: (value) {
                          setState(() {
                            _fromUnit = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UnitDropdown(
                        label: 'به',
                        value: _toUnit,
                        items: units,
                        onChanged: (value) {
                          setState(() {
                            _toUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _convert,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'تبدیل کن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _hasResult
                      ? _ResultCard(
                    key: const ValueKey('result'),
                    result: _result,
                    fromUnit: _fromUnit,
                    toUnit: _toUnit,
                  )
                      : const _EmptyResultCard(
                    key: ValueKey('empty'),
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

class _UnitDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.surfaceElevated,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySecondary,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.gold,
          ),
        ),
      ),
      items: items.map((unit) {
        return DropdownMenuItem<String>(
          value: unit,
          child: Text(
            unit,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'B Yekan',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String result;
  final String fromUnit;
  final String toUnit;

  const _ResultCard({
    super.key,
    required this.result,
    required this.fromUnit,
    required this.toUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'نتیجه',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              result,
              style: const TextStyle(
                color: AppColors.goldBright,
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$fromUnit  ←  $toUnit',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            color: AppColors.gold,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'نتیجه تبدیل اینجا نمایش داده می‌شود',
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}