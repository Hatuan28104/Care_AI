import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @soundVibration.
  ///
  /// In en, this message translates to:
  /// **'Sound & Vibration'**
  String get soundVibration;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @healthAlert.
  ///
  /// In en, this message translates to:
  /// **'Health Alert'**
  String get healthAlert;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @defaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSize;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @searchData.
  ///
  /// In en, this message translates to:
  /// **'Search data...'**
  String get searchData;

  /// No description provided for @activityData.
  ///
  /// In en, this message translates to:
  /// **'Activity Data'**
  String get activityData;

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @deleteAlert.
  ///
  /// In en, this message translates to:
  /// **'Delete alert'**
  String get deleteAlert;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action may have consequences.'**
  String get deleteWarning;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccess;

  /// No description provided for @digitalHuman.
  ///
  /// In en, this message translates to:
  /// **'Digital Human'**
  String get digitalHuman;

  /// No description provided for @nutritionExpert.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Expert'**
  String get nutritionExpert;

  /// No description provided for @zodiacExpert.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Expert'**
  String get zodiacExpert;

  /// No description provided for @fitnessCoach.
  ///
  /// In en, this message translates to:
  /// **'Fitness Coach'**
  String get fitnessCoach;

  /// No description provided for @meditationGuide.
  ///
  /// In en, this message translates to:
  /// **'Meditation Guide'**
  String get meditationGuide;

  /// No description provided for @digitalHumanSection.
  ///
  /// In en, this message translates to:
  /// **'Digital Human'**
  String get digitalHumanSection;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Health Categories'**
  String get healthCategory;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get welcome;

  /// No description provided for @welcomeQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get welcomeQuestion;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything...'**
  String get chatHint;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get chooseImage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @deviceTab.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceTab;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @configurePermissions.
  ///
  /// In en, this message translates to:
  /// **'Configure permissions'**
  String get configurePermissions;

  /// No description provided for @conversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation history'**
  String get conversationHistory;

  /// No description provided for @chooseConversation.
  ///
  /// In en, this message translates to:
  /// **'Choose conversation'**
  String get chooseConversation;

  /// No description provided for @shareConversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Share conversation history'**
  String get shareConversationHistory;

  /// No description provided for @basicHealthData.
  ///
  /// In en, this message translates to:
  /// **'Basic health data'**
  String get basicHealthData;

  /// No description provided for @chooseHealthData.
  ///
  /// In en, this message translates to:
  /// **'Choose health data'**
  String get chooseHealthData;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @guardians.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get guardians;

  /// No description provided for @dependents.
  ///
  /// In en, this message translates to:
  /// **'Dependents'**
  String get dependents;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  /// No description provided for @enterGuardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter guardian phone number'**
  String get enterGuardianPhone;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get sendInvite;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @inviteSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get inviteSentSuccess;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteGuardian.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this guardian?'**
  String get confirmDeleteGuardian;

  /// No description provided for @confirmInvite.
  ///
  /// In en, this message translates to:
  /// **'Confirm invitation'**
  String get confirmInvite;

  /// No description provided for @acceptInviteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept the invitation?'**
  String get acceptInviteQuestion;

  /// No description provided for @confirmRejectInvite.
  ///
  /// In en, this message translates to:
  /// **'Confirm reject invitation'**
  String get confirmRejectInvite;

  /// No description provided for @rejectInviteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this invitation?'**
  String get rejectInviteQuestion;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join date'**
  String get joinDate;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @shareData.
  ///
  /// In en, this message translates to:
  /// **'Share data'**
  String get shareData;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heartRate;

  /// No description provided for @bodyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Body temperature'**
  String get bodyTemperature;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get bloodPressure;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @sevenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'7 days ago'**
  String get sevenDaysAgo;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @scanningBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Scanning Bluetooth'**
  String get scanningBluetooth;

  /// No description provided for @deviceNearby.
  ///
  /// In en, this message translates to:
  /// **'Make sure your device is nearby'**
  String get deviceNearby;

  /// No description provided for @deviceVisible.
  ///
  /// In en, this message translates to:
  /// **'and discoverable'**
  String get deviceVisible;

  /// No description provided for @noDeviceFound.
  ///
  /// In en, this message translates to:
  /// **'No device found'**
  String get noDeviceFound;

  /// No description provided for @unnamedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unnamed device'**
  String get unnamedDevice;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect device'**
  String get connectDevice;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @bluetoothPairRequest.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth pair request'**
  String get bluetoothPairRequest;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @pairSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device paired successfully!'**
  String get pairSuccess;

  /// No description provided for @deviceConnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device connected successfully.'**
  String get deviceConnectedSuccess;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setup;

  /// No description provided for @allowHealthNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive health\nnotifications'**
  String get allowHealthNotificationTitle;

  /// No description provided for @allowHealthNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when something important happens.'**
  String get allowHealthNotificationDesc;

  /// No description provided for @healthAlertDesc.
  ///
  /// In en, this message translates to:
  /// **'Smartwatch can detect abnormal health signals.'**
  String get healthAlertDesc;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @syncingDevice.
  ///
  /// In en, this message translates to:
  /// **'Syncing device'**
  String get syncingDevice;

  /// No description provided for @syncingDesc.
  ///
  /// In en, this message translates to:
  /// **'Preparing health data for the best experience.'**
  String get syncingDesc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup complete!'**
  String get setupComplete;

  /// No description provided for @deviceReady.
  ///
  /// In en, this message translates to:
  /// **'Your device is ready'**
  String get deviceReady;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @goodHealth.
  ///
  /// In en, this message translates to:
  /// **'Good health'**
  String get goodHealth;

  /// No description provided for @goodHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Your health indicators are within normal range.'**
  String get goodHealthDesc;

  /// No description provided for @todayHealthData.
  ///
  /// In en, this message translates to:
  /// **'Today\'s health data'**
  String get todayHealthData;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'Blood oxygen – SpO₂'**
  String get spo2;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get caloriesBurned;

  /// No description provided for @bodyTemp.
  ///
  /// In en, this message translates to:
  /// **'Body temperature'**
  String get bodyTemp;

  /// No description provided for @stressLevel.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get stressLevel;

  /// No description provided for @disconnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect device'**
  String get disconnectDevice;

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get deleteDevice;

  /// No description provided for @confirmDeleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this device?'**
  String get confirmDeleteDevice;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanWatchInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Hold the smartwatch'**
  String get scanWatchInstruction1;

  /// No description provided for @scanWatchInstruction2.
  ///
  /// In en, this message translates to:
  /// **'in front of the camera'**
  String get scanWatchInstruction2;

  /// No description provided for @scanWatchInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Align the watch with the scan frame'**
  String get scanWatchInstruction3;

  /// No description provided for @qrNotFound.
  ///
  /// In en, this message translates to:
  /// **'QR not found? Try connecting via Bluetooth'**
  String get qrNotFound;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
