class ChildProfile {
  final String nickname;
  final int age;
  final List<String> interests;

  const ChildProfile({
    required this.nickname,
    required this.age,
    required this.interests,
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'age': age,
        'interests': interests,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        nickname: json['nickname'] as String,
        age: json['age'] as int,
        interests: List<String>.from(json['interests'] as List),
      );
}
