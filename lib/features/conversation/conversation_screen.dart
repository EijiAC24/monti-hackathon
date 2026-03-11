import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/monty_character.dart';
import 'conversation_provider.dart';

class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationProvider);

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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.pause_circle_outline, size: 28),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showEndDialog(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
            ),

            // Character area (top 60%)
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

            // Status indicator (bottom)
            Expanded(
              flex: 2,
              child: Center(
                child: _StatusIndicator(state: state.montyState),
              ),
            ),
          ],
        ),
      ),
    );
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
