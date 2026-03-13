import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_theme.dart';
import 'locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = [
    (Locale('en'), '🇺🇸', 'English'),
    (Locale('ja'), '🇯🇵', '日本語'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final activeCode = currentLocale?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/profile'),
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
                  ],
                ),
                const SizedBox(height: 16),

                // Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryPale, Color(0xFFFFE8D0)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Center(
                    child: Icon(Icons.settings_rounded,
                        size: 28, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.settingsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),

                // Edit profile
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.person_outline_rounded),
                    label: Text(l10n.settingsEditProfile),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Language label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.settingsLanguageLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),

                // Language cards
                ..._languages.map((lang) {
                  final selected =
                      activeCode == lang.$1.languageCode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(localeProvider.notifier)
                            .setLocale(lang.$1);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryPale
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primaryLight
                                    .withValues(alpha: 0.3),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow:
                              selected ? AppShadows.card : null,
                        ),
                        child: Row(
                          children: [
                            Text(lang.$2,
                                style:
                                    const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Text(
                              lang.$3,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                            const Spacer(),
                            if (selected)
                              const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
