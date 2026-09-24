import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/navigation/main_navigation.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashPage({
    super.key,
    this.onFinished,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _contentFadeAnimation;
  late final Animation<double> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // ورود لوگو
    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.28,
        curve: Curves.easeOut,
      ),
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.34,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // ورود متن‌ها کمی بعد از لوگو
    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.20,
        0.50,
        curve: Curves.easeOut,
      ),
    );

    _contentSlideAnimation = Tween<double>(
      begin: 18.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.20,
          0.52,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!mounted) return;

      if (widget.onFinished != null) {
        widget.onFinished!();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 45,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/kaveh_logo.png',
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _contentFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            _contentSlideAnimation.value,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'جعبه ابزار کاوه',
                          style: AppTypography.display,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'سازنده و کارآمد',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.goldBright,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 34),

                        const _LoadingIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                children: [
                  Text(
                    'کاری از تیم داتین آریا',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return SizedBox(
          width: 52,
          height: 18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (index) {
                final delay = index * 0.18;

                double value =
                    (_loadingController.value - delay) % 1.0;

                if (value < 0) {
                  value += 1.0;
                }

                final scale = 0.65 +
                    (0.35 *
                        (1 -
                            (value - 0.5).abs() * 2)
                            .clamp(0.0, 1.0));

                final opacity = 0.35 +
                    (0.65 *
                        (1 -
                            (value - 0.5).abs() * 2)
                            .clamp(0.0, 1.0));

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}