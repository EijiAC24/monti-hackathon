import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum MontyState { idle, listening, thinking, talking, happy }

class MontyCharacter extends StatefulWidget {
  final MontyState state;
  final double size;
  final String emoji;

  const MontyCharacter({
    super.key,
    this.state = MontyState.idle,
    this.size = 200,
    this.emoji = '🐻',
  });

  @override
  State<MontyCharacter> createState() => _MontyCharacterState();
}

class _MontyCharacterState extends State<MontyCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _breathController;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MontyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == MontyState.happy) {
      _bounceController.repeat(reverse: true);
    } else {
      _bounceController.stop();
      _bounceController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _breathAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _breathAnimation.value,
            child: _buildCharacter(),
          ),
        );
      },
    );
  }

  Widget _buildCharacter() {
    final circleSize = widget.size * 0.75;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: circleSize + 16,
            height: circleSize + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Main circle with gradient
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPale,
                  AppColors.primaryLight.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Text(
            _getFaceEmoji(),
            style: TextStyle(fontSize: widget.size * 0.5),
          ),
        ],
      ),
    );
  }

  String _getFaceEmoji() {
    return switch (widget.state) {
      MontyState.happy => '🎉',
      _ => widget.emoji,
    };
  }
}
