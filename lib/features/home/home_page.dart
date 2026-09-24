import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/storage/favorites_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/home_banners.dart';
import '../../data/tool_registry.dart';
import '../../models/tool.dart';
import '../settings/settings_page.dart';

import '../tools/calculator/calculator_page.dart';
import '../tools/percentage/percentage_page.dart';
import '../tools/discount/discount_page.dart';
import '../tools/split_bill/split_bill_page.dart';
import '../tools/statistics/statistics_page.dart';
import '../tools/unit_converter/unit_converter_page.dart';
import '../tools/temperature_converter/temperature_converter_page.dart';
import '../tools/timer/timer_page.dart';
import '../tools/stopwatch/stopwatch_page.dart';
import '../tools/date_difference/date_difference_page.dart';
import '../tools/date_converter/date_converter_page.dart';
import '../tools/countdown/countdown_page.dart';
import '../tools/password_generator/password_generator_page.dart';
import '../tools/qr_generator/qr_generator_page.dart';
import '../tools/qr_scanner/qr_scanner_page.dart';
import '../tools/text_counter/text_counter_page.dart';
import '../tools/text_cleaner/text_cleaner_page.dart';
import '../tools/text_case_converter/text_case_converter_page.dart';
import '../tools/area_calculator/area_calculator_page.dart';
import '../tools/quick_note/quick_note_page.dart';
import '../tools/random_picker/random_picker_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final ValueChanged<ToolCategory>? onCategoryTap;

  const HomePage({
    super.key,
    this.onSearchTap,
    this.onCategoryTap,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();

  Timer? _bannerTimer;
  int _currentBanner = 0;

  Set<String> _favoriteIds = {};
  bool _favoritesLoading = true;

  List<HomeBannerData> get _banners => HomeBanners.all;

  @override
  void initState() {
    super.initState();

    reloadFavorites();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!_bannerController.hasClients) return;
        if (_banners.isEmpty) return;

        final nextPage =
            (_currentBanner + 1) % _banners.length;

        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> reloadFavorites() async {
    final favorites =
    await FavoritesStorage.getFavorites();

    if (!mounted) return;

    setState(() {
      _favoriteIds = favorites;
      _favoritesLoading = false;
    });
  }

  List<KavehTool> get _favoriteTools {
    return ToolRegistry.all
        .where(
          (tool) => _favoriteIds.contains(tool.id),
    )
        .take(6)
        .toList();
  }

  void _openTool(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  void _openFavoriteTool(
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

    _openTool(context, page);
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsPage(),
      ),
    );
  }

  void _openBanner(
      BuildContext context,
      HomeBannerData banner,
      ) {
    _openTool(
      context,
      banner.buildDestination(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 20),

              _buildSearch(),

              const SizedBox(height: 24),

              _buildBannerSection(),

              const SizedBox(height: 28),

              if (!_favoritesLoading &&
                  _favoriteTools.isNotEmpty) ...[
                _buildFavoriteSection(),

                const SizedBox(height: 30),
              ],

              _buildSectionTitle(
                title: 'ابزارهای سریع',
                subtitle:
                'کارهای روزمره، سریع‌تر از همیشه',
              ),

              const SizedBox(height: 14),

              _buildQuickTools(),

              const SizedBox(height: 30),

              _buildSectionTitle(
                title: 'دسته‌بندی ابزارها',
                subtitle:
                'هر چیزی که لازم داری، یکجا',
              ),

              const SizedBox(height: 14),

              _buildCategories(),

              const SizedBox(height: 30),

              _buildKavehCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/kaveh_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return const Center(
                child: Text(
                  'کاوه',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 13),

        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'سلام 👋',
                style: AppTypography.headline,
              ),
              SizedBox(height: 4),
              Text(
                'امروز چه کمکی از کاوه می‌خوای؟',
                style: AppTypography.bodySecondary,
              ),
            ],
          ),
        ),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openSettings(context),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSearchTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.gold,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'کاوه چه کاری برات انجام بده؟',
                  style:
                  AppTypography.bodySecondary,
                ),
              ),

              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDisabled,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 7,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                _currentBanner = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];

              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 1,
                ),
                child: _BannerCard(
                  data: banner,
                  onTap: () => _openBanner(
                    context,
                    banner,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 11),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
                (index) {
              final selected =
                  index == _currentBanner;

              return AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                width: selected ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.gold
                      : AppColors.border,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteSection() {
    final favorites = _favoriteTools;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '⭐ ابزارهای محبوب',
                    style: AppTypography.title,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ابزارهایی که خودت انتخاب کردی',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // تب علاقه‌مندی‌ها از طریق
                  // BottomNavigation قابل دسترسی است.
                },
                borderRadius:
                BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 138,
          child: ListView.separated(
            physics:
            const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tool = favorites[index];

              return _FavoriteMiniCard(
                tool: tool,
                onTap: () {
                  _openFavoriteTool(
                    context,
                    tool,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTools() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToolCard(
                icon: '🧮',
                title: 'ماشین‌حساب',
                subtitle: 'محاسبات سریع',
                onTap: () => _openTool(
                  context,
                  const CalculatorPage(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _ToolCard(
                icon: '%',
                title: 'درصد',
                subtitle: 'محاسبه درصد',
                onTap: () => _openTool(
                  context,
                  const PercentagePage(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ToolCard(
                icon: '🏷️',
                title: 'تخفیف',
                subtitle: 'قیمت نهایی',
                onTap: () => _openTool(
                  context,
                  const DiscountPage(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _ToolCard(
                icon: '⏱️',
                title: 'تایمر',
                subtitle: 'زمان‌سنج',
                onTap: () => _openTool(
                  context,
                  const TimerPage(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 48,
      child: ListView(
        physics:
        const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            icon: '🧮',
            title: 'محاسبات',
            category:
            ToolCategory.calculation,
            selected: true,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '💰',
            title: 'مالی',
            category:
            ToolCategory.finance,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '🔄',
            title: 'تبدیل',
            category:
            ToolCategory.conversion,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '⏱️',
            title: 'زمان',
            category: ToolCategory.time,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '📝',
            title: 'متن',
            category: ToolCategory.text,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '📏',
            title: 'اندازه‌گیری',
            category:
            ToolCategory.measurement,
            onTap: widget.onCategoryTap,
          ),

          const SizedBox(width: 8),

          _CategoryChip(
            icon: '🔐',
            title: 'امنیت',
            category: ToolCategory.security,
            onTap: widget.onCategoryTap,
          ),
        ],
      ),
    );
  }

  Widget _buildKavehCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: const Center(
              child: Text(
                '✨',
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'کاوه همیشه آماده‌ست',
                  style: AppTypography.subtitle,
                ),
                SizedBox(height: 5),
                Text(
                  'هر ابزاری لازم داری، همین‌جا پیداش می‌کنی.',
                  style:
                  AppTypography.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBannerData data;
  final VoidCallback onTap;

  const _BannerCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(23),
            child: Image.asset(
              data.imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Center(
                  child: Icon(
                    Icons
                        .image_not_supported_outlined,
                    color:
                    AppColors.textDisabled,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteMiniCard extends StatelessWidget {
  final KavehTool tool;
  final VoidCallback onTap;

  const _FavoriteMiniCard({
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Ink(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                      AppColors.surfaceElevated,
                      borderRadius:
                      BorderRadius.circular(13),
                    ),
                    child: Text(
                      tool.icon,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.gold,
                    size: 19,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                tool.title,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                AppTypography.subtitle.copyWith(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                tool.subtitle,
                maxLines: 1,
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

class _ToolCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(20),
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color:
                  AppColors.surfaceElevated,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style:
                    const TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              Text(
                title,
                style:
                AppTypography.subtitle,
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style:
                AppTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String title;
  final ToolCategory category;
  final bool selected;
  final ValueChanged<ToolCategory>?
  onTap;

  const _CategoryChip({
    required this.icon,
    required this.title,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            onTap?.call(category),
        borderRadius:
        BorderRadius.circular(15),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.gold.withValues(
              alpha: 0.12,
            )
                : AppColors.surface,
            borderRadius:
            BorderRadius.circular(15),
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
              Text(
                icon,
                style:
                const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                title,
                style:
                AppTypography.bodySecondary
                    .copyWith(
                  color: selected
                      ? AppColors.goldBright
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}