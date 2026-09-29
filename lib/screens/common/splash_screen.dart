import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _hasNavigated = false;

  late final AnimationController _headerController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;

  late final AnimationController _exitController;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart)),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/Splash.mp4');
      await _videoController!.initialize();
      
      if (!mounted) return;

      setState(() {
        _isVideoReady = true;
      });

      _videoController!.setVolume(0.0);
      _videoController!.play();
      _headerController.forward();

      _videoController!.addListener(_onVideoTick);

      final duration = _videoController!.value.duration;
      final timeout = duration.inMilliseconds > 0 ? duration + const Duration(milliseconds: 500) : const Duration(seconds: 4);
      
      Future.delayed(timeout, () {
        if (!_hasNavigated && mounted) {
          _triggerExit();
        }
      });
    } catch (e) {
      debugPrint('Error loading splash video: $e');
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), _navigateNext);
      }
    }
  }

  void _onVideoTick() {
    if (_videoController == null || !mounted) return;
    
    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;
    
    if (duration > Duration.zero && position >= duration - const Duration(milliseconds: 300)) {
      _videoController!.removeListener(_onVideoTick);
      _triggerExit();
    }
  }

  void _triggerExit() {
    if (_hasNavigated || !mounted) return;
    // DO NOT PAUSE! Let the video play its final milliseconds naturally 
    // while the fade transition overlaps it. This prevents the abrupt stutter/halt.
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    try {
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
        return;
      } 
      
      // Attempt to read from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (hasSeenOnboarding) {
        context.go('/customer');
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      debugPrint('Navigation error (likely missing native plugin): $e');
      // Failsafe fallback if plugin crashes
      context.go('/customer');
    }
  }

  @override
  void dispose() {
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
          if (_isVideoReady && controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _headerOpacity.value,
                      child: Transform.translate(
                        offset: _headerSlide.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, color: Theme.of(context).primaryColor, size: 40),
                          const SizedBox(width: 12),
                          Text(
                            'HarvestHub',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Direct from farm to your table.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
