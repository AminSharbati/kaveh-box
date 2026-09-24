import 'package:flutter/material.dart';

import '../features/tools/calculator/calculator_page.dart';
import '../features/tools/discount/discount_page.dart';
import '../features/tools/timer/timer_page.dart';

enum HomeBannerAction {
  calculator,
  discount,
  timer,
}

class HomeBannerData {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final HomeBannerAction action;

  const HomeBannerData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.action,
  });

  Widget buildDestination() {
    switch (action) {
      case HomeBannerAction.calculator:
        return const CalculatorPage();

      case HomeBannerAction.discount:
        return const DiscountPage();

      case HomeBannerAction.timer:
        return const TimerPage();
    }
  }
}

abstract final class HomeBanners {
  static const List<HomeBannerData> all = [
    HomeBannerData(
      imagePath: 'assets/banners/banner_01.png',
      title: 'محاسباتت رو بسپار به کاوه',
      subtitle: 'سریع، ساده و همیشه در دسترس',
      buttonText: 'ماشین‌حساب',
      action: HomeBannerAction.calculator,
    ),
    HomeBannerData(
      imagePath: 'assets/banners/banner_02.png',
      title: 'قبل از خرید حساب کن!',
      subtitle: 'قیمت نهایی و مقدار تخفیف رو سریع پیدا کن',
      buttonText: 'محاسبه تخفیف',
      action: HomeBannerAction.discount,
    ),
    HomeBannerData(
      imagePath: 'assets/banners/banner_03.png',
      title: 'زمان رو مدیریت کن',
      subtitle: 'تایمر کاوه برای کارهای روزمره آماده‌ست',
      buttonText: 'شروع تایمر',
      action: HomeBannerAction.timer,
    ),
  ];
}