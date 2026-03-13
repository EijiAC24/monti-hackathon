import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_profile.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/monty_character.dart';
import '../profile/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(childProfileProvider);
    final nickname = profile?.nickname ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/scenario'),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(Icons.arrow_back_rounded,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(Icons.lock_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Character
              MontyCharacter(
                  state: MontyState.idle,
                  size: 200,
                  emoji: profile?.emoji ?? '🐻'),
              const SizedBox(height: 12),
              Text(
                ChildProfile.nameForEmoji(profile?.emoji ?? '🐻'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Speech bubble
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft(),
                ),
                child: Text(
                  l10n.homeBubble(nickname),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const Spacer(),

              // Talk button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppShadows.button,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/conversation'),
                    icon: const Icon(Icons.mic_rounded, size: 28),
                    label: Text(l10n.homeTalkButton,
                        style: const TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 72),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
