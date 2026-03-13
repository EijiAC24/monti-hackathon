// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Monti';

  @override
  String get characterName => 'Monty';

  @override
  String get profileTitle => 'Your Child\'s Profile';

  @override
  String get profileNameLabel => 'Nickname';

  @override
  String get profileNameHint => 'Enter nickname';

  @override
  String get profileAgeLabel => 'Age';

  @override
  String get profileInterestsLabel => 'Interests & Favorites';

  @override
  String get profileInterestsHint => 'e.g. Dinosaurs, Princess, Soccer';

  @override
  String get profileNext => 'Next →';

  @override
  String get interestDinosaurs => 'Dinosaurs';

  @override
  String get interestPrincess => 'Princess';

  @override
  String get interestCars => 'Cars';

  @override
  String get interestAnimals => 'Animals';

  @override
  String get interestSports => 'Sports';

  @override
  String get interestDrawing => 'Drawing';

  @override
  String get interestSweets => 'Sweets';

  @override
  String get interestSpace => 'Space';

  @override
  String scenarioTitle(String nickname) {
    return 'What to tell\n$nickname?';
  }

  @override
  String get scenarioTimerLabel => 'Call delay';

  @override
  String get scenarioImmediate => 'Now';

  @override
  String scenarioSeconds(int count) {
    return '${count}s';
  }

  @override
  String scenarioMinutes(int count) {
    return '${count}m';
  }

  @override
  String get scenarioStart => 'Set it up 📞';

  @override
  String get scenarioBrushingTitle => 'Let\'s brush teeth';

  @override
  String get scenarioBrushingGoal => 'Brush teeth on their own';

  @override
  String get scenarioCleanupTitle => 'Let\'s clean up';

  @override
  String get scenarioCleanupGoal => 'Start tidying up on their own';

  @override
  String get scenarioBedtimeTitle => 'Bedtime';

  @override
  String get scenarioBedtimeGoal => 'Get ready for bed calmly';

  @override
  String waitingTitle(String nickname) {
    return 'Monty is calling\n$nickname';
  }

  @override
  String get waitingCountdownSuffix => 'seconds until the call';

  @override
  String get waitingParentNote =>
      'When the phone rings,\nplease hand it to your child';

  @override
  String get waitingCancel => 'Cancel';

  @override
  String incomingCallCalling(String nickname) {
    return 'Calling $nickname...';
  }

  @override
  String get incomingCallAnswer => 'Tap to answer';

  @override
  String homeBubble(String nickname) {
    return '$nickname,\nlet\'s chat!';
  }

  @override
  String get homeTalkButton => 'Talk';

  @override
  String get conversationConnecting => 'Connecting...';

  @override
  String get conversationListening => 'Listening...';

  @override
  String get conversationThinking => 'Hmm...';

  @override
  String get conversationTalkPrompt => 'Go ahead, talk!';

  @override
  String get conversationTextHint => 'Type to talk (debug)';

  @override
  String get conversationEndTitle => 'End the call?';

  @override
  String get conversationEndKeep => 'Keep talking';

  @override
  String get conversationEndStop => 'End';

  @override
  String get conversationMicRequired => 'Microphone permission is required';

  @override
  String get statusListening => 'Listening... 🎧';

  @override
  String get statusThinking => 'Thinking...';

  @override
  String get statusTalking => 'Talking...';

  @override
  String get statusHappy => 'Yay! ✨';

  @override
  String get statusIdle => 'Go ahead!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get scenarioCustomTitle => 'Custom';

  @override
  String get scenarioCustomGoal => 'Your own mission';

  @override
  String get scenarioCustomHint => 'e.g. Eat your carrots';

  @override
  String get scenarioCustomLabel => 'What to ask the child?';
}
