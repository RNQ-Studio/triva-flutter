import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id')
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'TRIVA'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang'**
  String get welcome;

  /// No description provided for @appearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @langIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get langIndonesia;

  /// No description provided for @langEnglish.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get langEnglish;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get version;

  /// No description provided for @signIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke TRIVA'**
  String get signIn;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get password;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @name.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get name;

  /// No description provided for @errorGeneral.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala. Silakan coba lagi.'**
  String get errorGeneral;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat email yang valid'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter'**
  String get errorPasswordTooShort;

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Upload, Appraise, Upgrade'**
  String get splashTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Selanjutnya'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get onboardingStart;

  /// No description provided for @onboardingValueTitle.
  ///
  /// In id, this message translates to:
  /// **'Kenali nilai kendaraan'**
  String get onboardingValueTitle;

  /// No description provided for @onboardingValueDescription.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi data dan foto kendaraan untuk memperoleh indikasi nilai yang mudah dipahami.'**
  String get onboardingValueDescription;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In id, this message translates to:
  /// **'Pantau proses appraisal'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackDescription.
  ///
  /// In id, this message translates to:
  /// **'Ikuti perkembangan permintaan dari pengajuan hingga hasil yang telah ditinjau appraiser.'**
  String get onboardingTrackDescription;

  /// No description provided for @onboardingUpgradeTitle.
  ///
  /// In id, this message translates to:
  /// **'Siapkan langkah berikutnya'**
  String get onboardingUpgradeTitle;

  /// No description provided for @onboardingUpgradeDescription.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan hasil appraisal ke simulasi kredit, perbaikan, atau layanan kendaraan yang sesuai.'**
  String get onboardingUpgradeDescription;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan akun yang terdaftar untuk mengakses layanan dan riwayat kendaraan Anda.'**
  String get loginSubtitle;

  /// No description provided for @loginFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat masuk'**
  String get loginFailedTitle;

  /// No description provided for @loginFailedAction.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get loginFailedAction;

  /// No description provided for @loginBiometricDivider.
  ///
  /// In id, this message translates to:
  /// **'atau gunakan biometrik'**
  String get loginBiometricDivider;

  /// No description provided for @loginBiometricAction.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan biometrik'**
  String get loginBiometricAction;

  /// No description provided for @homeHeroTitle.
  ///
  /// In id, this message translates to:
  /// **'Kenali nilai kendaraan Anda'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroDescription.
  ///
  /// In id, this message translates to:
  /// **'Satu alur untuk mengunggah data kendaraan, memantau appraisal, dan menyiapkan langkah upgrade berikutnya.'**
  String get homeHeroDescription;

  /// No description provided for @homeLoginAction.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke TRIVA'**
  String get homeLoginAction;

  /// No description provided for @homeProfileAction.
  ///
  /// In id, this message translates to:
  /// **'Lihat profil saya'**
  String get homeProfileAction;

  /// No description provided for @homeServicesTitle.
  ///
  /// In id, this message translates to:
  /// **'Layanan TRIVA'**
  String get homeServicesTitle;

  /// No description provided for @homeServicesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'TRIVA menyatukan appraisal dan layanan lanjutan Auto2000 Kertajaya dalam pengalaman yang ringkas.'**
  String get homeServicesSubtitle;

  /// No description provided for @serviceAppraisalTitle.
  ///
  /// In id, this message translates to:
  /// **'Appraisal trade-in'**
  String get serviceAppraisalTitle;

  /// No description provided for @serviceAppraisalDescription.
  ///
  /// In id, this message translates to:
  /// **'Kirim data dan foto kendaraan untuk memperoleh indikasi nilai yang ditinjau appraiser.'**
  String get serviceAppraisalDescription;

  /// No description provided for @serviceToyotaTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking servis Toyota'**
  String get serviceToyotaTitle;

  /// No description provided for @serviceToyotaDescription.
  ///
  /// In id, this message translates to:
  /// **'Ajukan jadwal perawatan kendaraan Toyota dan pantau konfirmasinya.'**
  String get serviceToyotaDescription;

  /// No description provided for @serviceOtoxpertTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking OtoXpert'**
  String get serviceOtoxpertTitle;

  /// No description provided for @serviceOtoxpertDescription.
  ///
  /// In id, this message translates to:
  /// **'Temukan layanan perawatan untuk kendaraan non-Toyota melalui jaringan OtoXpert.'**
  String get serviceOtoxpertDescription;

  /// No description provided for @serviceCreditTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulasi kredit'**
  String get serviceCreditTitle;

  /// No description provided for @serviceCreditDescription.
  ///
  /// In id, this message translates to:
  /// **'Hitung estimasi cicilan berdasarkan program kredit, uang muka, dan tenor.'**
  String get serviceCreditDescription;

  /// No description provided for @serviceBodyPaintTitle.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Body & Paint'**
  String get serviceBodyPaintTitle;

  /// No description provided for @serviceBodyPaintDescription.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan indikasi biaya perbaikan panel sebelum pemeriksaan fisik.'**
  String get serviceBodyPaintDescription;

  /// No description provided for @homeProcessTitle.
  ///
  /// In id, this message translates to:
  /// **'Cara kerja appraisal'**
  String get homeProcessTitle;

  /// No description provided for @processVehicleTitle.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi kendaraan'**
  String get processVehicleTitle;

  /// No description provided for @processVehicleDescription.
  ///
  /// In id, this message translates to:
  /// **'Isi identitas kendaraan dan unggah foto kondisi yang diminta.'**
  String get processVehicleDescription;

  /// No description provided for @processReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Appraiser meninjau'**
  String get processReviewTitle;

  /// No description provided for @processReviewDescription.
  ///
  /// In id, this message translates to:
  /// **'Data pembanding dan kondisi kendaraan diperiksa sebelum hasil diterbitkan.'**
  String get processReviewDescription;

  /// No description provided for @processResultTitle.
  ///
  /// In id, this message translates to:
  /// **'Terima hasil dan lanjutkan'**
  String get processResultTitle;

  /// No description provided for @processResultDescription.
  ///
  /// In id, this message translates to:
  /// **'Gunakan hasil appraisal untuk memilih kredit, perbaikan, atau booking layanan.'**
  String get processResultDescription;

  /// No description provided for @homeFooter.
  ///
  /// In id, this message translates to:
  /// **'TRIVA · Trade-In Vehicle Appraisal · Auto2000 Kertajaya'**
  String get homeFooter;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
