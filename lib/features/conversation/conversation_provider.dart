import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/monty_character.dart';

class ConversationState {
  final MontyState montyState;
  final String currentText;
  final bool isConnected;

  const ConversationState({
    this.montyState = MontyState.idle,
    this.currentText = 'はなしてね！',
    this.isConnected = false,
  });

  ConversationState copyWith({
    MontyState? montyState,
    String? currentText,
    bool? isConnected,
  }) {
    return ConversationState(
      montyState: montyState ?? this.montyState,
      currentText: currentText ?? this.currentText,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier() : super(const ConversationState());

  void updateState(MontyState montyState, {String? text}) {
    state = state.copyWith(montyState: montyState, currentText: text);
  }

  void setConnected(bool connected) {
    state = state.copyWith(isConnected: connected);
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
