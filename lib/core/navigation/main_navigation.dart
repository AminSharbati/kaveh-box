import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/favorites_storage.dart';
import '../../data/tool_registry.dart';
import '../../models/tool.dart';

import '../../features/home/home_page.dart';
import '../../features/tools/tools_page.dart';

import '../../features/tools/calculator/calculator_page.dart';
import '../../features/tools/percentage/percentage_page.dart';
import '../../features/tools/discount/discount_page.dart';
import '../../features/tools/split_bill/split_bill_page.dart';
import '../../features/tools/statistics/statistics_page.dart';
import '../../features/tools/unit_converter/unit_converter_page.dart';
import '../../features/tools/temperature_converter/temperature_converter_page.dart';
import '../../features/tools/timer/timer_page.dart';
import '../../features/tools/stopwatch/stopwatch_page.dart';
import '../../features/tools/date_difference/date_difference_page.dart';
import '../../features/tools/date_converter/date_converter_page.dart';
import '../../features/tools/countdown/countdown_page.dart';
import '../../features/tools/password_generator/password_generator_page.dart';
import '../../features/tools/qr_generator/qr_generator_page.dart';
import '../../features/tools/qr_scanner/qr_scanner_page.dart';
import '../../features/tools/text_counter/text_counter_page.dart';
import '../../features/tools/text_cleaner/text_cleaner_page.dart';
import '../../features/tools/text_case_converter/text_case_converter_page.dart';
import '../../features/tools/area_calculator/area_calculator_page.dart';
import '../../features/tools/quick_note/quick_note_page.dart';
import '../../features/tools/random_picker/random_picker_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final GlobalKey<HomePageState> _homeKey =
  GlobalKey<HomePageState>();

  final GlobalKey<ToolsPageState> _toolsKey =
  GlobalKey<ToolsPageState>();

  final GlobalKey<FavoritesPageState> _favoritesKey =
  GlobalKey<FavoritesPageState>();

  void _openToolSearch() {
    setState(() {
      _currentIndex = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toolsKey.currentState?.openSearch();
    });
  }

  void _openToolCategory(ToolCategory category) {
    _toolsKey.currentState?.openCategory(category);

    if (_currentIndex != 1) {
      setState(() {
        _currentIndex = 1;
      });
    }
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _homeKey.currentState?.reloadFavorites();
      });
    }

    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toolsKey.currentState?.reloadFavorites();
      });
    }

    if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _favoritesKey.currentState?.reloadFavorites();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        key: _homeKey,
        onSearchTap: _openToolSearch,
        onCategoryTap: _openToolCategory,
      ),

      ToolsPage(
        key: _toolsKey,
      ),

      FavoritesPage(
        key: _favoritesKey,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: _BottomNavigation(
          currentIndex: _currentIndex,
          onItemTapped: _changeTab,
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _BottomNavigation({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                title: 'خانه',
                selected: currentIndex == 0,
                onTap: () => onItemTapped(0),
              ),

              _NavItem(
                icon: Icons.apps_rounded,
                title: 'ابزارها',
                selected: currentIndex == 1,
                onTap: () => onItemTapped(1),
              ),

              _NavItem(
                icon: Icons.star_rounded,
                title: 'علاقه‌مندی‌ها',
                selected: currentIndex == 2,
                onTap: () => onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? AppColors.gold
                  : AppColors.textSecondary,
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: selected
                    ? AppColors.gold
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() =>
      FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  Set<String> _favoriteIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    reloadFavorites();
  }

  Future<void> reloadFavorites() async {
    final favorites =
    await FavoritesStorage.getFavorites();

    if (!mounted) return;

    setState(() {
      _favoriteIds = favorites;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(
      KavehTool tool,
      ) async {
    await FavoritesStorage.setFavorite(
      tool.id,
      false,
    );

    if (!mounted) return;

    setState(() {
      _favoriteIds.remove(tool.id);
    });
  }

  List<KavehTool> get _favoriteTools {
    return ToolRegistry.all
        .where(
          (tool) => _favoriteIds.contains(tool.id),
    )
        .toList();
  }

  void _openTool(
      BuildContext context,
      KavehTool tool,
      ) {
    Widget? page;

    switch (tool.type) {
      case ToolType.calculator:
        page = const CalculatorPage();
        break;

      case ToolType.percentage:
        page = const PercentagePage();
        break;

      case ToolType.discount:
        page = const DiscountPage();
        break;

      case ToolType.splitBill:
        page = const SplitBillPage();
        break;

      case ToolType.statistics:
        page = const StatisticsPage();
        break;

      case ToolType.unitConverter:
        page = const UnitConverterPage();
        break;

      case ToolType.temperatureConverter:
        page = const TemperatureConverterPage();
        break;

      case ToolType.timer:
        page = const TimerPage();
        break;

      case ToolType.stopwatch:
        page = const StopwatchPage();
        break;

      case ToolType.dateDifference:
        page = const DateDifferencePage();
        break;

      case ToolType.dateConverter:
        page = const DateConverterPage();
        break;

      case ToolType.countdown:
        page = const CountdownPage();
        break;

      case ToolType.passwordGenerator:
        page = const PasswordGeneratorPage();
        break;

      case ToolType.qrGenerator:
        page = const QrGeneratorPage();
        break;

      case ToolType.qrScanner:
        page = const QrScannerPage();
        break;

      case ToolType.textCounter:
        page = const TextCounterPage();
        break;

      case ToolType.textCleaner:
        page = const TextCleanerPage();
        break;

      case ToolType.textCaseConverter:
        page = const TextCaseConverterPage();
        break;

      case ToolType.areaCalculator:
        page = const AreaCalculatorPage();
        break;

      case ToolType.quickNote:
        page = const QuickNotePage();
        break;

      case ToolType.randomPicker:
        page = const RandomPickerPage();
        break;
    }

    if (page == null) return;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => page!,
      ),
    )
        .then((_) {
      reloadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteTools = _favoriteTools;

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'علاقه‌مندی‌ها',
                          style:
                          AppTypography.headline,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'ابزارهایی که بیشتر دوستشان داری',
                          style:
                          AppTypography.bodySecondary,
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
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                ),
              ),
            )
          else if (favoriteTools.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_border_rounded,
                        color:
                        AppColors.textSecondary,
                        size: 58,
                      ),

                      SizedBox(height: 16),

                      Text(
                        'هنوز چیزی به علاقه‌مندی‌ها اضافه نکردی',
                        textAlign:
                        TextAlign.center,
                        style:
                        AppTypography.title,
                      ),

                      SizedBox(height: 8),

                      Text(
                        'از صفحه ابزارها روی ستاره هر ابزار بزن.',
                        textAlign:
                        TextAlign.center,
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
                24,
                20,
                100,
              ),
              sliver: SliverGrid(
                delegate:
                SliverChildBuilderDelegate(
                      (context, index) {
                    final tool =
                    favoriteTools[index];

                    return _FavoriteToolCard(
                      tool: tool,
                      onTap: () {
                        _openTool(
                          context,
                          tool,
                        );
                      },
                      onRemove: () {
                        _removeFavorite(tool);
                      },
                    );
                  },
                  childCount:
                  favoriteTools.length,
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

class _FavoriteToolCard extends StatelessWidget {
  final KavehTool tool;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteToolCard({
    required this.tool,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
                      onTap: onRemove,
                      borderRadius:
                      BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.star_rounded,
                          size: 22,
                          color: AppColors.gold,
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
                overflow:
                TextOverflow.ellipsis,
                style:
                AppTypography.subtitle.copyWith(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                tool.subtitle,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}