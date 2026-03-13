// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'モンティ';

  @override
  String get characterName => 'モンティ';

  @override
  String get profileTitle => 'お子さんのプロフィール';

  @override
  String get profileNameLabel => 'ニックネーム';

  @override
  String get profileNameHint => '呼び名を入力';

  @override
  String get profileAgeLabel => '年齢';

  @override
  String get profileInterestsLabel => '好きなもの・興味';

  @override
  String get profileInterestsHint => '例: 恐竜、プリンセス、サッカー';

  @override
  String get profileNext => '次へ →';

  @override
  String get interestDinosaurs => '恐竜';

  @override
  String get interestPrincess => 'プリンセス';

  @override
  String get interestCars => '車';

  @override
  String get interestAnimals => '動物';

  @override
  String get interestSports => 'スポーツ';

  @override
  String get interestDrawing => 'お絵かき';

  @override
  String get interestSweets => 'お菓子';

  @override
  String get interestSpace => '宇宙';

  @override
  String scenarioTitle(String nickname) {
    return '$nicknameに\n何を伝える？';
  }

  @override
  String get scenarioTimerLabel => '何秒後にかける？';

  @override
  String get scenarioImmediate => 'すぐ';

  @override
  String scenarioSeconds(int count) {
    return '$count秒';
  }

  @override
  String scenarioMinutes(int count) {
    return '$count分';
  }

  @override
  String get scenarioStart => 'セットする 📞';

  @override
  String get scenarioBrushingTitle => '歯磨きしよう';

  @override
  String get scenarioBrushingGoal => '自分から歯磨きに行く';

  @override
  String get scenarioCleanupTitle => 'お片付けしよう';

  @override
  String get scenarioCleanupGoal => '自分から片付けを始める';

  @override
  String get scenarioBedtimeTitle => 'おやすみ';

  @override
  String get scenarioBedtimeGoal => '落ち着いて寝る準備をする';

  @override
  String waitingTitle(String nickname) {
    return '$nicknameに\n電話をかけます';
  }

  @override
  String get waitingCountdownSuffix => '秒後にかかってきます';

  @override
  String get waitingParentNote => '電話が鳴ったら\nお子さんに渡してください';

  @override
  String get waitingCancel => 'キャンセル';

  @override
  String incomingCallCalling(String nickname) {
    return '$nicknameちゃんに でんわ...';
  }

  @override
  String get incomingCallAnswer => 'タップして でんわにでる';

  @override
  String homeBubble(String nickname) {
    return '$nicknameちゃん、\nおはなししよう！';
  }

  @override
  String get homeTalkButton => 'はなす';

  @override
  String get conversationConnecting => 'つないでるよ...';

  @override
  String get conversationListening => 'きいてるよ...';

  @override
  String get conversationThinking => 'うーんと...';

  @override
  String get conversationTalkPrompt => 'はなしてね！';

  @override
  String get conversationTextHint => 'テキストで話す（デバッグ用）';

  @override
  String get conversationEndTitle => '通話を終了しますか？';

  @override
  String get conversationEndKeep => '続ける';

  @override
  String get conversationEndStop => '終了';

  @override
  String get conversationMicRequired => 'マイクの許可が必要です';

  @override
  String get statusListening => 'きいてるよ... 🎧';

  @override
  String get statusThinking => 'うーんと...';

  @override
  String get statusTalking => 'おはなしちゅう...';

  @override
  String get statusHappy => 'やったー！✨';

  @override
  String get statusIdle => 'はなしてね！';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguageLabel => '言語';

  @override
  String get settingsEditProfile => 'プロフィール編集';

  @override
  String get scenarioCustomTitle => 'カスタム';

  @override
  String get scenarioCustomGoal => '自由にミッションを作成';

  @override
  String get scenarioCustomHint => '例: にんじんを食べる';

  @override
  String get scenarioCustomLabel => '何をお願いする？';
}
