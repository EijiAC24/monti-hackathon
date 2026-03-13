import '../l10n/app_localizations.dart';

class Scenario {
  final String id;
  final String emoji;
  final String promptAddition;

  // These are resolved at runtime from l10n
  final String Function(AppLocalizations l10n) _titleResolver;
  final String Function(AppLocalizations l10n) _goalResolver;

  const Scenario({
    required this.id,
    required this.emoji,
    required String Function(AppLocalizations) titleResolver,
    required String Function(AppLocalizations) goalResolver,
    required this.promptAddition,
  })  : _titleResolver = titleResolver,
        _goalResolver = goalResolver;

  String title(AppLocalizations l10n) => _titleResolver(l10n);
  String goal(AppLocalizations l10n) => _goalResolver(l10n);

  /// Create a custom scenario from free-text input.
  static Scenario custom(String userInput) {
    return Scenario(
      id: 'custom',
      emoji: '✏️',
      titleResolver: (l10n) => l10n.scenarioCustomTitle,
      goalResolver: (l10n) => l10n.scenarioCustomGoal,
      promptAddition: '''テーマ: $userInput
ゴール: 子供が自分から行動する / Child takes action on their own

挨拶したらすぐテーマに関連する質問をする。
1-2往復で核心に向かい、子供が自分で気づいて行動を決めたら褒めて送り出す。
After greeting, immediately ask a question related to the theme.
Move to the core in 1-2 exchanges. When child decides to act, celebrate and send them off.''',
    );
  }

  static final List<Scenario> defaults = [
    Scenario(
      id: 'brushing',
      emoji: '🪥',
      titleResolver: (l10n) => l10n.scenarioBrushingTitle,
      goalResolver: (l10n) => l10n.scenarioBrushingGoal,
      promptAddition: '''テーマ: 歯磨きしよう / Let's brush teeth
ゴール: 子供が自分から歯磨きに行く / Child goes to brush teeth on their own

挨拶したらすぐ「今日何か美味しいもの食べた？」と聞く。
1往復で食べ物の話をしたら「その食べ物、歯にくっついてるかも！どうしたらいいかな？」と核心へ。
子供が「歯磨き」と言ったら「すごい！応援してるよ！いってらっしゃい！」と送り出す。
After greeting, immediately ask "Did you eat anything yummy today?"
After 1 exchange, go to: "That food might be stuck on your teeth! What should we do?"
When child says "brush teeth", celebrate and send them off.''',
    ),
    Scenario(
      id: 'cleanup',
      emoji: '🧹',
      titleResolver: (l10n) => l10n.scenarioCleanupTitle,
      goalResolver: (l10n) => l10n.scenarioCleanupGoal,
      promptAddition: '''テーマ: お片付けしよう / Let's clean up
ゴール: 子供が自分から片付けを始める / Child starts tidying up on their own

挨拶したらすぐ「今日何して遊んだ？」と聞く。
1往復で遊びの話をしたら「おもちゃ出しっぱなしだと踏んじゃうかも！どうする？」と核心へ。
子供が「片付ける」と言ったら「やった！応援してるよ！」と送り出す。
After greeting, immediately ask "What did you play today?"
After 1 exchange: "If toys are left out, someone might step on them! What should we do?"
When child says "clean up", celebrate and cheer them on.''',
    ),
    Scenario(
      id: 'bedtime',
      emoji: '🌙',
      titleResolver: (l10n) => l10n.scenarioBedtimeTitle,
      goalResolver: (l10n) => l10n.scenarioBedtimeGoal,
      promptAddition: '''テーマ: おやすみ / Bedtime
ゴール: 子供が落ち着いて寝る準備をする / Child gets ready for bed calmly

挨拶したらすぐ「今日楽しかったこと教えて？」と聞く。
1往復で今日の話をしたら「明日も楽しいことあるよ！元気にするにはどうしたらいいかな？」と核心へ。
子供が「寝る」と言ったら「そうだね！おやすみ、いい夢見てね！」と穏やかに送り出す。
穏やかなトーンで話す。
After greeting, immediately ask "Tell me something fun from today!"
After 1 exchange: "Tomorrow will be fun too! How can you be full of energy?"
When child says "sleep", gently say goodnight.
Use a calm, soothing tone.''',
    ),
  ];
}
