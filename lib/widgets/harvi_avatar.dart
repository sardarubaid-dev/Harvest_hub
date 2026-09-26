import 'dart:math';

import 'package:flutter/material.dart';

enum HarviExpression { idle, greeting, thinking, talking, error }

class HarviAvatar extends StatefulWidget {
  final HarviExpression expression;
  final double size;

  const HarviAvatar({Key? key, required this.expression, this.size = 80.0})
    : super(key: key);

  @override
  State<HarviAvatar> createState() => _HarviAvatarState();
}

class _HarviAvatarState extends State<HarviAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _wobbleController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseController.repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _applyExpression(widget.expression);
  }

  @override
  void didUpdateWidget(covariant HarviAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression) {
      _applyExpression(widget.expression);
    }
  }

  void _applyExpression(HarviExpression expr) {
    _bounceController.stop();
    _wobbleController.stop();
    _shakeController.stop();
    _pulseController.duration = const Duration(milliseconds: 1500);
    if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);

    switch (expr) {
      case HarviExpression.idle:
        break;
      case HarviExpression.greeting:
        _bounceController.repeat(reverse: true);
        break;
      case HarviExpression.thinking:
        _wobbleController.repeat(reverse: true);
        break;
      case HarviExpression.talking:
        _pulseController.duration = const Duration(milliseconds: 300);
        _pulseController.repeat(reverse: true);
        break;
      case HarviExpression.error:
        _shakeController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _wobbleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String _getAssetPath() {
    switch (widget.expression) {
      case HarviExpression.idle:
        return 'assets/images/harvi.png';
      case HarviExpression.greeting:
        return 'assets/images/harvi_greeting.png';
      case HarviExpression.thinking:
        return 'assets/images/harvi_thinking.png';
      case HarviExpression.talking:
        return 'assets/images/harvi_talking.png';
      case HarviExpression.error:
        return 'assets/images/harvi_error.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _bounceController,
        _wobbleController,
        _shakeController,
      ]),
      builder: (context, child) {
        double scale = 1.0;
        double dy = 0.0;
        double dx = 0.0;
        double rotation = 0.0;

        if (widget.expression == HarviExpression.idle ||
            widget.expression == HarviExpression.talking) {
          scale = 1.0 + (_pulseController.value * 0.05);
        }

        if (widget.expression == HarviExpression.greeting) {
          dy = -(_bounceController.value * 15.0);
        }

        if (widget.expression == HarviExpression.thinking) {
          rotation = sin(_wobbleController.value * pi) * 0.15;
        }

        if (widget.expression == HarviExpression.error) {
          dx = sin(_shakeController.value * pi * 4) * 8.0;
        }

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // REMOVED color: Colors.white
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: _pulseController.value * 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    // Scale transition hides the misalignment by shrinking the old image and growing the new one!
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                    child: Image.asset(
                      _getAssetPath(),
                      key: ValueKey<String>(_getAssetPath()),
                      fit: BoxFit.cover,
                      width: widget.size,
                      height: widget.size,

                      // MULTIPLY blend mode removes the white background of the JPEG
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
