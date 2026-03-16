import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/monty_character.dart';
import '../profile/profile_provider.dart';
import '../scenario/scenario_screen.dart';
import 'conversation_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen>
    with TickerProviderStateMixin {
  bool _sessionStarted = false;
  late final AnimationController _celebrationController;
  late final Animation<double> _celebrationScale;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _celebrationController, curve: Curves.elasticOut),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_sessionStarted) return;
    _sessionStarted = true;

    final profile = ref.read(childProfileProvider);
    final scenario = ref.read(selectedScenarioProvider);

    if (profile == null || scenario == null) {
      context.go('/profile');
      return;
    }

    // Fetch fresh token from Cloud Run token server
    const tokenServerUrl = String.fromEnvironment('TOKEN_SERVER_URL');
    // Fallback to dart-define for local dev
    const fallbackToken = String.fromEnvironment('ACCESS_TOKEN');
    const fallbackProject = String.fromEnvironment('PROJECT_ID');
    const location = String.fromEnvironment('LOCATION', defaultValue: 'us-central1');

    String accessToken;
    String projectId;

    if (tokenServerUrl.isNotEmpty) {
      try {
        final resp = await http.get(Uri.parse('$tokenServerUrl/token'));
        if (resp.statusCode != 200) {
          print('[Monti] Token server error: ${resp.statusCode}');
          return;
        }
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        accessToken = data['access_token'] as String;
        projectId = data['project_id'] as String;
      } catch (e) {
        print('[Monti] Token server unreachable: $e');
        return;
      }
    } else if (fallbackToken.isNotEmpty && fallbackProject.isNotEmpty) {
      accessToken = fallbackToken;
      projectId = fallbackProject;
    } else {
      return;
    }

    final locale = Localizations.localeOf(context);
    await ref.read(conversationProvider.notifier).startSession(
          accessToken: accessToken,
          projectId: projectId,
          location: location,
          profile: profile,
          scenario: scenario,
          languageCode: locale.languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(conversationProvider);

    // Listen for state changes
    ref.listen<ConversationState>(conversationProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        final msg = next.errorMessage == 'mic_required'
            ? l10n.conversationMicRequired
            : next.errorMessage!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        );
      }
      // Play fanfare on goal completion (Cast Ending technique)
      if (next.goalComplete && !(prev?.goalComplete ?? false)) {
        _celebrationController.forward();
        _playFanfare();
      }
    });

    // Celebration screen
    if (state.goalComplete) {
      final emoji = ref.watch(childProfileProvider)?.emoji ?? '🐻';
      return _buildCelebration(context, l10n, emoji);
    }

    // Only show text bubble for connecting or talking states — not listening/thinking
    final displayText = state.currentText.isNotEmpty
        ? state.currentText
        : !state.isConnected
            ? l10n.conversationConnecting
            : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showEndDialog(context, l10n),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(Icons.close_rounded,
                            size: 22,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Character area
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    MontyCharacter(
                      state: state.montyState,
                      size: 220,
                      emoji: ref.watch(childProfileProvider)?.emoji ??
                          '🐻',
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: displayText.isNotEmpty
                          ? Container(
                              key: ValueKey(displayText.hashCode),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 32),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.lg),
                                boxShadow: AppShadows.soft(),
                              ),
                              child: Text(
                                displayText.length > 100
                                    ? displayText.substring(0, 100)
                                    : displayText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20, height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom area
            Expanded(
              flex: 2,
              child: Center(
                child: _StatusIndicator(
                    state: state.montyState,
                    isConnected: state.isConnected,
                    l10n: l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Celebration screen — Cast Ending technique from detail.design
  Widget _buildCelebration(
      BuildContext context, AppLocalizations l10n, String emoji) {
    final floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F0), Color(0xFFFFEDD8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating decorative emojis
              ..._buildFloatingEmojis(floatAnim),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _celebrationScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _celebrationScale.value,
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glow behind emoji (Blur Trick for Optical Fit)
                      AnimatedBuilder(
                        animation: floatAnim,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, floatAnim.value),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.25),
                                blurRadius: 48,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 96)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('🎉',
                          style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 20),
                      // Glow text
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: AppShadows.glow(),
                          borderRadius: BorderRadius.circular(
                              AppRadius.md),
                        ),
                        child: Text(
                          l10n.statusHappy,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        width: 200,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          boxShadow: AppShadows.button,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(conversationProvider.notifier)
                                .resetState();
                            context.go('/scenario');
                          },
                          child: const Text('OK',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Floating decorative emojis scattered around celebration screen
  List<Widget> _buildFloatingEmojis(Animation<double> floatAnim) {
    const emojis = ['⭐', '✨', '🌟', '💫', '🎊', '⭐', '✨', '🌟'];
    final positions = [
      const Alignment(-0.8, -0.6),
      const Alignment(0.85, -0.4),
      const Alignment(-0.6, 0.5),
      const Alignment(0.7, 0.6),
      const Alignment(-0.3, -0.8),
      const Alignment(0.4, -0.7),
      const Alignment(-0.9, 0.1),
      const Alignment(0.9, 0.15),
    ];
    return List.generate(emojis.length, (i) {
      final delay = i * 0.12;
      return AnimatedBuilder(
        animation: floatAnim,
        builder: (context, child) {
          final offset = floatAnim.value * (i.isEven ? 1 : -1);
          return Align(
            alignment: positions[i],
            child: Transform.translate(
              offset: Offset(offset * 0.5, offset),
              child: Opacity(
                opacity: (_celebrationScale.value * (1 - delay))
                    .clamp(0.0, 0.6),
                child: Text(emojis[i],
                    style: TextStyle(fontSize: 24 + (i % 3) * 8)),
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _playFanfare() async {
    final fanfarePlayer = AudioPlayer();
    await fanfarePlayer.setVolume(0.5);
    await fanfarePlayer.play(AssetSource('sounds/goal_complete.mp3'));
  }

  void _showEndDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.conversationEndTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.conversationEndKeep),
          ),
          ElevatedButton(
            onPressed: () async {
              ref.read(conversationProvider.notifier).stopSession();
              Navigator.pop(ctx);
              final endPlayer = AudioPlayer();
              await endPlayer
                  .play(AssetSource('sounds/call_end.mp3'));
              await Future<void>.delayed(
                  const Duration(milliseconds: 800));
              endPlayer.dispose();
              if (context.mounted) context.go('/scenario');
            },
            child: Text(l10n.conversationEndStop),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final MontyState state;
  final bool isConnected;
  final AppLocalizations l10n;

  const _StatusIndicator({
    required this.state,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Show "Connecting..." before session is established
    if (!isConnected) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: const ValueKey('connecting'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.conversationConnecting,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final (emoji, text) = switch (state) {
      MontyState.idle => ('🎤', l10n.statusIdle),
      MontyState.listening => ('🎤', l10n.statusListening),
      MontyState.thinking => ('✨', l10n.statusThinking),
      MontyState.talking => ('🔊', l10n.statusTalking),
      MontyState.happy => ('🎉', l10n.statusHappy),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Column(
        key: ValueKey(state),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
