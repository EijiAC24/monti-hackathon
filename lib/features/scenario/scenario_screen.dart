import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_profile.dart';
import '../../models/scenario.dart';
import '../../shared/theme/app_theme.dart';
import '../profile/profile_provider.dart';

final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);
final callDelaySecondsProvider = StateProvider<int>((ref) => 10);

class ScenarioScreen extends ConsumerStatefulWidget {
  const ScenarioScreen({super.key});

  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends ConsumerState<ScenarioScreen> {
  String? _selectedId;
  int _delaySeconds = 0;
  String _customText = '';

  static const _delayOptions = [0, 10, 30, 60];

  Scenario? get _resolvedScenario {
    if (_selectedId == null) return null;
    if (_selectedId == 'custom') {
      if (_customText.isEmpty) return null;
      return Scenario.custom(_customText);
    }
    return Scenario.defaults.firstWhere((s) => s.id == _selectedId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(childProfileProvider);
    final nickname = profile?.nickname ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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

                // Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryPale, Color(0xFFFFE8D0)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: profile?.characterImage != null
                      ? ClipOval(
                          child: Image.memory(
                            profile!.characterImage!,
                            width: 56,
                            height: 56,
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
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(profile?.emoji ?? '🐻',
                                  style: const TextStyle(fontSize: 30)),
                            ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scenarioTitle(nickname),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Scenario cards
                Expanded(
                  child: Column(
                    children: [
                      ...Scenario.defaults.map((scenario) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ScenarioCard(
                              scenario: scenario,
                              l10n: l10n,
                              isSelected: _selectedId == scenario.id,
                              onTap: () => setState(
                                  () => _selectedId = scenario.id),
                            ),
                          ),
                        );
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _CustomCard(
                            l10n: l10n,
                            isSelected: _selectedId == 'custom',
                            customText: _customText,
                            onTap: () => _showCustomInput(l10n),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer
                const SizedBox(height: 4),
                Text(
                  l10n.scenarioTimerLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _delayOptions.map((seconds) {
                    final selected = _delaySeconds == seconds;
                    final label = seconds == 0
                        ? l10n.scenarioImmediate
                        : seconds >= 60
                            ? l10n.scenarioMinutes(seconds ~/ 60)
                            : l10n.scenarioSeconds(seconds);
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _delaySeconds = seconds),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primaryLight
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Start button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: _resolvedScenario != null
                        ? AppShadows.button
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _resolvedScenario != null ? _onStart : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      disabledBackgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                    child: Text(l10n.scenarioStart),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomInput(AppLocalizations l10n) {
    final controller = TextEditingController(text: _customText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.scenarioCustomLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: l10n.scenarioCustomHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.waitingCancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customText = controller.text.trim();
                _selectedId = 'custom';
              });
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onStart() {
    final scenario = _resolvedScenario;
    if (scenario == null) return;
    ref.read(selectedScenarioProvider.notifier).state = scenario;
    ref.read(callDelaySecondsProvider.notifier).state = _delaySeconds;
    context.go('/waiting');
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final AppLocalizations l10n;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.l10n,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPale : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primaryLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(scenario.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    scenario.title(l10n),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scenario.goal(l10n),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isSelected;
  final String customText;
  final VoidCallback onTap;

  const _CustomCard({
    required this.l10n,
    required this.isSelected,
    required this.customText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPale : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primaryLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Center(
                child: Text('✏️', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSelected && customText.isNotEmpty
                        ? customText
                        : l10n.scenarioCustomTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.scenarioCustomGoal,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
