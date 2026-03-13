class ChildProfile {
  final String nickname;
  final int age;
  final List<String> interests;
  final String emoji;

  const ChildProfile({
    required this.nickname,
    required this.age,
    required this.interests,
    this.emoji = '🐻',
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'age': age,
        'interests': interests,
        'emoji': emoji,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        nickname: json['nickname'] as String,
        age: json['age'] as int,
        interests: List<String>.from(json['interests'] as List),
        emoji: json['emoji'] as String? ?? '🐻',
      );

  static const availableEmojis = ['🐻', '🐰', '🦁', '🐱', '🐶', '🐼'];

  /// Map emoji to character name
  static String nameForEmoji(String emoji) {
    return switch (emoji) {
      '🐻' => 'Monty',
      '🐰' => 'Luna',
      '🦁' => 'Leo',
      '🐱' => 'Mimi',
      '🐶' => 'Max',
      '🐼' => 'Pan',
      _ => 'Monty',
    };
  }

  /// Map emoji to Gemini voice name (child-friendly, higher-pitched voices)
  static String voiceForEmoji(String emoji) {
    return switch (emoji) {
      '🐻' => 'Zephyr',      // Bear - bright, warm
      '🐰' => 'Leda',        // Rabbit - youthful, gentle
      '🦁' => 'Puck',        // Lion - upbeat, energetic
      '🐱' => 'Achernar',    // Cat - soft, sweet
      '🐶' => 'Laomedeia',   // Dog - upbeat, friendly
      '🐼' => 'Aoede',       // Panda - breezy, calm
      _ => 'Zephyr',
    };
  }

  /// Map emoji to voice sample asset path
  static String voiceSampleForEmoji(String emoji) {
    return switch (emoji) {
      '🐻' => 'sounds/voice_bear.wav',
      '🐰' => 'sounds/voice_rabbit.wav',
      '🦁' => 'sounds/voice_lion.wav',
      '🐱' => 'sounds/voice_cat.wav',
      '🐶' => 'sounds/voice_dog.wav',
      '🐼' => 'sounds/voice_panda.wav',
      _ => 'sounds/voice_bear.wav',
    };
  }
}
