import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  int _selectedAge = 4;
  final Set<String> _selectedInterests = {};

  static const _interests = [
    ('🦖', 'きょうりゅう'),
    ('👸', 'プリンセス'),
    ('🚗', 'くるま'),
    ('🐶', 'どうぶつ'),
    ('⚽', 'スポーツ'),
    ('🎨', 'おえかき'),
    ('🍰', 'おかし'),
    ('🚀', 'うちゅう'),
  ];

  bool get _isValid =>
      _nicknameController.text.trim().isNotEmpty &&
      _selectedInterests.isNotEmpty;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Monty header
              const Text('🐻', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                'モンティに\nおしえてね！',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),

              // Nickname
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'おなまえ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(hintText: 'ニックネーム'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Age
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'なんさい？',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final age = i + 2;
                  final selected = _selectedAge == age;
                  return ChoiceChip(
                    label: Text(
                      '$age',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedAge = age),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Interests
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'すきなもの（えらんでね）',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _interests.map((interest) {
                  final selected = _selectedInterests.contains(interest.$2);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedInterests.remove(interest.$2);
                        } else {
                          _selectedInterests.add(interest.$2);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            interest.$1,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            interest.$2,
                            style: TextStyle(
                              fontSize: 10,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Next button
              ElevatedButton(
                onPressed: _isValid ? _onNext : null,
                child: const Text('つぎへ →'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNext() async {
    final profile = ChildProfile(
      nickname: _nicknameController.text.trim(),
      age: _selectedAge,
      interests: _selectedInterests.toList(),
    );
    await ref.read(childProfileProvider.notifier).save(profile);
    if (mounted) context.go('/scenario');
  }
}
