import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/conversation/conversation_screen.dart';
import '../features/home/home_screen.dart';
import '../features/incoming_call/incoming_call_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/scenario/scenario_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/waiting/waiting_screen.dart';

/// Smooth fade transition for all page navigations
CustomTransitionPage<void> _fadeTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const SettingsScreen()),
      ),
      GoRoute(
        path: '/scenario',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const ScenarioScreen()),
      ),
      GoRoute(
        path: '/waiting',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const WaitingScreen()),
      ),
      GoRoute(
        path: '/incoming-call',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const IncomingCallScreen()),
      ),
      GoRoute(
        path: '/conversation',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const ConversationScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _fadeTransition(state, const HomeScreen()),
      ),
    ],
  );
});
