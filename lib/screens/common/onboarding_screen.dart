import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  /// Tracks whether onboarding has already been completed or skipped in the current session
  /// so returning/authenticated users are not forced through onboarding repeatedly.
  static bool hasSeenOnboarding = false;

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlideData {
  final String badge;
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;
  final String imageAsset;
  final Color haloColor;

  const _OnboardingSlideData({
    required this.badge,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
    required this.imageAsset,
    required this.haloColor,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _floatController;
  int _currentIndex = 0;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      badge: 'DIRECT FROM FARMS',
      titlePrefix: 'Fresh From ',
      titleHighlight: 'Local Fields',
      subtitle:
          'Handpicked vegetables, fruits, dairy, and grains harvested daily by local farmers with zero middlemen.',
      imageAsset: 'assets/images/onboarding_farm.png',
      haloColor: Color(0xFFD8F3DC),
    ),
    _OnboardingSlideData(
      badge: 'UNIFIED MARKETPLACE',
      titlePrefix: 'Multiple Farms, ',
      titleHighlight: 'One Hub',
      subtitle:
          'Browse produce from dozens of verified local farms in one trusted marketplace with fair farm-gate pricing.',
      imageAsset: 'assets/images/onboarding_marketplace.png',
      haloColor: Color(0xFFD0F0D6),
    ),
    _OnboardingSlideData(
      badge: 'HARVEST TO HANDOVER',
      titlePrefix: 'Swift Doorstep ',
      titleHighlight: 'Handover',
      subtitle:
          'Carefully packed at our central hub and delivered straight to your doorstep at peak farm freshness.',
      imageAsset: 'assets/images/onboarding_delivery.png',
      haloColor: Color(0xFFD6F2DA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _handleSkipToGuestHome() {
    OnboardingScreen.hasSeenOnboarding = true;
    context.go('/customer');
  }

  void _handleGetStartedAuth() {
    OnboardingScreen.hasSeenOnboarding = true;
    context.go('/role_selection');
  }

  void _handleNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastSlide = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF43B251),
              Color(0xFF6BC476),
              Color(0xFFBFE6C4),
              Color(0xFFEAF6EC),
              Color(0xFFF9FBF9),
              Color(0xFFF9FBF9),
            ],
            stops: [0.00, 0.14, 0.28, 0.44, 0.62, 1.00],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Step Indicator on Left + Skip Button on Right
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '0${_currentIndex + 1} / 0${_slides.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleSkipToGuestHome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: TextStyle(
                                color: Color(0xFF1F3823),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF38A745),
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main 3D PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentIndex = idx;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Floating 3D Diorama Stage with Soft Glow Pedestal
                          Expanded(
                            flex: 6,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  final double dy = math.sin(
                                        _floatController.value * math.pi,
                                      ) *
                                      8.0;
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Ambient soft mint glow behind 3D island
                                      Container(
                                        width: 260,
                                        height: 260,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              slide.haloColor.withValues(
                                                alpha: 0.85,
                                              ),
                                              slide.haloColor.withValues(
                                                alpha: 0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Ground contact shadow oval
                                      Positioned(
                                        bottom: 18,
                                        child: Transform.scale(
                                          scale: 1.0 -
                                              (_floatController.value * 0.06),
                                          child: Container(
                                            width: 170,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF1D4D25,
                                                  ).withValues(alpha: 0.16),
                                                  blurRadius: 22,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Floating 3D Cutout Illustration
                                      Transform.translate(
                                        offset: Offset(0, -dy),
                                        child: child,
                                      ),
                                    ],
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    slide.imageAsset,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Editorial Typography Card Area
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                // Eyebrow Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5F6E7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFBDE5C3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    slide.badge,
                                    style: const TextStyle(
                                      color: Color(0xFF238A30),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Two-Tone Headline
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        height: 1.18,
                                        letterSpacing: -0.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: slide.titlePrefix,
                                          style: const TextStyle(
                                            color: Color(0xFF18241A),
                                          ),
                                        ),
                                        TextSpan(
                                          text: slide.titleHighlight,
                                          style: const TextStyle(
                                            color: Color(0xFF238A30),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    slide.subtitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF5A6B5D),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w400,
                                      height: 1.48,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Controls: Page Dots + Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Pill Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final bool active = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 26 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF43B251)
                                : const Color(0xFFCFE3D2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 22),

                    // Slide 1 & 2: Single "Next" Button
                    // Slide 3 (Last Slide): Both "Skip" (Guest) & "Get Started" (Login/Register) Buttons
                    if (!isLastSlide)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43B251),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          // 1. Skip Button (Explore as Guest without login/register)
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: _handleSkipToGuestHome,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF28462E),
                                  backgroundColor: const Color(0xFFEDF7EE),
                                  side: const BorderSide(
                                    color: Color(0xFFBFE2C4),
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 2. Get Started Button (Proceed to Role Selection / Sign In / Register)
                          Expanded(
                            flex: 6,
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _handleGetStartedAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF43B251),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
