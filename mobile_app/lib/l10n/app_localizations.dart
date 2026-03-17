import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('ja'),
    Locale('vi'),
    Locale('zh')
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

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

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
  /// **'View All'**
  String get viewAll;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Health Category'**
  String get healthCategory;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome 👋'**
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
  /// **'Configure Permissions'**
  String get configurePermissions;

  /// No description provided for @conversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistory;

  /// No description provided for @chooseConversation.
  ///
  /// In en, this message translates to:
  /// **'Choose Conversation'**
  String get chooseConversation;

  /// No description provided for @shareConversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Share Conversation History'**
  String get shareConversationHistory;

  /// No description provided for @basicHealthData.
  ///
  /// In en, this message translates to:
  /// **'Basic Health Data'**
  String get basicHealthData;

  /// No description provided for @chooseHealthData.
  ///
  /// In en, this message translates to:
  /// **'Choose Health Data'**
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
  /// **'Add New'**
  String get addNew;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get sendInvite;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @inviteSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invite sent successfully'**
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
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDependent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this dependent from the family?'**
  String get confirmDeleteDependent;

  /// No description provided for @confirmInvite.
  ///
  /// In en, this message translates to:
  /// **'Confirm Invite'**
  String get confirmInvite;

  /// No description provided for @acceptInviteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept the invitation?'**
  String get acceptInviteQuestion;

  /// No description provided for @confirmRejectInvite.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject Invite'**
  String get confirmRejectInvite;

  /// No description provided for @rejectInviteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this invitation?'**
  String get rejectInviteQuestion;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
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
  /// **'Share Data'**
  String get shareData;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @bodyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Body Temperature'**
  String get bodyTemperature;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// Number of steps
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// Sleep duration
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Distance travelled
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @scanningBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Scanning Bluetooth'**
  String get scanningBluetooth;

  /// No description provided for @deviceNearby.
  ///
  /// In en, this message translates to:
  /// **'Please ensure your device is nearby'**
  String get deviceNearby;

  /// No description provided for @deviceVisible.
  ///
  /// In en, this message translates to:
  /// **'and visibility mode is on'**
  String get deviceVisible;

  /// No description provided for @noDeviceFound.
  ///
  /// In en, this message translates to:
  /// **'No device found'**
  String get noDeviceFound;

  /// No description provided for @unnamedDevice.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Device'**
  String get unnamedDevice;

  /// No description provided for @connectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect Device'**
  String get connectDevice;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @bluetoothPairRequest.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Pairing Request'**
  String get bluetoothPairRequest;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @pairSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device paired!'**
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
  /// **'Receive Health Notifications'**
  String get allowHealthNotificationTitle;

  /// No description provided for @allowHealthNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when there is important information you need to know.'**
  String get allowHealthNotificationDesc;

  /// No description provided for @healthAlertDesc.
  ///
  /// In en, this message translates to:
  /// **'Smartwatches can alert you when abnormal signs are detected in heart rate, blood pressure, or other vital metrics.\n\nThese notifications help you take timely action or notify relatives when necessary.'**
  String get healthAlertDesc;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

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

  /// No description provided for @bluetoothPairDesc.
  ///
  /// In en, this message translates to:
  /// **'“Apple Watch Series Demo” wants to pair with your iPhone. Please confirm this code also displays on “Apple Watch Series Demo”. Do not enter this code on any other accessory.'**
  String get bluetoothPairDesc;

  /// No description provided for @todayHealthData.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Health Data'**
  String get todayHealthData;

  /// No description provided for @demoWatch.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch Series Demo'**
  String get demoWatch;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @preparingHealthData.
  ///
  /// In en, this message translates to:
  /// **'We are preparing health data to provide the best experience for you. This process may take a moment.\n\nPlease keep the watch near the phone to ensure smooth synchronization. You will receive a notification when the process is complete.'**
  String get preparingHealthData;

  /// No description provided for @chooseConversationsToShare.
  ///
  /// In en, this message translates to:
  /// **'Choose the conversations you want to share'**
  String get chooseConversationsToShare;

  /// No description provided for @shareImportantHealthData.
  ///
  /// In en, this message translates to:
  /// **'Share important health information with caregivers'**
  String get shareImportantHealthData;

  /// No description provided for @holdSmartwatch.
  ///
  /// In en, this message translates to:
  /// **'Hold the smartwatch'**
  String get holdSmartwatch;

  /// No description provided for @inFrontOfCamera.
  ///
  /// In en, this message translates to:
  /// **'in front of the camera'**
  String get inFrontOfCamera;

  /// No description provided for @alignWatchInFrame.
  ///
  /// In en, this message translates to:
  /// **'Align the watch within the scan frame'**
  String get alignWatchInFrame;

  /// No description provided for @scanFrameAbove.
  ///
  /// In en, this message translates to:
  /// **'above.'**
  String get scanFrameAbove;

  /// No description provided for @qrNotFoundBluetooth.
  ///
  /// In en, this message translates to:
  /// **'QR code not found? Try connecting via Bluetooth'**
  String get qrNotFoundBluetooth;

  /// No description provided for @devicePaired.
  ///
  /// In en, this message translates to:
  /// **'Device Paired'**
  String get devicePaired;

  /// No description provided for @setupContinue.
  ///
  /// In en, this message translates to:
  /// **'You can continue the initial setup process.'**
  String get setupContinue;

  /// No description provided for @disconnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Device'**
  String get disconnectDevice;

  /// No description provided for @syncingDevice.
  ///
  /// In en, this message translates to:
  /// **'Syncing device'**
  String get syncingDevice;

  /// No description provided for @syncingDesc.
  ///
  /// In en, this message translates to:
  /// **'We are preparing health data.'**
  String get syncingDesc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete!'**
  String get setupComplete;

  /// No description provided for @deviceReady.
  ///
  /// In en, this message translates to:
  /// **'Your device is ready to use'**
  String get deviceReady;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @configureSharingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Configure Sharing Permissions'**
  String get configureSharingPermissions;

  /// No description provided for @lastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get lastMessage;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Care AI, hello'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your digital companion, peace of mind for the whole family.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'An OTP code has been sent to phone number {phone}:'**
  String otpSentTo(Object phone);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Care AI Account'**
  String get createAccount;

  /// No description provided for @startHealthJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your health journey with an AI assistant'**
  String get startHealthJourney;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registerSuccess;

  /// No description provided for @startUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Start experiencing Care AI now.'**
  String get startUsingApp;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please check and enter the correct phone number!'**
  String get invalidPhone;

  /// No description provided for @registerAgree.
  ///
  /// In en, this message translates to:
  /// **'By registering, you confirm that you agree to the'**
  String get registerAgree;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get terms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacy_Policy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacy_Policy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy '**
  String get privacyPolicy;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem...'**
  String get describeProblem;

  /// No description provided for @ofCareAI.
  ///
  /// In en, this message translates to:
  /// **'of Care AI.'**
  String get ofCareAI;

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete Device'**
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

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @callHotline.
  ///
  /// In en, this message translates to:
  /// **'Call hotline: 1900 xxxx'**
  String get callHotline;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: support@careai.vn'**
  String get supportEmail;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chooseSubject.
  ///
  /// In en, this message translates to:
  /// **'Choose subject'**
  String get chooseSubject;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully'**
  String get requestSentSuccess;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @hotline.
  ///
  /// In en, this message translates to:
  /// **'Hotline'**
  String get hotline;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// No description provided for @replyWithin24h.
  ///
  /// In en, this message translates to:
  /// **'Reply within 24 hours'**
  String get replyWithin24h;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @faqTextSize.
  ///
  /// In en, this message translates to:
  /// **'How do I change the text size?'**
  String get faqTextSize;

  /// No description provided for @faqAiSupport.
  ///
  /// In en, this message translates to:
  /// **'How can AI assist me?'**
  String get faqAiSupport;

  /// No description provided for @faqVideoCall.
  ///
  /// In en, this message translates to:
  /// **'How do I make a video call with a Digital Human?'**
  String get faqVideoCall;

  /// No description provided for @faqDataSafety.
  ///
  /// In en, this message translates to:
  /// **'Is my information safe?'**
  String get faqDataSafety;

  /// No description provided for @quickContact.
  ///
  /// In en, this message translates to:
  /// **'Quick Contact'**
  String get quickContact;

  /// No description provided for @sendSupportRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Support Request'**
  String get sendSupportRequest;

  /// No description provided for @techSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get techSupport;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountSecurity;

  /// No description provided for @aiFeatures.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiFeatures;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @textSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Apps that support Dynamic Type will adjust to your preferred reading size below.'**
  String get textSizePreview;

  /// No description provided for @infoCollected.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get infoCollected;

  /// No description provided for @infoUsage.
  ///
  /// In en, this message translates to:
  /// **'How We Use Information'**
  String get infoUsage;

  /// No description provided for @infoSharing.
  ///
  /// In en, this message translates to:
  /// **'Information Sharing'**
  String get infoSharing;

  /// No description provided for @dataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get dataSecurity;

  /// No description provided for @userRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get userRights;

  /// No description provided for @infoUsedFor.
  ///
  /// In en, this message translates to:
  /// **'Your information is used to:'**
  String get infoUsedFor;

  /// No description provided for @infoSharedCases.
  ///
  /// In en, this message translates to:
  /// **'We only share your information in the following cases:'**
  String get infoSharedCases;

  /// No description provided for @serviceTracking.
  ///
  /// In en, this message translates to:
  /// **'Provide health tracking, reminder services, and care support.'**
  String get serviceTracking;

  /// No description provided for @alertGuardian.
  ///
  /// In en, this message translates to:
  /// **'Send alerts to guardians or medical staff when necessary.'**
  String get alertGuardian;

  /// No description provided for @improveSystem.
  ///
  /// In en, this message translates to:
  /// **'Improve system stability and personalize the user experience.'**
  String get improveSystem;

  /// No description provided for @ensureSafety.
  ///
  /// In en, this message translates to:
  /// **'Ensure safety, comply with legal regulations, and use for correct purposes.'**
  String get ensureSafety;

  /// No description provided for @shareWithGuardian.
  ///
  /// In en, this message translates to:
  /// **'With guardians or family members with your permission.'**
  String get shareWithGuardian;

  /// No description provided for @shareWithMedical.
  ///
  /// In en, this message translates to:
  /// **'With medical facilities when authorized or in emergencies.'**
  String get shareWithMedical;

  /// No description provided for @privacyIntro1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Health Monitoring Support System. This Privacy Policy applies to all system services, including apps, websites, software, and related platforms.'**
  String get privacyIntro1;

  /// No description provided for @privacyIntro2.
  ///
  /// In en, this message translates to:
  /// **'We are committed to protecting your privacy. This policy explains how we collect, use, share, and protect your personal information. By using the platform, you agree to the contents described below.'**
  String get privacyIntro2;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @loginHistory.
  ///
  /// In en, this message translates to:
  /// **'Login History'**
  String get loginHistory;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @changePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhone;

  /// No description provided for @phoneExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 0912345678 or +84 912345678'**
  String get phoneExample;

  /// No description provided for @phoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated'**
  String get phoneUpdated;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get twoFactorAuth;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @fingerprintOrFace.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or Face Recognition'**
  String get fingerprintOrFace;

  /// No description provided for @noLoginHistory.
  ///
  /// In en, this message translates to:
  /// **'No login history'**
  String get noLoginHistory;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept Terms'**
  String get acceptTerms;

  /// No description provided for @userResponsibility.
  ///
  /// In en, this message translates to:
  /// **'User Responsibility'**
  String get userResponsibility;

  /// No description provided for @serviceLimitations.
  ///
  /// In en, this message translates to:
  /// **'Service Limitations'**
  String get serviceLimitations;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// No description provided for @termsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policy Updates'**
  String get termsUpdates;

  /// No description provided for @unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Name'**
  String get unknownName;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDeleteInvite.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete invitation'**
  String get confirmDeleteInvite;

  /// No description provided for @userResponsibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'You must provide accurate and updated information. You are responsible for the security of your account and all activities that occur under it. Use of the platform for illegal, harmful, or fraudulent purposes is strictly prohibited.'**
  String get userResponsibilityDesc;

  /// No description provided for @serviceLimitationsDesc.
  ///
  /// In en, this message translates to:
  /// **'The Elderly Care Digital Human System is a support tool and does not replace professional medical advice, diagnosis, or treatment.'**
  String get serviceLimitationsDesc;

  /// No description provided for @accountManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'You can suspend or permanently delete your account at any time through app settings or by contacting support.'**
  String get accountManagementDesc;

  /// No description provided for @termsUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'These Terms of Use may be updated over time to comply with new legal regulations or to improve service quality.'**
  String get termsUpdatesDesc;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @noGuardians.
  ///
  /// In en, this message translates to:
  /// **'No guardians yet'**
  String get noGuardians;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @healthCategories.
  ///
  /// In en, this message translates to:
  /// **'Health Categories'**
  String get healthCategories;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get hello;

  /// No description provided for @whatSupportToday.
  ///
  /// In en, this message translates to:
  /// **'What support do you\nneed today?'**
  String get whatSupportToday;

  /// No description provided for @aiIntro.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋 How can I assist you today?'**
  String get aiIntro;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @deleteAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Alert'**
  String get deleteAlertTitle;

  /// No description provided for @deleteAlertWarning.
  ///
  /// In en, this message translates to:
  /// **'This action can lead to serious consequences.'**
  String get deleteAlertWarning;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @heartRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Heart\nRate'**
  String get heartRateTitle;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed description: '**
  String get detailedDescription;

  /// No description provided for @unstableHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Unstable heart rate, higher than normal'**
  String get unstableHeartRate;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @imageSelected.
  ///
  /// In en, this message translates to:
  /// **'📷 Image selected'**
  String get imageSelected;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **'🎤 Voice message'**
  String get voiceMessage;

  /// No description provided for @careAIIntro.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Care AI 💙\nIt\'s great to see you today. Would you like to share how you\'ve been feeling lately?'**
  String get careAIIntro;

  /// No description provided for @chooseGender.
  ///
  /// In en, this message translates to:
  /// **'Choose Gender'**
  String get chooseGender;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name is required.'**
  String get fullNameRequired;

  /// No description provided for @birthDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Birth Date is required.'**
  String get birthDateRequired;

  /// No description provided for @invalidBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format.'**
  String get invalidBirthDate;

  /// No description provided for @mustBe16.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 16 years old.'**
  String get mustBe16;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmail;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required.'**
  String get genderRequired;

  /// No description provided for @weightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight is required.'**
  String get weightRequired;

  /// No description provided for @heightRequired.
  ///
  /// In en, this message translates to:
  /// **'Height is required.'**
  String get heightRequired;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @fullNameExample.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get fullNameExample;

  /// No description provided for @updatePhoto.
  ///
  /// In en, this message translates to:
  /// **'Update photo'**
  String get updatePhoto;

  /// No description provided for @invalidHeightWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid height / weight'**
  String get invalidHeightWeight;

  /// No description provided for @invalidGender.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid gender'**
  String get invalidGender;

  /// Calories burned
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'Blood Oxygen Level – SpO₂'**
  String get spo2;

  /// No description provided for @goodHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Your metrics are all within the normal range. Keep maintaining a healthy lifestyle!'**
  String get goodHealthDesc;

  /// No description provided for @enterGuardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your guardian\'s phone number'**
  String get enterGuardianPhone;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or accessing the Health Monitoring Support System, you agree to comply with these Terms of Use...'**
  String get termsIntro;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask anything...'**
  String get askAnything;

  /// No description provided for @keepDeviceNear.
  ///
  /// In en, this message translates to:
  /// **'Please ensure your device is nearby'**
  String get keepDeviceNear;

  /// No description provided for @enableVisibility.
  ///
  /// In en, this message translates to:
  /// **'and visibility mode is on'**
  String get enableVisibility;

  /// No description provided for @healthNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive Health\nNotifications'**
  String get healthNotificationTitle;

  /// No description provided for @healthNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when there is important information you need to know.'**
  String get healthNotificationDesc;

  /// No description provided for @goodHealth.
  ///
  /// In en, this message translates to:
  /// **'Good health'**
  String get goodHealth;

  /// No description provided for @stressLevel.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get stressLevel;

  /// No description provided for @deleteDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this device?'**
  String get deleteDeviceConfirm;

  /// No description provided for @deleteGuardianConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this guardian from the family?'**
  String get deleteGuardianConfirm;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @rejectInviteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm rejection of invitation'**
  String get rejectInviteConfirm;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get enterMessage;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server.'**
  String get serverError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get typing;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get loadDataError;

  /// No description provided for @aiNotUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I don\'t understand.'**
  String get aiNotUnderstand;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// No description provided for @chooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose action'**
  String get chooseAction;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @soundNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get soundNotification;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @sharedConversations.
  ///
  /// In en, this message translates to:
  /// **'Shared Conversations'**
  String get sharedConversations;

  /// No description provided for @noSharedConversations.
  ///
  /// In en, this message translates to:
  /// **'No shared conversations'**
  String get noSharedConversations;

  /// Body temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Normal health status
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Steps unit
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get stepsUnit;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// No description provided for @confirmDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation?'**
  String get confirmDeleteConversation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
