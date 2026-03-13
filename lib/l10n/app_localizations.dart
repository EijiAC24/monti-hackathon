import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Monti'**
  String get appTitle;

  /// No description provided for @characterName.
  ///
  /// In en, this message translates to:
  /// **'Monty'**
  String get characterName;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Child\'s Profile'**
  String get profileTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get profileNameHint;

  /// No description provided for @profileAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAgeLabel;

  /// No description provided for @profileInterestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interests & Favorites'**
  String get profileInterestsLabel;

  /// No description provided for @profileInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dinosaurs, Princess, Soccer'**
  String get profileInterestsHint;

  /// No description provided for @profileNext.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get profileNext;

  /// No description provided for @interestDinosaurs.
  ///
  /// In en, this message translates to:
  /// **'Dinosaurs'**
  String get interestDinosaurs;

  /// No description provided for @interestPrincess.
  ///
  /// In en, this message translates to:
  /// **'Princess'**
  String get interestPrincess;

  /// No description provided for @interestCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get interestCars;

  /// No description provided for @interestAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get interestAnimals;

  /// No description provided for @interestSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get interestSports;

  /// No description provided for @interestDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get interestDrawing;

  /// No description provided for @interestSweets.
  ///
  /// In en, this message translates to:
  /// **'Sweets'**
  String get interestSweets;

  /// No description provided for @interestSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get interestSpace;

  /// No description provided for @scenarioTitle.
  ///
  /// In en, this message translates to:
  /// **'What to tell\n{nickname}?'**
  String scenarioTitle(String nickname);

  /// No description provided for @scenarioTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Call delay'**
  String get scenarioTimerLabel;

  /// No description provided for @scenarioImmediate.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get scenarioImmediate;

  /// No description provided for @scenarioSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String scenarioSeconds(int count);

  /// No description provided for @scenarioMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String scenarioMinutes(int count);

  /// No description provided for @scenarioStart.
  ///
  /// In en, this message translates to:
  /// **'Set it up 📞'**
  String get scenarioStart;

  /// No description provided for @scenarioBrushingTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s brush teeth'**
  String get scenarioBrushingTitle;

  /// No description provided for @scenarioBrushingGoal.
  ///
  /// In en, this message translates to:
  /// **'Brush teeth on their own'**
  String get scenarioBrushingGoal;

  /// No description provided for @scenarioCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s clean up'**
  String get scenarioCleanupTitle;

  /// No description provided for @scenarioCleanupGoal.
  ///
  /// In en, this message translates to:
  /// **'Start tidying up on their own'**
  String get scenarioCleanupGoal;

  /// No description provided for @scenarioBedtimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get scenarioBedtimeTitle;

  /// No description provided for @scenarioBedtimeGoal.
  ///
  /// In en, this message translates to:
  /// **'Get ready for bed calmly'**
  String get scenarioBedtimeGoal;

  /// No description provided for @waitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Monty is calling\n{nickname}'**
  String waitingTitle(String nickname);

  /// No description provided for @waitingCountdownSuffix.
  ///
  /// In en, this message translates to:
  /// **'seconds until the call'**
  String get waitingCountdownSuffix;

  /// No description provided for @waitingParentNote.
  ///
  /// In en, this message translates to:
  /// **'When the phone rings,\nplease hand it to your child'**
  String get waitingParentNote;

  /// No description provided for @waitingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get waitingCancel;

  /// No description provided for @incomingCallCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling {nickname}...'**
  String incomingCallCalling(String nickname);

  /// No description provided for @incomingCallAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap to answer'**
  String get incomingCallAnswer;

  /// No description provided for @homeBubble.
  ///
  /// In en, this message translates to:
  /// **'{nickname},\nlet\'s chat!'**
  String homeBubble(String nickname);

  /// No description provided for @homeTalkButton.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get homeTalkButton;

  /// No description provided for @conversationConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get conversationConnecting;

  /// No description provided for @conversationListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get conversationListening;

  /// No description provided for @conversationThinking.
  ///
  /// In en, this message translates to:
  /// **'Hmm...'**
  String get conversationThinking;

  /// No description provided for @conversationTalkPrompt.
  ///
  /// In en, this message translates to:
  /// **'Go ahead, talk!'**
  String get conversationTalkPrompt;

  /// No description provided for @conversationTextHint.
  ///
  /// In en, this message translates to:
  /// **'Type to talk (debug)'**
  String get conversationTextHint;

  /// No description provided for @conversationEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End the call?'**
  String get conversationEndTitle;

  /// No description provided for @conversationEndKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep talking'**
  String get conversationEndKeep;

  /// No description provided for @conversationEndStop.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get conversationEndStop;

  /// No description provided for @conversationMicRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get conversationMicRequired;

  /// No description provided for @statusListening.
  ///
  /// In en, this message translates to:
  /// **'Listening... 🎧'**
  String get statusListening;

  /// No description provided for @statusThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get statusThinking;

  /// No description provided for @statusTalking.
  ///
  /// In en, this message translates to:
  /// **'Talking...'**
  String get statusTalking;

  /// No description provided for @statusHappy.
  ///
  /// In en, this message translates to:
  /// **'Yay! ✨'**
  String get statusHappy;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'Go ahead!'**
  String get statusIdle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @scenarioCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get scenarioCustomTitle;

  /// No description provided for @scenarioCustomGoal.
  ///
  /// In en, this message translates to:
  /// **'Your own mission'**
  String get scenarioCustomGoal;

  /// No description provided for @scenarioCustomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eat your carrots'**
  String get scenarioCustomHint;

  /// No description provided for @scenarioCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'What to ask the child?'**
  String get scenarioCustomLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
