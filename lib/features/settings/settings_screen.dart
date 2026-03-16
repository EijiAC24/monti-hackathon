import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../../models/child_profile.dart';
import '../../shared/theme/app_theme.dart';
import '../profile/profile_provider.dart';
import 'locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _promptController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isGenerating = false;
  Uint8List? _previewImage;

  @override
  void dispose() {
    _promptController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateCharacter() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      const tokenServerUrl = String.fromEnvironment('TOKEN_SERVER_URL');
      if (tokenServerUrl.isEmpty) return;

      final resp = await http.post(
        Uri.parse('$tokenServerUrl/generate-character'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final imageB64 = data['image'] as String?;
        if (imageB64 != null && imageB64.isNotEmpty) {
          setState(() => _previewImage = base64Decode(imageB64));
        }
      }
    } catch (e) {
      print('[Monti] Character generation failed: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _applyCharacter() {
    if (_previewImage == null) return;
    final current = ref.read(childProfileProvider);
    if (current == null) return;

    final updated = current.copyWith(
      characterImage: _previewImage,
      characterName: _nameController.text.trim(),
    );
    ref.read(childProfileProvider.notifier).save(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Character updated!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }

  static const _languages = [
    (Locale('en'), '🇺🇸', 'English'),
    (Locale('ja'), '🇯🇵', '日本語'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final activeCode = currentLocale?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;
    final profile = ref.watch(childProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                  const SizedBox(height: 12),

                  // Header
                  Text(
                    l10n.settingsTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // --- Character Generation ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Character',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        // Preview
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                            color: AppColors.primaryPale,
                          ),
                          child: _isGenerating
                              ? const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : _previewImage != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        _previewImage!,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : profile?.characterImage != null
                                      ? ClipOval(
                                          child: Image.memory(
                                            profile!.characterImage!,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            profile?.emoji ?? '🐻',
                                            style: const TextStyle(
                                                fontSize: 44),
                                          ),
                                        ),
                        ),
                        const SizedBox(height: 16),
                        // Prompt input
                        TextField(
                          controller: _promptController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                'Describe your character (e.g. a friendly purple dinosaur)',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Name input
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Character name (e.g. Dino)',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _isGenerating ? null : _generateCharacter,
                                child: Text(_isGenerating
                                    ? 'Generating...'
                                    : 'Generate'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _previewImage != null ? _applyCharacter : null,
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Language ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.settingsLanguageLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),

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

                  const SizedBox(height: 16),

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
