class Scenario {
  final String id;
  final String title;
  final String emoji;
  final String goal;
  final String promptAddition;

  const Scenario({
    required this.id,
    required this.title,
    required this.emoji,
    required this.goal,
    required this.promptAddition,
  });

  static const List<Scenario> defaults = [
    Scenario(
      id: 'brushing',
      title: 'はみがきしよう',
      emoji: '🪥',
      goal: '自分から歯磨きに行く',
      promptAddition: '''テーマ: 歯磨きしよう
ゴール: 子供が自分から歯磨きに行く

会話の導入例:
- 「今日何か美味しいもの食べた？」から始める
- 食べ物→歯にくっつく→どうなる？→虫歯→どうする？→歯磨き！
- 子供が「歯磨きする」と言ったら大いに喜ぶ''',
    ),
    Scenario(
      id: 'cleanup',
      title: 'おかたづけしよう',
      emoji: '🧹',
      goal: '自分から片付けを始める',
      promptAddition: '''テーマ: お片付けしよう
ゴール: 子供が自分から片付けを始める

会話の導入例:
- 「今日何して遊んだ？」から始める
- おもちゃ→出しっぱなし→踏んだら痛い/なくなっちゃう→どうする？→片付ける！
- 「一緒にやろう」「応援してるよ」のスタンス''',
    ),
    Scenario(
      id: 'bedtime',
      title: 'おやすみ',
      emoji: '🌙',
      goal: '落ち着いて寝る準備をする',
      promptAddition: '''テーマ: おやすみ
ゴール: 子供が落ち着いて寝る準備をする

会話の導入例:
- 「今日楽しかったこと教えて？」から始める
- 今日の振り返り→明日も楽しいことある→そのためには元気でいないと→寝る！
- 穏やかなトーン、ゆっくり話す''',
    ),
  ];
}
