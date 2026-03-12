import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/monty_character.dart';
import '../profile/profile_provider.dart';
import '../scenario/scenario_screen.dart';
import 'conversation_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  bool _sessionStarted = false;
  final _textController = TextEditingController();
  bool _showTextInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
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

    // API key via --dart-define=GEMINI_API_KEY=xxx
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      // Show text-based fallback mode
      setState(() => _showTextInput = true);
      return;
    }

    await ref.read(conversationProvider.notifier).startSession(
          apiKey: apiKey,
          profile: profile,
          scenario: scenario,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);

    // Show error snackbar
    ref.listen<ConversationState>(conversationProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Toggle text input (debug)
                  IconButton(
                    onPressed: () {
                      setState(() => _showTextInput = !_showTextInput);
                    },
                    icon: Icon(
                      _showTextInput ? Icons.mic : Icons.keyboard,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showEndDialog(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
            ),

            // Character area
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MontyCharacter(state: state.montyState, size: 180),
                  const SizedBox(height: 20),
                  if (state.currentText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        state.currentText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, height: 1.5),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom area: status indicator or text input
            Expanded(
              flex: 2,
              child: _showTextInput
                  ? _buildTextInput()
                  : Center(
                      child: _StatusIndicator(state: state.montyState),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'テキストで話す（デバッグ用）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _onSendText,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => _onSendText(_textController.text),
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _onSendText(String text) {
    if (text.trim().isEmpty) return;
    ref.read(conversationProvider.notifier).sendText(text.trim());
    _textController.clear();
  }

  void _showEndDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('おわりにする？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('まだはなす'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(conversationProvider.notifier).stopSession();
              Navigator.pop(ctx);
              context.go('/home');
            },
            child: const Text('おわる'),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final MontyState state;

  const _StatusIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (state) {
      MontyState.idle => (Icons.mic, 'はなしてね！'),
      MontyState.listening => (Icons.headphones, 'きいてるよ... 🎧'),
      MontyState.thinking => (Icons.auto_awesome, 'うーんと...'),
      MontyState.talking => (Icons.volume_up, 'おはなしちゅう...'),
      MontyState.happy => (Icons.celebration, 'やったー！✨'),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
