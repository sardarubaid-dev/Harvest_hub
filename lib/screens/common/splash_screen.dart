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

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
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

    // Safety fallback so the screen never hangs if hardware decoder is busy
    _safetyTimer = Timer(const Duration(milliseconds: 6000), _navigateNext);

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
      }
    } catch (_) {
      Timer(const Duration(milliseconds: 1200), _navigateNext);
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || _hasNavigated) {
      return;
    }
    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 60)) {
      _navigateNext();
    }
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F3),
      body: _isVideoReady && controller != null
          ? RepaintBoundary(
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
            )
          : const ColoredBox(
              color: Color(0xFFF3F8F3),
              child: SizedBox.expand(),
            ),
    );
  }
}
