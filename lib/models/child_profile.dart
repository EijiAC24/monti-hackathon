import 'dart:typed_data';

class ChildProfile {
  final String nickname;
  final int age;
  final List<String> interests;
  final String emoji;
  final String characterName; // User-defined character name
  final Uint8List? characterImage; // AI-generated character image (PNG)

  const ChildProfile({
    required this.nickname,
    required this.age,
    required this.interests,
    this.emoji = '🐻',
    this.characterName = '',
    this.characterImage,
  });

  ChildProfile copyWith({
    String? nickname,
    int? age,
    List<String>? interests,
    String? emoji,
    String? characterName,
    Uint8List? characterImage,
  }) {
    return ChildProfile(
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      emoji: emoji ?? this.emoji,
      characterName: characterName ?? this.characterName,
      characterImage: characterImage ?? this.characterImage,
    );
  }

  /// Display name: user-defined character name or default from emoji
  String get displayName =>
      characterName.isNotEmpty ? characterName : nameForEmoji(emoji);

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'age': age,
        'interests': interests,
        'emoji': emoji,
        'characterName': characterName,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        nickname: json['nickname'] as String,
        age: json['age'] as int,
        interests: List<String>.from(json['interests'] as List),
        emoji: json['emoji'] as String? ?? '🐻',
        characterName: json['characterName'] as String? ?? '',
      );

  static const availableEmojis = ['🐻', '🐰', '🦁', '🐱', '🐶', '🐼'];

  /// Map emoji to character asset image path
  static String? assetForEmoji(String emoji) {
    return switch (emoji) {
      '🐻' => 'assets/characters/bear.png',
      '🐰' => 'assets/characters/rabbit.png',
      '🦁' => 'assets/characters/lion.png',
      '🐱' => 'assets/characters/cat.png',
      '🐶' => 'assets/characters/dog.png',
      '🐼' => 'assets/characters/panda.png',
      _ => null,
    };
  }

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
