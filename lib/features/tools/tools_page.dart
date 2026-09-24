import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/favorites_storage.dart';
import '../../data/tool_registry.dart';
import '../../models/tool.dart';

import 'calculator/calculator_page.dart';
import 'percentage/percentage_page.dart';
import 'discount/discount_page.dart';
import 'split_bill/split_bill_page.dart';
import 'statistics/statistics_page.dart';
import 'unit_converter/unit_converter_page.dart';
import 'temperature_converter/temperature_converter_page.dart';
import 'timer/timer_page.dart';
import 'stopwatch/stopwatch_page.dart';
import 'date_difference/date_difference_page.dart';
import 'date_converter/date_converter_page.dart';
import 'countdown/countdown_page.dart';
import 'password_generator/password_generator_page.dart';
import 'qr_generator/qr_generator_page.dart';
import 'qr_scanner/qr_scanner_page.dart';
import 'text_counter/text_counter_page.dart';
import 'text_cleaner/text_cleaner_page.dart';
import 'text_case_converter/text_case_converter_page.dart';
import 'area_calculator/area_calculator_page.dart';
import 'quick_note/quick_note_page.dart';
import 'random_picker/random_picker_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => ToolsPageState();
}

class ToolsPageState extends State<ToolsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _searchText = '';
  ToolCategory? _selectedCategory;

  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesStorage.getFavorites();

    if (!mounted) return;

    setState(() {
      _favoriteIds = favorites;
    });
  }

  Future<void> reloadFavorites() async {
    await _loadFavorites();
  }

  Future<void> _toggleFavorite(KavehTool tool) async {
    final isFavorite = _favoriteIds.contains(tool.id);

    setState(() {
      if (isFavorite) {
        _favoriteIds.remove(tool.id);
      } else {
        _favoriteIds.add(tool.id);
      }
    });

    await FavoritesStorage.setFavorite(
      tool.id,
      !isFavorite,
    );
  }

  /// این متد از MainNavigation صدا زده می‌شود.
  void openSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchFocusNode.requestFocus();
    });
  }

  /// این متد برای باز کردن ابزارها روی یک دسته‌بندی مشخص است.
  void openCategory(ToolCategory category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _searchText = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<KavehTool> get _filteredTools {
    final query = _searchText.trim().toLowerCase();

    return ToolRegistry.all.where((tool) {
      final matchesCategory =
          _selectedCategory == null ||
              tool.category == _selectedCategory;

      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        tool.title,
        tool.subtitle,
        ...tool.keywords,
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  void _openTool(
      BuildContext context,
      KavehTool tool,
      ) {
    if (tool.type == ToolType.calculator) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CalculatorPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.percentage) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PercentagePage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.discount) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DiscountPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.splitBill) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SplitBillPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.statistics) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const StatisticsPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.unitConverter) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const UnitConverterPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.temperatureConverter) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TemperatureConverterPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.timer) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TimerPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.stopwatch) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const StopwatchPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.dateDifference) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DateDifferencePage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.dateConverter) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DateConverterPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.countdown) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CountdownPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.passwordGenerator) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PasswordGeneratorPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.qrGenerator) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QrGeneratorPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.qrScanner) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QrScannerPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.textCounter) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TextCounterPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.textCleaner) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TextCleanerPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.textCaseConverter) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TextCaseConverterPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.areaCalculator) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AreaCalculatorPage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.quickNote) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QuickNotePage(),
        ),
      );
      return;
    }

    if (tool.type == ToolType.randomPicker) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const RandomPickerPage(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tool.title} به‌زودی آماده می‌شود',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tools = _filteredTools;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ابزارها',
                          style: AppTypography.headline,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'هر چیزی که برای کارهای روزمره نیاز داری',
                          style: AppTypography.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.gold,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'جستجوی ابزار...',
                  hintStyle:
                  AppTypography.bodySecondary,

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.gold,
                  ),

                  suffixIcon:
                  _searchText.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchText = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color:
                      AppColors.textSecondary,
                    ),
                  )
                      : null,

                  filled: true,
                  fillColor: AppColors.surface,

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      title: 'همه',
                      selected:
                      _selectedCategory == null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'محاسبات',
                      selected:
                      _selectedCategory ==
                          ToolCategory.calculation,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.calculation;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'مالی',
                      selected:
                      _selectedCategory ==
                          ToolCategory.finance,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.finance;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'تبدیل',
                      selected:
                      _selectedCategory ==
                          ToolCategory.conversion,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.conversion;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'زمان',
                      selected:
                      _selectedCategory ==
                          ToolCategory.time,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.time;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'امنیت',
                      selected:
                      _selectedCategory ==
                          ToolCategory.security,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.security;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'متن',
                      selected:
                      _selectedCategory ==
                          ToolCategory.text,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.text;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'اندازه‌گیری',
                      selected:
                      _selectedCategory ==
                          ToolCategory.measurement,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.measurement;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'شخصی',
                      selected:
                      _selectedCategory ==
                          ToolCategory.personal,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.personal;
                        });
                      },
                    ),
                    _CategoryChip(
                      title: 'سرگرمی',
                      selected:
                      _selectedCategory ==
                          ToolCategory.fun,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              ToolCategory.fun;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              14,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'همه ابزارها',
                      style: AppTypography.subtitle,
                    ),
                  ),
                  Text(
                    '${tools.length} ابزار',
                    style:
                    AppTypography.caption.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (tools.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        color:
                        AppColors.textSecondary,
                        size: 46,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'ابزاری پیدا نشد',
                        style: AppTypography.title,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'عبارت دیگری را امتحان کن.',
                        style:
                        AppTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                100,
              ),
              sliver: SliverGrid(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    final tool = tools[index];

                    return _ToolCard(
                      tool: tool,
                      isFavorite:
                      _favoriteIds.contains(
                        tool.id,
                      ),
                      onFavoriteTap: () {
                        _toggleFavorite(tool);
                      },
                      onTap: () {
                        _openTool(
                          context,
                          tool,
                        );
                      },
                    );
                  },
                  childCount: tools.length,
                ),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final KavehTool tool;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _ToolCard({
    required this.tool,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor:
        AppColors.gold.withValues(alpha: 0.10),
        highlightColor:
        AppColors.gold.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                      AppColors.surfaceElevated,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Text(
                      tool.icon,
                      style: const TextStyle(
                        fontSize: 21,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavoriteTap,
                      borderRadius:
                      BorderRadius.circular(12),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 22,
                          color: isFavorite
                              ? AppColors.gold
                              : AppColors
                              .textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                tool.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                AppTypography.subtitle.copyWith(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                tool.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 8),
      child: Material(
        color: selected
            ? AppColors.gold.withValues(
          alpha: 0.12,
        )
            : AppColors.surface,
        borderRadius:
        BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(13),
          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(13),
              border: Border.all(
                color: selected
                    ? AppColors.gold.withValues(
                  alpha: 0.45,
                )
                    : AppColors.border,
              ),
            ),
            child: Text(
              title,
              style:
              AppTypography.caption.copyWith(
                color: selected
                    ? AppColors.goldBright
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}