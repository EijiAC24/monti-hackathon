import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_profile.dart';
import '../../shared/theme/app_theme.dart';
import '../profile/profile_provider.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  ConsumerState<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;
  late final AnimationController _ringController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _shakeAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // Ring pulse for answer button
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _playRingtone();
  }

  Future<void> _playRingtone() async {
    await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
    await _ringtonePlayer.play(AssetSource('sounds/ringtone.mp3'));
  }

  Future<void> _answerCall() async {
    await _ringtonePlayer.stop();
    final connectPlayer = AudioPlayer();
    await connectPlayer.play(AssetSource('sounds/call_connect.mp3'));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    connectPlayer.dispose();

    if (mounted) context.go('/conversation');
  }

  @override
  void dispose() {
    _ringtonePlayer.stop();
    _ringtonePlayer.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(childProfileProvider);
    final nickname = profile?.nickname ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.callGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Animated character
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_pulseAnimation, _shakeAnimation]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: profile?.characterImage != null
                              ? ClipOval(
                                  child: Image.memory(
                                    profile!.characterImage!,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ChildProfile.assetForEmoji(
                                          profile?.emoji ?? '🐻') !=
                                      null
                                  ? ClipOval(
                                      child: Image.asset(
                                        ChildProfile.assetForEmoji(
                                            profile?.emoji ?? '🐻')!,
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                          profile?.emoji ?? '🐻',
                                          style: const TextStyle(
                                              fontSize: 80)),
                                    ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Caller name
                Text(
                  profile?.displayName ?? 'Monty',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.incomingCallCalling(nickname),
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                ),

                const Spacer(flex: 3),

                // Answer button with ring pulse
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Expanding ring
                      AnimatedBuilder(
                        animation: _ringAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 88 + (_ringAnimation.value * 40),
                            height: 88 + (_ringAnimation.value * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                    alpha: 0.4 *
                                        (1 - _ringAnimation.value)),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      // Button
                      GestureDetector(
                        onTap: _answerCall,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.glow(
                                color: AppColors.secondary),
                          ),
                          child: const Icon(
                            Icons.phone_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.incomingCallAnswer,
                  style:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                          ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
