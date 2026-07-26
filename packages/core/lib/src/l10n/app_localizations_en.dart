// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TRIVA';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get welcome => 'Welcome';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Use system setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get langIndonesia => 'Indonesian';

  @override
  String get langEnglish => 'English';

  @override
  String get version => 'Version';

  @override
  String get signIn => 'Sign in to TRIVA';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get errorGeneral => 'Something went wrong. Please try again.';

  @override
  String get errorInvalidEmail => 'Enter a valid email address';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get splashTagline => 'Upload, Appraise, Upgrade';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingValueTitle => 'Understand your vehicle value';

  @override
  String get onboardingValueDescription =>
      'Complete the vehicle details and photos to receive a clear indicative valuation.';

  @override
  String get onboardingTrackTitle => 'Track the appraisal';

  @override
  String get onboardingTrackDescription =>
      'Follow the request from submission until an appraiser-reviewed result is ready.';

  @override
  String get onboardingUpgradeTitle => 'Plan the next step';

  @override
  String get onboardingUpgradeDescription =>
      'Continue from the appraisal to financing, repairs, or the most suitable vehicle service.';

  @override
  String get loginSubtitle =>
      'Use your registered account to access services and vehicle history.';

  @override
  String get googleLoginSubtitle =>
      'Use your Google account to securely access your services, vehicles, and activity.';

  @override
  String get googleLoginAction => 'Continue with Google';

  @override
  String get googleLoginLoading => 'Connecting your Google account…';

  @override
  String get googleLoginAccountNotice =>
      'TRIVA only uses your name, email, and profile photo from Google to create and secure your session.';

  @override
  String get googleLoginPrivacyNotice =>
      'By continuing, you agree to the use of your Google identity as needed to provide TRIVA services.';

  @override
  String get googleLoginNetworkError =>
      'The connection to Google was interrupted. Check your internet connection and try again.';

  @override
  String get googleLoginConfigurationError =>
      'Google Sign-In is not available on this device yet. Try again or contact the TRIVA team.';

  @override
  String get googleLoginRejectedError =>
      'This Google account cannot sign in to TRIVA yet. Use another account or contact the TRIVA team.';

  @override
  String get loginFailedTitle => 'Unable to sign in';

  @override
  String get loginFailedAction => 'Close';

  @override
  String get loginBiometricDivider => 'or use biometrics';

  @override
  String get loginBiometricAction => 'Sign in with biometrics';

  @override
  String get homeHeroTitle => 'Understand your vehicle value';

  @override
  String get homeHeroDescription =>
      'One flow to upload vehicle details, track the appraisal, and prepare your next upgrade.';

  @override
  String get homeLoginAction => 'Sign in to TRIVA';

  @override
  String get homeProfileAction => 'View my profile';

  @override
  String get homeServicesTitle => 'TRIVA services';

  @override
  String get homeServicesSubtitle =>
      'TRIVA brings appraisal and Auto2000 Kertajaya follow-up services into one concise experience.';

  @override
  String get serviceAppraisalTitle => 'Trade-in appraisal';

  @override
  String get serviceAppraisalDescription =>
      'Submit vehicle details and photos for an indicative value reviewed by an appraiser.';

  @override
  String get serviceToyotaTitle => 'Toyota service booking';

  @override
  String get serviceToyotaDescription =>
      'Request a Toyota maintenance schedule and track its confirmation.';

  @override
  String get serviceOtoxpertTitle => 'OtoXpert booking';

  @override
  String get serviceOtoxpertDescription =>
      'Find maintenance services for non-Toyota vehicles through OtoXpert.';

  @override
  String get serviceCreditTitle => 'Credit simulation';

  @override
  String get serviceCreditDescription =>
      'Estimate installments based on financing program, down payment, and term.';

  @override
  String get serviceBodyPaintTitle => 'Body & Paint estimate';

  @override
  String get serviceBodyPaintDescription =>
      'Receive an indicative panel repair cost before a physical inspection.';

  @override
  String get homeProcessTitle => 'How appraisal works';

  @override
  String get processVehicleTitle => 'Complete vehicle details';

  @override
  String get processVehicleDescription =>
      'Provide the vehicle identity and upload the requested condition photos.';

  @override
  String get processReviewTitle => 'Appraiser review';

  @override
  String get processReviewDescription =>
      'Comparable data and vehicle condition are checked before publishing the result.';

  @override
  String get processResultTitle => 'Receive and continue';

  @override
  String get processResultDescription =>
      'Use the appraisal result to choose financing, repairs, or a service booking.';

  @override
  String get homeFooter =>
      'TRIVA · Trade-In Vehicle Appraisal · Auto2000 Kertajaya';
}
