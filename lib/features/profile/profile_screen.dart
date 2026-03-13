import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/child_profile.dart';
import '../../shared/theme/app_theme.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _interestsController = TextEditingController();
  final _voicePlayer = AudioPlayer();
  int _selectedAge = 4;
  final Set<String> _selectedInterests = {};
  String _selectedEmoji = '🐻';
  bool _initialized = false;

  List<(String, String Function(AppLocalizations))> get _interests => [
        ('🦖', (l10n) => l10n.interestDinosaurs),
        ('👸', (l10n) => l10n.interestPrincess),
        ('🚗', (l10n) => l10n.interestCars),
        ('🐶', (l10n) => l10n.interestAnimals),
        ('⚽', (l10n) => l10n.interestSports),
        ('🎨', (l10n) => l10n.interestDrawing),
        ('🍰', (l10n) => l10n.interestSweets),
        ('🚀', (l10n) => l10n.interestSpace),
      ];

  bool get _isValid =>
      _nicknameController.text.trim().isNotEmpty &&
      (_selectedInterests.isNotEmpty ||
          _interestsController.text.trim().isNotEmpty);

  @override
  void dispose() {
    _nicknameController.dispose();
    _interestsController.dispose();
    _voicePlayer.dispose();
    super.dispose();
  }

  void _initFromProfile(ChildProfile? profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _nicknameController.text = profile.nickname;
    _selectedAge = profile.age;
    _selectedEmoji = profile.emoji;
    _selectedInterests.addAll(profile.interests);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(childProfileProvider);
    _initFromProfile(profile);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                // Top bar
                Row(
                  children: [
                    const Spacer(),
                    _IconBtn(
                      icon: Icons.settings_rounded,
                      onTap: () => context.go('/settings'),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        // Character selector
                        GestureDetector(
                          onTap: _showEmojiPicker,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primaryPale, Color(0xFFFFE8D0)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.card,
                            ),
                            child: Center(
                              child: Text(_selectedEmoji,
                                  style: const TextStyle(fontSize: 42)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.profileTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Name section
                        _SectionLabel(label: l10n.profileNameLabel),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _nicknameController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: l10n.profileNameHint,
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Age section
                        _SectionLabel(label: l10n.profileAgeLabel),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: List.generate(7, (i) {
                            final age = i + 2;
                            final selected = _selectedAge == age;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAge = age),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.primaryLight
                                            .withValues(alpha: 0.5),
                                  ),
                                  boxShadow: selected
                                      ? AppShadows.card
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '$age',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Interests section
                        _SectionLabel(label: l10n.profileInterestsLabel),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.map((interest) {
                            final label = interest.$2(l10n);
                            final selected =
                                _selectedInterests.contains(label);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    _selectedInterests.remove(label);
                                  } else {
                                    _selectedInterests.add(label);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 72,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryPale
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.primaryLight
                                            .withValues(alpha: 0.4),
                                    width: selected ? 2 : 1,
                                  ),
                                  boxShadow: selected
                                      ? AppShadows.card
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(interest.$1,
                                        style:
                                            const TextStyle(fontSize: 24)),
                                    const SizedBox(height: 2),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _interestsController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: l10n.profileInterestsHint,
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Next button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: _isValid ? AppShadows.button : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _isValid ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      disabledBackgroundColor:
                          AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                    child: Text(l10n.profileNext),
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

  Future<void> _playVoiceSample(String emoji) async {
    await _voicePlayer.stop();
    final assetPath = ChildProfile.voiceSampleForEmoji(emoji);
    await _voicePlayer.play(AssetSource(assetPath));
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          // Inner radius = outer(24) - padding(24) = 0 → use 12 for items
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ChildProfile.availableEmojis.map((emoji) {
                  final selected = _selectedEmoji == emoji;
                  final name = ChildProfile.nameForEmoji(emoji);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      setSheetState(() {});
                      _playVoiceSample(emoji);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryPale
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: selected ? AppShadows.card : null,
                      ),
                      child: Column(
                        children: [
                          Text(emoji,
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNext() async {
    final interests = <String>[..._selectedInterests];
    final freeText = _interestsController.text.trim();
    if (freeText.isNotEmpty) {
      final extras = freeText
          .split(RegExp(r'[,、\s]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      interests.addAll(extras);
    }
    final profile = ChildProfile(
      nickname: _nicknameController.text.trim(),
      age: _selectedAge,
      interests: interests,
      emoji: _selectedEmoji,
    );
    await ref.read(childProfileProvider.notifier).save(profile);
    if (mounted) context.go('/scenario');
  }
}

// --- Shared widgets ---

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Hit area 44px (detail.design: larger than it appears)
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(icon, size: 22, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
