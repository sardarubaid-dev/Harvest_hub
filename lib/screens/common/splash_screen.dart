import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../providers/auth_provider.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late final AnimationController _headerController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;

  late final AnimationController _exitController;
  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;

  bool _isVideoReady = false;
  bool _isExiting = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _headerOpacity = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _exitFade = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOutCubic,
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _initSplashVideo();
  }

  Future<void> _initSplashVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/Splash.mp4',
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );
    _videoController = controller;

    _safetyTimer = Timer(const Duration(milliseconds: 6000), _startSmoothExit);

    try {
      await controller.initialize();
      await controller.setVolume(0.0);
      await controller.setLooping(false);
      controller.addListener(_onVideoTick);

      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
        await controller.play();
        _headerController.forward();
      }
    } catch (_) {
      _headerController.forward();
      Timer(const Duration(milliseconds: 1600), _startSmoothExit);
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || _isExiting) {
      return;
    }
    final position = controller.value.position;
    final duration = controller.value.duration;

    // Trigger the smooth cross-dissolve 480ms before the end of the video
    // while the 3D camera is still moving, avoiding any end-of-stream freeze.
    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 480)) {
      _startSmoothExit();
    }
  }

  Future<void> _startSmoothExit() async {
    if (_isExiting || !mounted) return;
    _isExiting = true;
    _safetyTimer?.cancel();

    await _exitController.forward();
    _navigateNext();
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (authProvider.isAuthenticated && user != null) {
      if (user.isAdmin) {
        context.go('/admin/dashboard');
      } else if (user.isFarmer) {
        context.go('/farmer/dashboard');
      } else {
        context.go('/customer');
      }
    } else if (OnboardingScreen.hasSeenOnboarding) {
      context.go('/customer');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _headerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F3),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Hardware-Accelerated 3D Video Canvas with Smooth Exit Scale
          if (_isVideoReady && controller != null)
            AnimatedBuilder(
              animation: _exitScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _exitScale.value,
                  child: child,
                );
              },
              child: RepaintBoundary(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
            ),

          // 2. Soft Translucent Sky Feather & Editorial Top Branding (Zero Emojis)
          // Confined strictly to the top sky zone so the 3D scene remains 100% unobstructed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6F6FAF5),
                    Color(0xB3F6FAF5),
                    Color(0x00F6FAF5),
                  ],
                  stops: [0.0, 0.62, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  child: FadeTransition(
                    opacity: _headerOpacity,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F5E7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFBFE2C4),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'FARM  •  MARKETPLACE  •  DOORSTEP',
                              style: TextStyle(
                                color: Color(0xFF21802D),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Harvest',
                                  style: TextStyle(color: Color(0xFF162418)),
                                ),
                                TextSpan(
                                  text: 'Hub',
                                  style: TextStyle(color: Color(0xFF238A30)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Direct from local fields to your table',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4C5F50),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Seamless Exit Cross-Dissolve Veil into Next Screen's Exact Theme Gradient
          IgnorePointer(
            child: FadeTransition(
              opacity: _exitFade,
              child: Container(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
