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

  /// No description provided for @privacyAndAccount.
  ///
  /// In id, this message translates to:
  /// **'Privasi dan akun'**
  String get privacyAndAccount;

  /// No description provided for @privacyPolicy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pelajari cara TRIVA mengelola dan melindungi data Anda'**
  String get privacyPolicySubtitle;

  /// No description provided for @accountDeletion.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun'**
  String get accountDeletion;

  /// No description provided for @accountDeletionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Minta penghapusan akun dan data TRIVA Anda'**
  String get accountDeletionSubtitle;

  /// No description provided for @openLinkError.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak dapat dibuka. Silakan coba lagi.'**
  String get openLinkError;

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

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan akun yang terdaftar untuk mengakses layanan dan riwayat kendaraan Anda.'**
  String get loginSubtitle;

  /// No description provided for @googleLoginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan akun Google untuk mengakses layanan, kendaraan, dan aktivitas Anda dengan aman.'**
  String get googleLoginSubtitle;

  /// No description provided for @googleLoginAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dengan Google'**
  String get googleLoginAction;

  /// No description provided for @googleLoginLoading.
  ///
  /// In id, this message translates to:
  /// **'Menghubungkan akun Google…'**
  String get googleLoginLoading;

  /// No description provided for @googleLoginAccountNotice.
  ///
  /// In id, this message translates to:
  /// **'TRIVA hanya menggunakan nama, email, dan foto profil dari akun Google untuk membuat dan mengamankan sesi Anda.'**
  String get googleLoginAccountNotice;

  /// No description provided for @googleLoginPrivacyNotice.
  ///
  /// In id, this message translates to:
  /// **'Dengan melanjutkan, Anda menyetujui penggunaan identitas Google sesuai kebutuhan layanan TRIVA.'**
  String get googleLoginPrivacyNotice;

  /// No description provided for @googleLoginNetworkError.
  ///
  /// In id, this message translates to:
  /// **'Koneksi ke Google terputus. Periksa internet Anda lalu coba lagi.'**
  String get googleLoginNetworkError;

  /// No description provided for @googleLoginConfigurationError.
  ///
  /// In id, this message translates to:
  /// **'Google Sign-In belum dapat digunakan di perangkat ini. Silakan coba lagi atau hubungi tim TRIVA.'**
  String get googleLoginConfigurationError;

  /// No description provided for @googleLoginRejectedError.
  ///
  /// In id, this message translates to:
  /// **'Akun Google ini belum dapat masuk ke TRIVA. Gunakan akun lain atau hubungi tim TRIVA.'**
  String get googleLoginRejectedError;

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

  /// No description provided for @loginHeroTitle.
  ///
  /// In id, this message translates to:
  /// **'Nilai kendaraan, tanpa tebak-tebakan'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroDescription.
  ///
  /// In id, this message translates to:
  /// **'Appraisal transparan, ditinjau appraiser, dan dapat dipantau dari satu aplikasi.'**
  String get loginHeroDescription;

  /// No description provided for @profileSetupTitle.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi profil Anda'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupDescription.
  ///
  /// In id, this message translates to:
  /// **'Data ini membantu kami menyiapkan appraisal dan menghubungi Anda bila ada informasi yang perlu dikonfirmasi.'**
  String get profileSetupDescription;

  /// No description provided for @phoneNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor ponsel'**
  String get phoneNumber;

  /// No description provided for @city.
  ///
  /// In id, this message translates to:
  /// **'Kota domisili'**
  String get city;

  /// No description provided for @province.
  ///
  /// In id, this message translates to:
  /// **'Provinsi'**
  String get province;

  /// No description provided for @cityOrRegency.
  ///
  /// In id, this message translates to:
  /// **'Kota/kabupaten'**
  String get cityOrRegency;

  /// No description provided for @chooseProvince.
  ///
  /// In id, this message translates to:
  /// **'Pilih provinsi'**
  String get chooseProvince;

  /// No description provided for @chooseCity.
  ///
  /// In id, this message translates to:
  /// **'Pilih kota/kabupaten'**
  String get chooseCity;

  /// No description provided for @chooseProvinceFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih provinsi terlebih dahulu'**
  String get chooseProvinceFirst;

  /// No description provided for @regionLoading.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan pilihan wilayah…'**
  String get regionLoading;

  /// No description provided for @regionLoadError.
  ///
  /// In id, this message translates to:
  /// **'Pilihan wilayah belum dapat dimuat. Periksa koneksi lalu coba lagi.'**
  String get regionLoadError;

  /// No description provided for @regionEmpty.
  ///
  /// In id, this message translates to:
  /// **'Master provinsi dan kota belum tersedia.'**
  String get regionEmpty;

  /// No description provided for @serviceConsentLabel.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui pemrosesan data untuk layanan appraisal TRIVA.'**
  String get serviceConsentLabel;

  /// No description provided for @marketingConsentLabel.
  ///
  /// In id, this message translates to:
  /// **'Saya bersedia menerima informasi promo dan layanan terkait.'**
  String get marketingConsentLabel;

  /// No description provided for @consentRequired.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan layanan wajib diberikan.'**
  String get consentRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In id, this message translates to:
  /// **'Kolom ini wajib diisi.'**
  String get fieldRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In id, this message translates to:
  /// **'Gunakan 9–15 digit nomor ponsel.'**
  String get phoneInvalid;

  /// No description provided for @saveAndContinue.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan lanjutkan'**
  String get saveAndContinue;

  /// No description provided for @profileSetupError.
  ///
  /// In id, this message translates to:
  /// **'Profil belum dapat disimpan. Periksa data lalu coba lagi.'**
  String get profileSetupError;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @activity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get activity;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Apa kebutuhan kendaraan Anda hari ini?'**
  String get homeGreetingSubtitle;

  /// No description provided for @myVehicle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan Saya'**
  String get myVehicle;

  /// No description provided for @emptyVehicleTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kendaraan'**
  String get emptyVehicleTitle;

  /// No description provided for @emptyVehicleDescription.
  ///
  /// In id, this message translates to:
  /// **'Mulai appraisal pertama Anda dan kendaraan akan tersimpan otomatis.'**
  String get emptyVehicleDescription;

  /// No description provided for @startAppraisal.
  ///
  /// In id, this message translates to:
  /// **'Mulai appraisal'**
  String get startAppraisal;

  /// No description provided for @comingSoon.
  ///
  /// In id, this message translates to:
  /// **'Layanan ini segera tersedia.'**
  String get comingSoon;

  /// No description provided for @appraisalStep.
  ///
  /// In id, this message translates to:
  /// **'Langkah {current} dari 4'**
  String appraisalStep(int current);

  /// No description provided for @vehicleIdentityTitle.
  ///
  /// In id, this message translates to:
  /// **'Identitas kendaraan'**
  String get vehicleIdentityTitle;

  /// No description provided for @vehicleIdentityDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan identitas sesuai STNK agar pembanding lebih akurat.'**
  String get vehicleIdentityDescription;

  /// No description provided for @vehicleMake.
  ///
  /// In id, this message translates to:
  /// **'Merek'**
  String get vehicleMake;

  /// No description provided for @chooseVehicleMake.
  ///
  /// In id, this message translates to:
  /// **'Pilih merek mobil'**
  String get chooseVehicleMake;

  /// No description provided for @searchVehicleMake.
  ///
  /// In id, this message translates to:
  /// **'Cari merek mobil'**
  String get searchVehicleMake;

  /// No description provided for @vehicleMakeLoadError.
  ///
  /// In id, this message translates to:
  /// **'Master merek mobil belum dapat dimuat. Periksa koneksi lalu coba lagi.'**
  String get vehicleMakeLoadError;

  /// No description provided for @vehicleMakeEmpty.
  ///
  /// In id, this message translates to:
  /// **'Master merek mobil belum tersedia.'**
  String get vehicleMakeEmpty;

  /// No description provided for @vehicleModel.
  ///
  /// In id, this message translates to:
  /// **'Model'**
  String get vehicleModel;

  /// No description provided for @chooseVehicleModel.
  ///
  /// In id, this message translates to:
  /// **'Pilih model mobil'**
  String get chooseVehicleModel;

  /// No description provided for @chooseVehicleModelFor.
  ///
  /// In id, this message translates to:
  /// **'Pilih model {make}'**
  String chooseVehicleModelFor(String make);

  /// No description provided for @searchVehicleModel.
  ///
  /// In id, this message translates to:
  /// **'Cari model mobil'**
  String get searchVehicleModel;

  /// No description provided for @chooseVehicleMakeFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih merek terlebih dahulu'**
  String get chooseVehicleMakeFirst;

  /// No description provided for @vehicleModelLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat model mobil...'**
  String get vehicleModelLoading;

  /// No description provided for @vehicleModelLoadError.
  ///
  /// In id, this message translates to:
  /// **'Master model mobil belum dapat dimuat.'**
  String get vehicleModelLoadError;

  /// No description provided for @vehicleModelEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada model untuk merek ini.'**
  String get vehicleModelEmpty;

  /// No description provided for @vehicleVariant.
  ///
  /// In id, this message translates to:
  /// **'Varian'**
  String get vehicleVariant;

  /// No description provided for @chooseVehicleVariant.
  ///
  /// In id, this message translates to:
  /// **'Pilih varian kendaraan'**
  String get chooseVehicleVariant;

  /// No description provided for @chooseVehicleVariantFor.
  ///
  /// In id, this message translates to:
  /// **'Pilih varian {model}'**
  String chooseVehicleVariantFor(String model);

  /// No description provided for @searchVehicleVariant.
  ///
  /// In id, this message translates to:
  /// **'Cari varian kendaraan'**
  String get searchVehicleVariant;

  /// No description provided for @chooseVehicleModelFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih model terlebih dahulu'**
  String get chooseVehicleModelFirst;

  /// No description provided for @vehicleVariantLoading.
  ///
  /// In id, this message translates to:
  /// **'Memuat varian kendaraan...'**
  String get vehicleVariantLoading;

  /// No description provided for @vehicleVariantLoadError.
  ///
  /// In id, this message translates to:
  /// **'Master varian kendaraan belum dapat dimuat.'**
  String get vehicleVariantLoadError;

  /// No description provided for @vehicleVariantEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada master varian untuk model ini.'**
  String get vehicleVariantEmpty;

  /// No description provided for @vehicleVariantNotFound.
  ///
  /// In id, this message translates to:
  /// **'Varian tidak ditemukan? Isi manual'**
  String get vehicleVariantNotFound;

  /// No description provided for @vehicleVariantManualHelper.
  ///
  /// In id, this message translates to:
  /// **'Gunakan nama varian yang tercantum di STNK atau dokumen kendaraan.'**
  String get vehicleVariantManualHelper;

  /// No description provided for @chooseFromVariantMaster.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari master varian'**
  String get chooseFromVariantMaster;

  /// No description provided for @vehicleYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get vehicleYear;

  /// No description provided for @chooseVehicleYear.
  ///
  /// In id, this message translates to:
  /// **'Pilih tahun kendaraan'**
  String get chooseVehicleYear;

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail kendaraan'**
  String get vehicleDetailsTitle;

  /// No description provided for @vehicleDetailsDescription.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi spesifikasi dan penggunaan kendaraan saat ini.'**
  String get vehicleDetailsDescription;

  /// No description provided for @editVehicleIdentity.
  ///
  /// In id, this message translates to:
  /// **'Ubah identitas'**
  String get editVehicleIdentity;

  /// No description provided for @transmission.
  ///
  /// In id, this message translates to:
  /// **'Transmisi'**
  String get transmission;

  /// No description provided for @automatic.
  ///
  /// In id, this message translates to:
  /// **'Otomatis'**
  String get automatic;

  /// No description provided for @manual.
  ///
  /// In id, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @fuelType.
  ///
  /// In id, this message translates to:
  /// **'Bahan bakar'**
  String get fuelType;

  /// No description provided for @gasoline.
  ///
  /// In id, this message translates to:
  /// **'Bensin'**
  String get gasoline;

  /// No description provided for @diesel.
  ///
  /// In id, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @hybrid.
  ///
  /// In id, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @electric.
  ///
  /// In id, this message translates to:
  /// **'Listrik'**
  String get electric;

  /// No description provided for @mileage.
  ///
  /// In id, this message translates to:
  /// **'Jarak tempuh'**
  String get mileage;

  /// No description provided for @vehicleColor.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get vehicleColor;

  /// No description provided for @licensePlate.
  ///
  /// In id, this message translates to:
  /// **'Nomor polisi'**
  String get licensePlate;

  /// No description provided for @vehicleCity.
  ///
  /// In id, this message translates to:
  /// **'Kota kendaraan'**
  String get vehicleCity;

  /// No description provided for @conditionTitle.
  ///
  /// In id, this message translates to:
  /// **'Kondisi kendaraan'**
  String get conditionTitle;

  /// No description provided for @conditionDescription.
  ///
  /// In id, this message translates to:
  /// **'Jawab sesuai kondisi sebenarnya. Appraiser akan memvalidasinya dari foto.'**
  String get conditionDescription;

  /// No description provided for @vehicleConditionPercentage.
  ///
  /// In id, this message translates to:
  /// **'Kondisi kendaraan saat ini'**
  String get vehicleConditionPercentage;

  /// No description provided for @vehicleConditionPercentageDescription.
  ///
  /// In id, this message translates to:
  /// **'Geser berdasarkan penilaian kondisi keseluruhan kendaraan.'**
  String get vehicleConditionPercentageDescription;

  /// No description provided for @conditionPercentageValue.
  ///
  /// In id, this message translates to:
  /// **'{value}%'**
  String conditionPercentageValue(int value);

  /// No description provided for @taxStatus.
  ///
  /// In id, this message translates to:
  /// **'Status pajak'**
  String get taxStatus;

  /// No description provided for @taxActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get taxActive;

  /// No description provided for @taxOverdue.
  ///
  /// In id, this message translates to:
  /// **'Menunggak'**
  String get taxOverdue;

  /// No description provided for @unknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak tahu'**
  String get unknown;

  /// No description provided for @floodHistory.
  ///
  /// In id, this message translates to:
  /// **'Pernah terendam banjir?'**
  String get floodHistory;

  /// No description provided for @majorAccidentHistory.
  ///
  /// In id, this message translates to:
  /// **'Pernah kecelakaan berat?'**
  String get majorAccidentHistory;

  /// No description provided for @answerYes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get answerYes;

  /// No description provided for @answerNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get answerNo;

  /// No description provided for @serviceHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat servis'**
  String get serviceHistory;

  /// No description provided for @serviceComplete.
  ///
  /// In id, this message translates to:
  /// **'Lengkap'**
  String get serviceComplete;

  /// No description provided for @servicePartial.
  ///
  /// In id, this message translates to:
  /// **'Sebagian'**
  String get servicePartial;

  /// No description provided for @serviceNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get serviceNone;

  /// No description provided for @ownership.
  ///
  /// In id, this message translates to:
  /// **'Kepemilikan'**
  String get ownership;

  /// No description provided for @ownershipFirst.
  ///
  /// In id, this message translates to:
  /// **'Tangan pertama'**
  String get ownershipFirst;

  /// No description provided for @ownershipSecond.
  ///
  /// In id, this message translates to:
  /// **'Tangan kedua'**
  String get ownershipSecond;

  /// No description provided for @ownershipMore.
  ///
  /// In id, this message translates to:
  /// **'Lebih dari dua'**
  String get ownershipMore;

  /// No description provided for @photosTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto kendaraan'**
  String get photosTitle;

  /// No description provided for @photosDescription.
  ///
  /// In id, this message translates to:
  /// **'Ambil lima foto terang, utuh, dan tanpa filter.'**
  String get photosDescription;

  /// No description provided for @photoFront.
  ///
  /// In id, this message translates to:
  /// **'Tampak depan'**
  String get photoFront;

  /// No description provided for @photoRear.
  ///
  /// In id, this message translates to:
  /// **'Tampak belakang'**
  String get photoRear;

  /// No description provided for @photoLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisi kiri'**
  String get photoLeft;

  /// No description provided for @photoRight.
  ///
  /// In id, this message translates to:
  /// **'Sisi kanan'**
  String get photoRight;

  /// No description provided for @photoDashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard & odometer'**
  String get photoDashboard;

  /// No description provided for @photoAdd.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto'**
  String get photoAdd;

  /// No description provided for @photoReplace.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get photoReplace;

  /// No description provided for @photosComplete.
  ///
  /// In id, this message translates to:
  /// **'Semua foto lengkap'**
  String get photosComplete;

  /// No description provided for @reviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau pengajuan'**
  String get reviewTitle;

  /// No description provided for @reviewDescription.
  ///
  /// In id, this message translates to:
  /// **'Pastikan data berikut sudah sesuai sebelum dikirim.'**
  String get reviewDescription;

  /// No description provided for @reviewVehicle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan'**
  String get reviewVehicle;

  /// No description provided for @reviewCondition.
  ///
  /// In id, this message translates to:
  /// **'Kondisi'**
  String get reviewCondition;

  /// No description provided for @reviewPhotos.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get reviewPhotos;

  /// No description provided for @reviewConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya memahami hasil appraisal bersifat indikatif dan dapat memerlukan inspeksi fisik.'**
  String get reviewConsent;

  /// No description provided for @submitAppraisal.
  ///
  /// In id, this message translates to:
  /// **'Kirim appraisal'**
  String get submitAppraisal;

  /// No description provided for @submittingAppraisal.
  ///
  /// In id, this message translates to:
  /// **'Mengirim appraisal'**
  String get submittingAppraisal;

  /// No description provided for @draftSaved.
  ///
  /// In id, this message translates to:
  /// **'Draft tersimpan otomatis'**
  String get draftSaved;

  /// No description provided for @submittedTitle.
  ///
  /// In id, this message translates to:
  /// **'Appraisal berhasil dikirim'**
  String get submittedTitle;

  /// No description provided for @submittedDescription.
  ///
  /// In id, this message translates to:
  /// **'Kami sedang menyiapkan pembanding dan validasi appraiser.'**
  String get submittedDescription;

  /// No description provided for @referenceNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor referensi'**
  String get referenceNumber;

  /// No description provided for @viewProgress.
  ///
  /// In id, this message translates to:
  /// **'Lihat perkembangan'**
  String get viewProgress;

  /// No description provided for @backToHome.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke beranda'**
  String get backToHome;

  /// No description provided for @activityTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Saya'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas.'**
  String get activityEmpty;

  /// No description provided for @demoActivityNotice.
  ///
  /// In id, this message translates to:
  /// **'Data berikut merupakan contoh tampilan aktivitas dan akan diganti otomatis saat transaksi Anda tersedia.'**
  String get demoActivityNotice;

  /// No description provided for @demoActivityRecentTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas terbaru'**
  String get demoActivityRecentTitle;

  /// No description provided for @demoActivityAppraisalTitle.
  ///
  /// In id, this message translates to:
  /// **'Appraisal Toyota Avanza'**
  String get demoActivityAppraisalTitle;

  /// No description provided for @demoActivityAppraisalSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hari ini, 09.30 · TIA-20260727-0001'**
  String get demoActivityAppraisalSubtitle;

  /// No description provided for @demoActivityReviewStatus.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get demoActivityReviewStatus;

  /// No description provided for @demoActivityServiceTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking servis berkala'**
  String get demoActivityServiceTitle;

  /// No description provided for @demoActivityServiceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Besok, 10.00 · Auto2000 Kertajaya'**
  String get demoActivityServiceSubtitle;

  /// No description provided for @demoActivityConfirmedStatus.
  ///
  /// In id, this message translates to:
  /// **'Jadwal dikonfirmasi'**
  String get demoActivityConfirmedStatus;

  /// No description provided for @demoActivityCreditTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulasi kredit Innova Zenix'**
  String get demoActivityCreditTitle;

  /// No description provided for @demoActivityCreditSubtitle.
  ///
  /// In id, this message translates to:
  /// **'26 Jul 2026 · Tenor 60 bulan'**
  String get demoActivityCreditSubtitle;

  /// No description provided for @demoActivitySavedStatus.
  ///
  /// In id, this message translates to:
  /// **'Simulasi tersimpan'**
  String get demoActivitySavedStatus;

  /// No description provided for @demoActivityBodyPaintTitle.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Body & Paint'**
  String get demoActivityBodyPaintTitle;

  /// No description provided for @demoActivityBodyPaintSubtitle.
  ///
  /// In id, this message translates to:
  /// **'25 Jul 2026 · Bumper belakang'**
  String get demoActivityBodyPaintSubtitle;

  /// No description provided for @demoActivityDraftStatus.
  ///
  /// In id, this message translates to:
  /// **'Draft'**
  String get demoActivityDraftStatus;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan appraisal, jadwal layanan, dan penawaran akan muncul di sini.'**
  String get notificationsEmptyDescription;

  /// No description provided for @appraisalProgressTitle.
  ///
  /// In id, this message translates to:
  /// **'Perkembangan appraisal'**
  String get appraisalProgressTitle;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Perbarui'**
  String get refresh;

  /// No description provided for @needsActionTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto perlu diperbaiki'**
  String get needsActionTitle;

  /// No description provided for @needsActionDescription.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto yang ditandai agar appraiser dapat melanjutkan penilaian.'**
  String get needsActionDescription;

  /// No description provided for @sendReplacement.
  ///
  /// In id, this message translates to:
  /// **'Kirim foto pengganti'**
  String get sendReplacement;

  /// No description provided for @underReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Sedang dinilai appraiser'**
  String get underReviewTitle;

  /// No description provided for @underReviewDescription.
  ///
  /// In id, this message translates to:
  /// **'Data kendaraan, kondisi, dan pembanding sedang divalidasi.'**
  String get underReviewDescription;

  /// No description provided for @resultTitle.
  ///
  /// In id, this message translates to:
  /// **'Hasil appraisal'**
  String get resultTitle;

  /// No description provided for @tradeInEstimate.
  ///
  /// In id, this message translates to:
  /// **'Estimasi trade-in'**
  String get tradeInEstimate;

  /// No description provided for @marketRange.
  ///
  /// In id, this message translates to:
  /// **'Rentang harga pasar'**
  String get marketRange;

  /// No description provided for @confidence.
  ///
  /// In id, this message translates to:
  /// **'Tingkat keyakinan'**
  String get confidence;

  /// No description provided for @comparableCount.
  ///
  /// In id, this message translates to:
  /// **'{count} kendaraan pembanding'**
  String comparableCount(int count);

  /// No description provided for @marketDataAsOf.
  ///
  /// In id, this message translates to:
  /// **'Data pembanding per'**
  String get marketDataAsOf;

  /// No description provided for @marketDataSources.
  ///
  /// In id, this message translates to:
  /// **'Sumber data'**
  String get marketDataSources;

  /// No description provided for @appraisalAdjustments.
  ///
  /// In id, this message translates to:
  /// **'Faktor penyesuaian'**
  String get appraisalAdjustments;

  /// No description provided for @validUntil.
  ///
  /// In id, this message translates to:
  /// **'Berlaku hingga {date}'**
  String validUntil(String date);

  /// No description provided for @acceptPrice.
  ///
  /// In id, this message translates to:
  /// **'Terima harga'**
  String get acceptPrice;

  /// No description provided for @declinePrice.
  ///
  /// In id, this message translates to:
  /// **'Belum cocok'**
  String get declinePrice;

  /// No description provided for @decideLater.
  ///
  /// In id, this message translates to:
  /// **'Putuskan nanti'**
  String get decideLater;

  /// No description provided for @scheduleInspection.
  ///
  /// In id, this message translates to:
  /// **'Jadwalkan inspeksi'**
  String get scheduleInspection;

  /// No description provided for @inspectionDate.
  ///
  /// In id, this message translates to:
  /// **'Waktu inspeksi'**
  String get inspectionDate;

  /// No description provided for @inspectionNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get inspectionNotes;

  /// No description provided for @decisionAcceptedTitle.
  ///
  /// In id, this message translates to:
  /// **'Harga appraisal diterima'**
  String get decisionAcceptedTitle;

  /// No description provided for @decisionAcceptedDescription.
  ///
  /// In id, this message translates to:
  /// **'Nilai trade-in siap digunakan untuk langkah pembelian kendaraan berikutnya.'**
  String get decisionAcceptedDescription;

  /// No description provided for @decisionRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Keputusan tersimpan'**
  String get decisionRejectedTitle;

  /// No description provided for @decisionRejectedDescription.
  ///
  /// In id, this message translates to:
  /// **'Data kendaraan tetap tersimpan dan dapat dilanjutkan ke estimasi perbaikan.'**
  String get decisionRejectedDescription;

  /// No description provided for @decisionDeferredMessage.
  ///
  /// In id, this message translates to:
  /// **'Hasil tetap tersedia di Aktivitas Saya.'**
  String get decisionDeferredMessage;

  /// No description provided for @statusDraft.
  ///
  /// In id, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @loadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data belum dapat dimuat.'**
  String get loadFailed;

  /// No description provided for @photoGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari galeri'**
  String get photoGallery;

  /// No description provided for @photoPermissionError.
  ///
  /// In id, this message translates to:
  /// **'Kamera atau galeri tidak dapat dibuka. Periksa izin aplikasi.'**
  String get photoPermissionError;

  /// No description provided for @uploadPreparingVehicle.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan data kendaraan'**
  String get uploadPreparingVehicle;

  /// No description provided for @uploadCreatingRequest.
  ///
  /// In id, this message translates to:
  /// **'Membuat permintaan appraisal'**
  String get uploadCreatingRequest;

  /// No description provided for @uploadSavingCondition.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan checklist kondisi'**
  String get uploadSavingCondition;

  /// No description provided for @uploadingPhoto.
  ///
  /// In id, this message translates to:
  /// **'Mengunggah foto {current} dari 5'**
  String uploadingPhoto(int current);

  /// No description provided for @uploadSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim appraisal'**
  String get uploadSending;

  /// No description provided for @uploadSuccess.
  ///
  /// In id, this message translates to:
  /// **'Appraisal berhasil dikirim'**
  String get uploadSuccess;

  /// No description provided for @incompleteDraftError.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi seluruh data sebelum mengirim.'**
  String get incompleteDraftError;

  /// No description provided for @submissionNetworkError.
  ///
  /// In id, this message translates to:
  /// **'Koneksi terputus. Draft tersimpan; coba kirim kembali.'**
  String get submissionNetworkError;

  /// No description provided for @submissionAuthError.
  ///
  /// In id, this message translates to:
  /// **'Sesi Anda berakhir. Masuk kembali untuk melanjutkan.'**
  String get submissionAuthError;

  /// No description provided for @submissionGeneralError.
  ///
  /// In id, this message translates to:
  /// **'Appraisal belum dapat dikirim. Draft Anda tetap tersimpan.'**
  String get submissionGeneralError;

  /// No description provided for @inspectionScheduledDescription.
  ///
  /// In id, this message translates to:
  /// **'Jadwal tersimpan. Tim TRIVA akan menghubungi Anda untuk konfirmasi inspeksi.'**
  String get inspectionScheduledDescription;

  /// No description provided for @adminPanel.
  ///
  /// In id, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @adminPanelTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat operasional'**
  String get adminPanelTitle;

  /// No description provided for @adminPanelSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola layanan sesuai akses yang diberikan kepada akun Anda.'**
  String get adminPanelSubtitle;

  /// No description provided for @adminAccessDenied.
  ///
  /// In id, this message translates to:
  /// **'Akses admin tidak tersedia'**
  String get adminAccessDenied;

  /// No description provided for @adminAccessDeniedDescription.
  ///
  /// In id, this message translates to:
  /// **'Akun ini tidak memiliki izin untuk membuka modul operasional.'**
  String get adminAccessDeniedDescription;

  /// No description provided for @adminUserAccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola akses admin'**
  String get adminUserAccessTitle;

  /// No description provided for @adminUserAccessDescription.
  ///
  /// In id, this message translates to:
  /// **'Cari user existing dan berikan akses ke Admin Panel.'**
  String get adminUserAccessDescription;

  /// No description provided for @adminUserSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama atau email user'**
  String get adminUserSearchHint;

  /// No description provided for @adminUserEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'User tidak ditemukan'**
  String get adminUserEmptyTitle;

  /// No description provided for @adminUserEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Periksa kata pencarian atau coba nama dan email lain.'**
  String get adminUserEmptyDescription;

  /// No description provided for @adminUserAlreadyAdmin.
  ///
  /// In id, this message translates to:
  /// **'Sudah memiliki akses admin'**
  String get adminUserAlreadyAdmin;

  /// No description provided for @adminUserInactive.
  ///
  /// In id, this message translates to:
  /// **'Akun tidak aktif'**
  String get adminUserInactive;

  /// No description provided for @adminUserGrantAction.
  ///
  /// In id, this message translates to:
  /// **'Jadikan admin'**
  String get adminUserGrantAction;

  /// No description provided for @adminUserGrantConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadikan {name} sebagai admin?'**
  String adminUserGrantConfirmTitle(String name);

  /// No description provided for @adminUserGrantConfirmDescription.
  ///
  /// In id, this message translates to:
  /// **'User akan memperoleh izin untuk mengakses dan mengelola modul operasional.'**
  String get adminUserGrantConfirmDescription;

  /// No description provided for @adminUserGrantSuccess.
  ///
  /// In id, this message translates to:
  /// **'Akses admin untuk {name} berhasil diberikan.'**
  String adminUserGrantSuccess(String name);

  /// No description provided for @adminUserGrantFailed.
  ///
  /// In id, this message translates to:
  /// **'Akses admin belum dapat diberikan. Coba lagi.'**
  String get adminUserGrantFailed;

  /// No description provided for @loadMore.
  ///
  /// In id, this message translates to:
  /// **'Muat lainnya'**
  String get loadMore;

  /// No description provided for @clear.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan'**
  String get clear;

  /// No description provided for @moduleActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get moduleActive;

  /// No description provided for @moduleUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Belum diaktifkan'**
  String get moduleUnavailable;

  /// No description provided for @adminBookingQueue.
  ///
  /// In id, this message translates to:
  /// **'Booking Toyota'**
  String get adminBookingQueue;

  /// No description provided for @adminBookingQueueDescription.
  ///
  /// In id, this message translates to:
  /// **'Antrean konfirmasi, jadwal, dan progres servis.'**
  String get adminBookingQueueDescription;

  /// No description provided for @adminNoBookings.
  ///
  /// In id, this message translates to:
  /// **'Antrean booking kosong'**
  String get adminNoBookings;

  /// No description provided for @adminNoBookingsDescription.
  ///
  /// In id, this message translates to:
  /// **'Permintaan Booking Toyota akan muncul di sini.'**
  String get adminNoBookingsDescription;

  /// No description provided for @adminNoValidSlots.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada slot mendatang yang valid untuk tindakan ini.'**
  String get adminNoValidSlots;

  /// No description provided for @sortUpdatedDesc.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diperbarui'**
  String get sortUpdatedDesc;

  /// No description provided for @sortDueAsc.
  ///
  /// In id, this message translates to:
  /// **'Tenggat SLA terdekat'**
  String get sortDueAsc;

  /// No description provided for @sortSlotAsc.
  ///
  /// In id, this message translates to:
  /// **'Preferensi jadwal terdekat'**
  String get sortSlotAsc;

  /// No description provided for @searchBookings.
  ///
  /// In id, this message translates to:
  /// **'Cari referensi, pelanggan, atau kendaraan'**
  String get searchBookings;

  /// No description provided for @bookingToyotaTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking Toyota'**
  String get bookingToyotaTitle;

  /// No description provided for @bookingStepVehicle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan'**
  String get bookingStepVehicle;

  /// No description provided for @bookingStepService.
  ///
  /// In id, this message translates to:
  /// **'Layanan'**
  String get bookingStepService;

  /// No description provided for @bookingStepSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get bookingStepSchedule;

  /// No description provided for @bookingStepReview.
  ///
  /// In id, this message translates to:
  /// **'Tinjau'**
  String get bookingStepReview;

  /// No description provided for @bookingSelectVehicleTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kendaraan Toyota'**
  String get bookingSelectVehicleTitle;

  /// No description provided for @bookingSelectVehicleDescription.
  ///
  /// In id, this message translates to:
  /// **'Gunakan kendaraan tersimpan agar detail servis tidak perlu diisi ulang.'**
  String get bookingSelectVehicleDescription;

  /// No description provided for @bookingNoVehicles.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kendaraan tersimpan'**
  String get bookingNoVehicles;

  /// No description provided for @bookingNoVehiclesDescription.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan kendaraan terlebih dahulu, lalu kembali ke Booking Toyota.'**
  String get bookingNoVehiclesDescription;

  /// No description provided for @addVehicle.
  ///
  /// In id, this message translates to:
  /// **'Tambah kendaraan'**
  String get addVehicle;

  /// No description provided for @bookingAddVehicleTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah kendaraan untuk booking'**
  String get bookingAddVehicleTitle;

  /// No description provided for @bookingAddVehicleDescription.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi data kendaraan sekali agar dapat dipakai kembali di seluruh layanan TRIVA.'**
  String get bookingAddVehicleDescription;

  /// No description provided for @useThisVehicle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan kendaraan ini'**
  String get useThisVehicle;

  /// No description provided for @chooseAnotherVehicle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kendaraan lain'**
  String get chooseAnotherVehicle;

  /// No description provided for @nonToyotaTitle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan ini bukan Toyota'**
  String get nonToyotaTitle;

  /// No description provided for @nonToyotaDescription.
  ///
  /// In id, this message translates to:
  /// **'Booking Toyota hanya tersedia untuk kendaraan Toyota. Anda tetap dapat melanjutkan servis melalui jaringan OtoXpert.'**
  String get nonToyotaDescription;

  /// No description provided for @continueOtoxpert.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Booking OtoXpert'**
  String get continueOtoxpert;

  /// No description provided for @otoxpertUnavailableMessage.
  ///
  /// In id, this message translates to:
  /// **'Booking OtoXpert belum diaktifkan. Kendaraan Anda tetap tersimpan.'**
  String get otoxpertUnavailableMessage;

  /// No description provided for @serviceWhereTitle.
  ///
  /// In id, this message translates to:
  /// **'Servis di mana?'**
  String get serviceWhereTitle;

  /// No description provided for @serviceWhereDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih cara servis yang paling sesuai.'**
  String get serviceWhereDescription;

  /// No description provided for @workshopService.
  ///
  /// In id, this message translates to:
  /// **'Workshop Auto2000'**
  String get workshopService;

  /// No description provided for @workshopServiceDescription.
  ///
  /// In id, this message translates to:
  /// **'Datang ke workshop pada jadwal yang telah dikonfirmasi.'**
  String get workshopServiceDescription;

  /// No description provided for @thsService.
  ///
  /// In id, this message translates to:
  /// **'Toyota Home Service (THS)'**
  String get thsService;

  /// No description provided for @thsServiceDescription.
  ///
  /// In id, this message translates to:
  /// **'Teknisi datang ke alamat dalam area layanan.'**
  String get thsServiceDescription;

  /// No description provided for @scheduleNeedsConfirmation.
  ///
  /// In id, this message translates to:
  /// **'Jadwal yang dipilih masih perlu dikonfirmasi petugas.'**
  String get scheduleNeedsConfirmation;

  /// No description provided for @chooseServiceType.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis layanan'**
  String get chooseServiceType;

  /// No description provided for @serviceTypeTitle.
  ///
  /// In id, this message translates to:
  /// **'Apa yang dibutuhkan?'**
  String get serviceTypeTitle;

  /// No description provided for @serviceTypeDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih satu layanan untuk kendaraan Toyota Anda.'**
  String get serviceTypeDescription;

  /// No description provided for @serviceTypesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Jenis layanan belum tersedia'**
  String get serviceTypesEmpty;

  /// No description provided for @serviceTypesEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Admin belum mengaktifkan layanan untuk pilihan ini.'**
  String get serviceTypesEmptyDescription;

  /// No description provided for @serviceAdvisorConfirmation.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi akhir akan dikonfirmasi Service Advisor.'**
  String get serviceAdvisorConfirmation;

  /// No description provided for @continueServiceDetails.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke detail servis'**
  String get continueServiceDetails;

  /// No description provided for @serviceDetailsTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail servis'**
  String get serviceDetailsTitle;

  /// No description provided for @serviceDetailsDescription.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi kilometer dan keluhan agar petugas dapat menyiapkan layanan.'**
  String get serviceDetailsDescription;

  /// No description provided for @currentMileage.
  ///
  /// In id, this message translates to:
  /// **'Kilometer saat ini'**
  String get currentMileage;

  /// No description provided for @complaint.
  ///
  /// In id, this message translates to:
  /// **'Keluhan atau catatan'**
  String get complaint;

  /// No description provided for @complaintHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan gejala atau kebutuhan servis'**
  String get complaintHint;

  /// No description provided for @supportingPhotoOptional.
  ///
  /// In id, this message translates to:
  /// **'Foto pendukung (opsional)'**
  String get supportingPhotoOptional;

  /// No description provided for @addSupportingPhoto.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get addSupportingPhoto;

  /// No description provided for @removeSupportingPhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get removeSupportingPhoto;

  /// No description provided for @supportingPhotoPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Foto hanya dapat dilihat petugas berwenang.'**
  String get supportingPhotoPrivacy;

  /// No description provided for @chooseSchedule.
  ///
  /// In id, this message translates to:
  /// **'Pilih jadwal'**
  String get chooseSchedule;

  /// No description provided for @schedulePreferenceTitle.
  ///
  /// In id, this message translates to:
  /// **'Kapan Anda ingin servis?'**
  String get schedulePreferenceTitle;

  /// No description provided for @schedulePreferenceDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih dua waktu berbeda sebagai preferensi utama dan alternatif.'**
  String get schedulePreferenceDescription;

  /// No description provided for @primaryPreference.
  ///
  /// In id, this message translates to:
  /// **'Jadwal utama'**
  String get primaryPreference;

  /// No description provided for @alternativePreference.
  ///
  /// In id, this message translates to:
  /// **'Jadwal alternatif'**
  String get alternativePreference;

  /// No description provided for @preferenceNotSlot.
  ///
  /// In id, this message translates to:
  /// **'Waktu ini adalah preferensi dan belum mengunci slot.'**
  String get preferenceNotSlot;

  /// No description provided for @bookingLeadTimeNotice.
  ///
  /// In id, this message translates to:
  /// **'Ajukan minimal {days} hari sebelum tanggal yang dipilih.'**
  String bookingLeadTimeNotice(int days);

  /// No description provided for @availabilityEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada waktu yang dapat diminta'**
  String get availabilityEmpty;

  /// No description provided for @availabilityEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Ubah lokasi atau layanan, lalu periksa kembali jadwal.'**
  String get availabilityEmptyDescription;

  /// No description provided for @availabilityLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Jadwal belum dapat dimuat. Periksa koneksi lalu coba lagi.'**
  String get availabilityLoadFailed;

  /// No description provided for @reviewBooking.
  ///
  /// In id, this message translates to:
  /// **'Tinjau booking'**
  String get reviewBooking;

  /// No description provided for @thsAddressTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi kunjungan THS'**
  String get thsAddressTitle;

  /// No description provided for @thsAddressDescription.
  ///
  /// In id, this message translates to:
  /// **'Alamat dan pin wajib agar petugas dapat memeriksa cakupan layanan.'**
  String get thsAddressDescription;

  /// No description provided for @fullAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat lengkap'**
  String get fullAddress;

  /// No description provided for @locationNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan lokasi'**
  String get locationNotes;

  /// No description provided for @latitude.
  ///
  /// In id, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In id, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @setManualPin.
  ///
  /// In id, this message translates to:
  /// **'Atur pin manual'**
  String get setManualPin;

  /// No description provided for @pinLocationSet.
  ///
  /// In id, this message translates to:
  /// **'Pin lokasi sudah diatur'**
  String get pinLocationSet;

  /// No description provided for @thsAddressPinRequired.
  ///
  /// In id, this message translates to:
  /// **'Alamat, kota, dan pin lokasi wajib untuk THS.'**
  String get thsAddressPinRequired;

  /// No description provided for @thsCoverageAvailable.
  ///
  /// In id, this message translates to:
  /// **'Area layanan tersedia'**
  String get thsCoverageAvailable;

  /// No description provided for @thsCoverageUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Alamat belum termasuk area layanan THS'**
  String get thsCoverageUnavailable;

  /// No description provided for @manualPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur koordinat lokasi'**
  String get manualPinTitle;

  /// No description provided for @manualPinDescription.
  ///
  /// In id, this message translates to:
  /// **'Masukkan koordinat dari peta perangkat bila izin lokasi tidak tersedia.'**
  String get manualPinDescription;

  /// No description provided for @savePin.
  ///
  /// In id, this message translates to:
  /// **'Simpan pin'**
  String get savePin;

  /// No description provided for @reviewServiceRequestTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau permintaan servis'**
  String get reviewServiceRequestTitle;

  /// No description provided for @reviewServiceRequestDescription.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali detail sebelum permintaan dikirim.'**
  String get reviewServiceRequestDescription;

  /// No description provided for @location.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get location;

  /// No description provided for @service.
  ///
  /// In id, this message translates to:
  /// **'Layanan'**
  String get service;

  /// No description provided for @primarySchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal utama'**
  String get primarySchedule;

  /// No description provided for @alternativeSchedule.
  ///
  /// In id, this message translates to:
  /// **'Alternatif'**
  String get alternativeSchedule;

  /// No description provided for @contactChannel.
  ///
  /// In id, this message translates to:
  /// **'Channel konfirmasi'**
  String get contactChannel;

  /// No description provided for @requestToConfirmNotice.
  ///
  /// In id, this message translates to:
  /// **'Jadwal pilihan adalah preferensi dan belum dikonfirmasi.'**
  String get requestToConfirmNotice;

  /// No description provided for @serviceBookingConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui pemrosesan data untuk permintaan servis ini.'**
  String get serviceBookingConsent;

  /// No description provided for @submitServiceRequest.
  ///
  /// In id, this message translates to:
  /// **'Kirim permintaan servis'**
  String get submitServiceRequest;

  /// No description provided for @serviceRequestSubmittedTitle.
  ///
  /// In id, this message translates to:
  /// **'Permintaan servis berhasil dikirim'**
  String get serviceRequestSubmittedTitle;

  /// No description provided for @serviceRequestSubmittedDescription.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Anda belum dikonfirmasi.'**
  String get serviceRequestSubmittedDescription;

  /// No description provided for @awaitingStaffConfirmation.
  ///
  /// In id, this message translates to:
  /// **'Menunggu konfirmasi petugas'**
  String get awaitingStaffConfirmation;

  /// No description provided for @viewBookingDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail booking'**
  String get viewBookingDetail;

  /// No description provided for @bookingDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail booking'**
  String get bookingDetailTitle;

  /// No description provided for @bookingTimelineTitle.
  ///
  /// In id, this message translates to:
  /// **'Perkembangan booking'**
  String get bookingTimelineTitle;

  /// No description provided for @alternativeProposedTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal alternatif diajukan'**
  String get alternativeProposedTitle;

  /// No description provided for @originalScheduleUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Jadwal utama belum tersedia'**
  String get originalScheduleUnavailable;

  /// No description provided for @advisorProposal.
  ///
  /// In id, this message translates to:
  /// **'Usulan Service Advisor'**
  String get advisorProposal;

  /// No description provided for @proposalDeadline.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu tanggapan'**
  String get proposalDeadline;

  /// No description provided for @noScheduleConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jadwal yang dikonfirmasi.'**
  String get noScheduleConfirmed;

  /// No description provided for @acceptAlternative.
  ///
  /// In id, this message translates to:
  /// **'Terima jadwal alternatif'**
  String get acceptAlternative;

  /// No description provided for @rejectAlternative.
  ///
  /// In id, this message translates to:
  /// **'Tolak dan pilih jadwal lain'**
  String get rejectAlternative;

  /// No description provided for @chooseReplacementSchedule.
  ///
  /// In id, this message translates to:
  /// **'Pilih jadwal pengganti'**
  String get chooseReplacementSchedule;

  /// No description provided for @rejectionReasonOptional.
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan (opsional)'**
  String get rejectionReasonOptional;

  /// No description provided for @bookingRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Layanan belum dapat dijadwalkan'**
  String get bookingRejectedTitle;

  /// No description provided for @rejectionReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan penolakan'**
  String get rejectionReason;

  /// No description provided for @createNewRequest.
  ///
  /// In id, this message translates to:
  /// **'Buat permintaan baru'**
  String get createNewRequest;

  /// No description provided for @backToActivity.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke aktivitas'**
  String get backToActivity;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking dikonfirmasi'**
  String get bookingConfirmedTitle;

  /// No description provided for @confirmedSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal servis Anda'**
  String get confirmedSchedule;

  /// No description provided for @serviceAdvisor.
  ///
  /// In id, this message translates to:
  /// **'PIC (Service Advisor)'**
  String get serviceAdvisor;

  /// No description provided for @partnerBookingNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor booking partner'**
  String get partnerBookingNumber;

  /// No description provided for @arrivalInstructions.
  ///
  /// In id, this message translates to:
  /// **'Instruksi kedatangan'**
  String get arrivalInstructions;

  /// No description provided for @openDirections.
  ///
  /// In id, this message translates to:
  /// **'Buka petunjuk lokasi'**
  String get openDirections;

  /// No description provided for @requestReschedule.
  ///
  /// In id, this message translates to:
  /// **'Minta jadwal ulang'**
  String get requestReschedule;

  /// No description provided for @cancelBooking.
  ///
  /// In id, this message translates to:
  /// **'Batalkan booking'**
  String get cancelBooking;

  /// No description provided for @rescheduleTitle.
  ///
  /// In id, this message translates to:
  /// **'Minta jadwal ulang'**
  String get rescheduleTitle;

  /// No description provided for @currentConfirmedSchedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal saat ini (terkonfirmasi)'**
  String get currentConfirmedSchedule;

  /// No description provided for @newPrimarySchedule.
  ///
  /// In id, this message translates to:
  /// **'Pilihan utama baru'**
  String get newPrimarySchedule;

  /// No description provided for @newAlternativeSchedule.
  ///
  /// In id, this message translates to:
  /// **'Pilihan alternatif baru'**
  String get newAlternativeSchedule;

  /// No description provided for @changeReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan'**
  String get changeReason;

  /// No description provided for @oldScheduleRemains.
  ///
  /// In id, this message translates to:
  /// **'Jadwal lama tetap berlaku sampai perubahan dikonfirmasi petugas.'**
  String get oldScheduleRemains;

  /// No description provided for @submitReschedule.
  ///
  /// In id, this message translates to:
  /// **'Kirim permintaan ulang'**
  String get submitReschedule;

  /// No description provided for @serviceInProgressTitle.
  ///
  /// In id, this message translates to:
  /// **'Sedang dikerjakan'**
  String get serviceInProgressTitle;

  /// No description provided for @vehicleBeingServiced.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan Anda sedang ditangani'**
  String get vehicleBeingServiced;

  /// No description provided for @contactServiceAdvisor.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Service Advisor'**
  String get contactServiceAdvisor;

  /// No description provided for @viewServiceDetails.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail layanan'**
  String get viewServiceDetails;

  /// No description provided for @serviceCompletedTitle.
  ///
  /// In id, this message translates to:
  /// **'Servis selesai'**
  String get serviceCompletedTitle;

  /// No description provided for @serviceCompletedDescription.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan Anda sudah selesai ditangani.'**
  String get serviceCompletedDescription;

  /// No description provided for @workshopFinalDetailsNotice.
  ///
  /// In id, this message translates to:
  /// **'Rincian pekerjaan dan biaya final mengikuti dokumen workshop.'**
  String get workshopFinalDetailsNotice;

  /// No description provided for @viewInActivity.
  ///
  /// In id, this message translates to:
  /// **'Lihat di Aktivitas'**
  String get viewInActivity;

  /// No description provided for @leaveServiceFeedback.
  ///
  /// In id, this message translates to:
  /// **'Beri masukan layanan'**
  String get leaveServiceFeedback;

  /// No description provided for @bookingCancelledTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking dibatalkan'**
  String get bookingCancelledTitle;

  /// No description provided for @bookingExpiredTitle.
  ///
  /// In id, this message translates to:
  /// **'Permintaan telah kedaluwarsa'**
  String get bookingExpiredTitle;

  /// No description provided for @bookingNoShowTitle.
  ///
  /// In id, this message translates to:
  /// **'Kunjungan tidak tercatat'**
  String get bookingNoShowTitle;

  /// No description provided for @bookingGenericDescription.
  ///
  /// In id, this message translates to:
  /// **'Periksa timeline untuk pembaruan terbaru dari petugas.'**
  String get bookingGenericDescription;

  /// No description provided for @cancelReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan pembatalan'**
  String get cancelReason;

  /// No description provided for @confirmCancellation.
  ///
  /// In id, this message translates to:
  /// **'Batalkan booking ini?'**
  String get confirmCancellation;

  /// No description provided for @confirmCancellationDescription.
  ///
  /// In id, this message translates to:
  /// **'Riwayat booking tetap tersimpan di Aktivitas Saya.'**
  String get confirmCancellationDescription;

  /// No description provided for @bookingMutationFailed.
  ///
  /// In id, this message translates to:
  /// **'Perubahan belum dapat disimpan. Coba lagi.'**
  String get bookingMutationFailed;

  /// No description provided for @bookingOfflineError.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang offline. Draft tetap tersimpan; sambungkan internet lalu coba lagi.'**
  String get bookingOfflineError;

  /// No description provided for @bookingDuplicateError.
  ///
  /// In id, this message translates to:
  /// **'Booking aktif dengan kendaraan dan jadwal yang sama sudah tersedia.'**
  String get bookingDuplicateError;

  /// No description provided for @bookingIncompleteError.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi seluruh data wajib sebelum mengirim.'**
  String get bookingIncompleteError;

  /// No description provided for @activityEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Appraisal, booking, estimasi Body & Paint, dan simulasi kredit Anda akan muncul di sini.'**
  String get activityEmptyDescription;

  /// No description provided for @activityAppraisalsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas appraisal gagal dimuat. Booking servis Anda tetap ditampilkan.'**
  String get activityAppraisalsLoadFailed;

  /// No description provided for @activityBookingsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas booking servis gagal dimuat. Appraisal Anda tetap ditampilkan.'**
  String get activityBookingsLoadFailed;

  /// No description provided for @activityAppraisalLabel.
  ///
  /// In id, this message translates to:
  /// **'Trade-in appraisal'**
  String get activityAppraisalLabel;

  /// No description provided for @activityToyotaBookingLabel.
  ///
  /// In id, this message translates to:
  /// **'Booking Toyota'**
  String get activityToyotaBookingLabel;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In id, this message translates to:
  /// **'Tandai semua dibaca'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsMarkAllReadError.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi gagal ditandai dibaca. Silakan coba lagi.'**
  String get notificationsMarkAllReadError;

  /// No description provided for @notificationsLoadError.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi belum dapat dimuat.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsOfflineError.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi tidak dapat diperbarui saat offline.'**
  String get notificationsOfflineError;

  /// No description provided for @notificationOpenAction.
  ///
  /// In id, this message translates to:
  /// **'Buka detail'**
  String get notificationOpenAction;

  /// No description provided for @adminConfirmBooking.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi booking'**
  String get adminConfirmBooking;

  /// No description provided for @adminProposeAlternative.
  ///
  /// In id, this message translates to:
  /// **'Ajukan jadwal alternatif'**
  String get adminProposeAlternative;

  /// No description provided for @adminRejectBooking.
  ///
  /// In id, this message translates to:
  /// **'Tolak permintaan'**
  String get adminRejectBooking;

  /// No description provided for @adminApproveReschedule.
  ///
  /// In id, this message translates to:
  /// **'Setujui jadwal ulang'**
  String get adminApproveReschedule;

  /// No description provided for @adminRejectReschedule.
  ///
  /// In id, this message translates to:
  /// **'Tolak jadwal ulang'**
  String get adminRejectReschedule;

  /// No description provided for @adminCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Catat check-in'**
  String get adminCheckIn;

  /// No description provided for @adminStartService.
  ///
  /// In id, this message translates to:
  /// **'Mulai servis'**
  String get adminStartService;

  /// No description provided for @adminCompleteService.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan servis'**
  String get adminCompleteService;

  /// No description provided for @adminMarkNoShow.
  ///
  /// In id, this message translates to:
  /// **'Tandai no-show'**
  String get adminMarkNoShow;

  /// No description provided for @adminActionReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan atau catatan'**
  String get adminActionReason;

  /// No description provided for @advisorName.
  ///
  /// In id, this message translates to:
  /// **'Nama Service Advisor'**
  String get advisorName;

  /// No description provided for @advisorPhone.
  ///
  /// In id, this message translates to:
  /// **'Nomor Service Advisor'**
  String get advisorPhone;

  /// No description provided for @externalBookingNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor booking partner'**
  String get externalBookingNumber;

  /// No description provided for @internalNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan internal'**
  String get internalNote;

  /// No description provided for @proposalExpiryInvalid.
  ///
  /// In id, this message translates to:
  /// **'Batas respons harus setelah waktu sekarang dan sebelum slot usulan maupun jadwal terkonfirmasi yang masih aktif.'**
  String get proposalExpiryInvalid;

  /// No description provided for @proposedPicName.
  ///
  /// In id, this message translates to:
  /// **'PIC jadwal usulan'**
  String get proposedPicName;

  /// No description provided for @proposedArrivalInstructions.
  ///
  /// In id, this message translates to:
  /// **'Petunjuk kedatangan usulan'**
  String get proposedArrivalInstructions;

  /// No description provided for @timelineActor.
  ///
  /// In id, this message translates to:
  /// **'Oleh {name} ({type})'**
  String timelineActor(String name, String type);

  /// No description provided for @assignedAdvisor.
  ///
  /// In id, this message translates to:
  /// **'Advisor admin yang ditugaskan'**
  String get assignedAdvisor;

  /// No description provided for @instructions.
  ///
  /// In id, this message translates to:
  /// **'Instruksi untuk pelanggan'**
  String get instructions;

  /// No description provided for @sendAdminAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan tindakan'**
  String get sendAdminAction;

  /// No description provided for @adminActionSuccess.
  ///
  /// In id, this message translates to:
  /// **'Status booking berhasil diperbarui.'**
  String get adminActionSuccess;

  /// No description provided for @customer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get customer;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @fulfillment.
  ///
  /// In id, this message translates to:
  /// **'Cara servis'**
  String get fulfillment;

  /// No description provided for @updatedAt.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui'**
  String get updatedAt;

  /// No description provided for @copyReference.
  ///
  /// In id, this message translates to:
  /// **'Salin nomor referensi'**
  String get copyReference;

  /// No description provided for @referenceCopied.
  ///
  /// In id, this message translates to:
  /// **'Nomor referensi disalin.'**
  String get referenceCopied;

  /// No description provided for @useCurrentLocation.
  ///
  /// In id, this message translates to:
  /// **'Gunakan lokasi saat ini'**
  String get useCurrentLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In id, this message translates to:
  /// **'Layanan lokasi perangkat belum aktif.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi tidak diberikan.'**
  String get locationPermissionDenied;

  /// No description provided for @locationMapFallback.
  ///
  /// In id, this message translates to:
  /// **'Pilih titik secara manual langsung pada peta.'**
  String get locationMapFallback;

  /// No description provided for @photoUploadFailed.
  ///
  /// In id, this message translates to:
  /// **'Foto gagal diunggah. Periksa koneksi lalu coba lagi.'**
  String get photoUploadFailed;

  /// No description provided for @photoTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Ukuran foto maksimal 10 MB.'**
  String get photoTooLarge;

  /// No description provided for @photoInvalidType.
  ///
  /// In id, this message translates to:
  /// **'Gunakan foto JPG, JPEG, PNG, HEIC, atau HEIF.'**
  String get photoInvalidType;

  /// No description provided for @benefitVehicleTitle.
  ///
  /// In id, this message translates to:
  /// **'Benefit kendaraan'**
  String get benefitVehicleTitle;

  /// No description provided for @supportingPhotosTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto pendukung'**
  String get supportingPhotosTitle;

  /// No description provided for @preferencePrimary.
  ///
  /// In id, this message translates to:
  /// **'Preferensi utama'**
  String get preferencePrimary;

  /// No description provided for @preferenceAlternative.
  ///
  /// In id, this message translates to:
  /// **'Preferensi alternatif'**
  String get preferenceAlternative;

  /// No description provided for @proposedScheduleLabel.
  ///
  /// In id, this message translates to:
  /// **'Jadwal usulan petugas'**
  String get proposedScheduleLabel;

  /// No description provided for @confirmedScheduleLabel.
  ///
  /// In id, this message translates to:
  /// **'Jadwal terkonfirmasi'**
  String get confirmedScheduleLabel;

  /// No description provided for @reschedulePrimaryLabel.
  ///
  /// In id, this message translates to:
  /// **'Permintaan jadwal utama baru'**
  String get reschedulePrimaryLabel;

  /// No description provided for @rescheduleAlternativeLabel.
  ///
  /// In id, this message translates to:
  /// **'Permintaan jadwal alternatif baru'**
  String get rescheduleAlternativeLabel;

  /// No description provided for @proposalReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan usulan'**
  String get proposalReasonLabel;

  /// No description provided for @proposalContextLabel.
  ///
  /// In id, this message translates to:
  /// **'Konteks usulan'**
  String get proposalContextLabel;

  /// No description provided for @rescheduleReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan'**
  String get rescheduleReasonLabel;

  /// No description provided for @responseDeadline.
  ///
  /// In id, this message translates to:
  /// **'Batas respons'**
  String get responseDeadline;

  /// No description provided for @completedAtLabel.
  ///
  /// In id, this message translates to:
  /// **'Selesai pada'**
  String get completedAtLabel;

  /// No description provided for @slaOverdueLabel.
  ///
  /// In id, this message translates to:
  /// **'SLA terlambat'**
  String get slaOverdueLabel;

  /// No description provided for @dateIsoLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal (YYYY-MM-DD)'**
  String get dateIsoLabel;

  /// No description provided for @timeWindowLabel.
  ///
  /// In id, this message translates to:
  /// **'Rentang waktu'**
  String get timeWindowLabel;

  /// No description provided for @picNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama PIC'**
  String get picNameLabel;

  /// No description provided for @arrivalInstructionsLabel.
  ///
  /// In id, this message translates to:
  /// **'Instruksi kedatangan'**
  String get arrivalInstructionsLabel;

  /// No description provided for @alternativeReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan alternatif'**
  String get alternativeReasonLabel;

  /// No description provided for @responseDeadlineIsoLabel.
  ///
  /// In id, this message translates to:
  /// **'Batas respons (ISO 8601)'**
  String get responseDeadlineIsoLabel;

  /// No description provided for @reasonCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode alasan'**
  String get reasonCodeLabel;

  /// No description provided for @benefitTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis benefit'**
  String get benefitTypeLabel;

  /// No description provided for @benefitStatusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status benefit'**
  String get benefitStatusLabel;

  /// No description provided for @verificationSourceLabel.
  ///
  /// In id, this message translates to:
  /// **'Sumber verifikasi'**
  String get verificationSourceLabel;

  /// No description provided for @benefitNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan benefit'**
  String get benefitNotesLabel;

  /// No description provided for @confirmActionPrompt.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan aksi ini?'**
  String get confirmActionPrompt;

  /// No description provided for @pendingVerificationLabel.
  ///
  /// In id, this message translates to:
  /// **'Akan diverifikasi petugas'**
  String get pendingVerificationLabel;

  /// No description provided for @bookingAwaitingNotice.
  ///
  /// In id, this message translates to:
  /// **'Permintaan belum terkonfirmasi. Petugas akan memeriksa ketersediaan kedua preferensi jadwal.'**
  String get bookingAwaitingNotice;

  /// No description provided for @bookingAlternativeNotice.
  ///
  /// In id, this message translates to:
  /// **'Jadwal utama tidak tersedia. Tinjau jadwal alternatif yang diajukan sebelum batas respons.'**
  String get bookingAlternativeNotice;

  /// No description provided for @bookingRescheduleNotice.
  ///
  /// In id, this message translates to:
  /// **'Permintaan perubahan sedang ditinjau. Jadwal lama tetap berlaku sampai perubahan dikonfirmasi.'**
  String get bookingRescheduleNotice;

  /// No description provided for @bookingCheckedInNotice.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan sudah check-in dan menunggu proses servis.'**
  String get bookingCheckedInNotice;

  /// No description provided for @bookingInServiceNotice.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan sedang dikerjakan oleh tim servis.'**
  String get bookingInServiceNotice;

  /// No description provided for @bookingCompletedNotice.
  ///
  /// In id, this message translates to:
  /// **'Servis selesai. Rincian pekerjaan dan biaya final mengikuti dokumen dari bengkel.'**
  String get bookingCompletedNotice;

  /// No description provided for @bookingTerminalNotice.
  ///
  /// In id, this message translates to:
  /// **'Booking tidak dapat dilanjutkan. Anda dapat membuat permintaan baru.'**
  String get bookingTerminalNotice;

  /// No description provided for @profilePhoneRequired.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan nomor ponsel profil sebelum mengirim booking.'**
  String get profilePhoneRequired;

  /// No description provided for @thsOperationalVerification.
  ///
  /// In id, this message translates to:
  /// **'Area akan diverifikasi oleh petugas sebelum konfirmasi.'**
  String get thsOperationalVerification;

  /// No description provided for @thsTemporarilyUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Toyota Home Service belum tersedia karena area operasional masih menunggu verifikasi.'**
  String get thsTemporarilyUnavailable;

  /// No description provided for @serviceFulfillmentUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi servis belum tersedia'**
  String get serviceFulfillmentUnavailableTitle;

  /// No description provided for @serviceFulfillmentUnavailableDescription.
  ///
  /// In id, this message translates to:
  /// **'Belum ada lokasi bengkel atau Toyota Home Service yang beroperasi saat ini. Silakan coba lagi nanti.'**
  String get serviceFulfillmentUnavailableDescription;

  /// No description provided for @serviceSelectionChanged.
  ///
  /// In id, this message translates to:
  /// **'Pilihan servis tersimpan ini sudah tidak beroperasi. Pilih kembali lokasi dan layanan sebelum mengirim.'**
  String get serviceSelectionChanged;

  /// No description provided for @chooseServiceLocationAgain.
  ///
  /// In id, this message translates to:
  /// **'Pilih ulang layanan'**
  String get chooseServiceLocationAgain;

  /// No description provided for @otoxpertFlowTitle.
  ///
  /// In id, this message translates to:
  /// **'Booking OtoXpert'**
  String get otoxpertFlowTitle;

  /// No description provided for @otoxpertSelectVehicle.
  ///
  /// In id, this message translates to:
  /// **'Pilih kendaraan'**
  String get otoxpertSelectVehicle;

  /// No description provided for @otoxpertSelectVehicleDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih kendaraan tersimpan untuk menampilkan bengkel yang kompatibel.'**
  String get otoxpertSelectVehicleDescription;

  /// No description provided for @otoxpertChooseWorkshop.
  ///
  /// In id, this message translates to:
  /// **'Pilih bengkel OtoXpert'**
  String get otoxpertChooseWorkshop;

  /// No description provided for @otoxpertWorkshopEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bengkel yang kompatibel untuk kendaraan ini.'**
  String get otoxpertWorkshopEmpty;

  /// No description provided for @otoxpertChooseService.
  ///
  /// In id, this message translates to:
  /// **'Pilih layanan bengkel'**
  String get otoxpertChooseService;

  /// No description provided for @otoxpertSymptoms.
  ///
  /// In id, this message translates to:
  /// **'Gejala kendaraan'**
  String get otoxpertSymptoms;

  /// No description provided for @otoxpertLastServiceDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal servis terakhir (opsional)'**
  String get otoxpertLastServiceDate;

  /// No description provided for @otoxpertPickupDelivery.
  ///
  /// In id, this message translates to:
  /// **'Minta antar-jemput kendaraan'**
  String get otoxpertPickupDelivery;

  /// No description provided for @otoxpertPartnerConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui detail kendaraan dan keluhan dibagikan kepada bengkel OtoXpert untuk memproses permintaan ini.'**
  String get otoxpertPartnerConsent;

  /// No description provided for @otoxpertIndicativePrice.
  ///
  /// In id, this message translates to:
  /// **'Estimasi indikatif'**
  String get otoxpertIndicativePrice;

  /// No description provided for @otoxpertPriceDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Harga final ditentukan bengkel setelah pemeriksaan kendaraan.'**
  String get otoxpertPriceDisclaimer;

  /// No description provided for @otoxpertRequestSubmitted.
  ///
  /// In id, this message translates to:
  /// **'Permintaan OtoXpert berhasil dikirim dan menunggu konfirmasi bengkel.'**
  String get otoxpertRequestSubmitted;

  /// No description provided for @otoxpertAdminQueue.
  ///
  /// In id, this message translates to:
  /// **'Antrean Booking OtoXpert'**
  String get otoxpertAdminQueue;

  /// No description provided for @otoxpertAllStatuses.
  ///
  /// In id, this message translates to:
  /// **'Semua status'**
  String get otoxpertAllStatuses;

  /// No description provided for @otoxpertMaximumPrice.
  ///
  /// In id, this message translates to:
  /// **'Estimasi maksimum'**
  String get otoxpertMaximumPrice;

  /// No description provided for @otoxpertFollowUpOutcome.
  ///
  /// In id, this message translates to:
  /// **'Hasil tindak lanjut'**
  String get otoxpertFollowUpOutcome;

  /// No description provided for @activityOtoxpertBookingLabel.
  ///
  /// In id, this message translates to:
  /// **'Booking OtoXpert'**
  String get activityOtoxpertBookingLabel;

  /// No description provided for @activityOtoxpertLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas OtoXpert gagal dimuat. Aktivitas lain tetap ditampilkan.'**
  String get activityOtoxpertLoadFailed;

  /// No description provided for @loadingData.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan data…'**
  String get loadingData;

  /// No description provided for @creditFlowTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulasi kredit'**
  String get creditFlowTitle;

  /// No description provided for @creditFlowSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan cicilan dari program yang berlaku. Hasil ini berupa estimasi, bukan persetujuan kredit.'**
  String get creditFlowSubtitle;

  /// No description provided for @creditProgramLabel.
  ///
  /// In id, this message translates to:
  /// **'Program dan mobil target'**
  String get creditProgramLabel;

  /// No description provided for @creditProgramHelper.
  ///
  /// In id, this message translates to:
  /// **'Program menentukan harga OTR, tenor, bunga, dan biaya.'**
  String get creditProgramHelper;

  /// No description provided for @creditNoProgramsTitle.
  ///
  /// In id, this message translates to:
  /// **'Program kredit belum tersedia'**
  String get creditNoProgramsTitle;

  /// No description provided for @creditNoProgramsDescription.
  ///
  /// In id, this message translates to:
  /// **'Program aktif untuk kota dan kendaraan target belum dimasukkan. Coba lagi setelah tim memperbarui program.'**
  String get creditNoProgramsDescription;

  /// No description provided for @creditTargetVehicle.
  ///
  /// In id, this message translates to:
  /// **'Mobil target'**
  String get creditTargetVehicle;

  /// No description provided for @creditOtrCity.
  ///
  /// In id, this message translates to:
  /// **'Kota OTR'**
  String get creditOtrCity;

  /// No description provided for @creditOtrPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga OTR'**
  String get creditOtrPrice;

  /// No description provided for @creditDownPaymentSection.
  ///
  /// In id, this message translates to:
  /// **'Dana awal'**
  String get creditDownPaymentSection;

  /// No description provided for @creditCashDownPayment.
  ///
  /// In id, this message translates to:
  /// **'DP tunai'**
  String get creditCashDownPayment;

  /// No description provided for @creditTradeInManual.
  ///
  /// In id, this message translates to:
  /// **'Nilai trade-in manual'**
  String get creditTradeInManual;

  /// No description provided for @creditTradeInFromAppraisal.
  ///
  /// In id, this message translates to:
  /// **'Nilai trade-in akan diambil dari hasil appraisal ini.'**
  String get creditTradeInFromAppraisal;

  /// No description provided for @creditUseTradeInAsDp.
  ///
  /// In id, this message translates to:
  /// **'Gunakan equity trade-in sebagai DP'**
  String get creditUseTradeInAsDp;

  /// No description provided for @creditOldVehiclePayoff.
  ///
  /// In id, this message translates to:
  /// **'Sisa kewajiban kendaraan lama'**
  String get creditOldVehiclePayoff;

  /// No description provided for @creditTenor.
  ///
  /// In id, this message translates to:
  /// **'Tenor'**
  String get creditTenor;

  /// No description provided for @creditMonths.
  ///
  /// In id, this message translates to:
  /// **'bulan'**
  String get creditMonths;

  /// No description provided for @creditInvalidNumber.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka Rupiah yang valid.'**
  String get creditInvalidNumber;

  /// No description provided for @creditRatePerYear.
  ///
  /// In id, this message translates to:
  /// **'Bunga flat per tahun'**
  String get creditRatePerYear;

  /// No description provided for @creditCalculate.
  ///
  /// In id, this message translates to:
  /// **'Hitung simulasi'**
  String get creditCalculate;

  /// No description provided for @creditCalculating.
  ///
  /// In id, this message translates to:
  /// **'Menghitung…'**
  String get creditCalculating;

  /// No description provided for @creditResultTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan estimasi'**
  String get creditResultTitle;

  /// No description provided for @creditMonthlyInstallment.
  ///
  /// In id, this message translates to:
  /// **'Cicilan per bulan'**
  String get creditMonthlyInstallment;

  /// No description provided for @creditInitialPayment.
  ///
  /// In id, this message translates to:
  /// **'Dana awal dibayar'**
  String get creditInitialPayment;

  /// No description provided for @creditPrincipal.
  ///
  /// In id, this message translates to:
  /// **'Pokok pembiayaan'**
  String get creditPrincipal;

  /// No description provided for @creditTotalDownPayment.
  ///
  /// In id, this message translates to:
  /// **'Total komposisi DP'**
  String get creditTotalDownPayment;

  /// No description provided for @creditTradeInEquity.
  ///
  /// In id, this message translates to:
  /// **'Equity trade-in'**
  String get creditTradeInEquity;

  /// No description provided for @creditApprovedDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon program'**
  String get creditApprovedDiscount;

  /// No description provided for @creditTotalInterest.
  ///
  /// In id, this message translates to:
  /// **'Total bunga flat'**
  String get creditTotalInterest;

  /// No description provided for @creditAdministrationFee.
  ///
  /// In id, this message translates to:
  /// **'Administrasi'**
  String get creditAdministrationFee;

  /// No description provided for @creditProvisionFee.
  ///
  /// In id, this message translates to:
  /// **'Provisi'**
  String get creditProvisionFee;

  /// No description provided for @creditInsuranceFee.
  ///
  /// In id, this message translates to:
  /// **'Asuransi awal'**
  String get creditInsuranceFee;

  /// No description provided for @creditFeeNotIncluded.
  ///
  /// In id, this message translates to:
  /// **'Belum termasuk'**
  String get creditFeeNotIncluded;

  /// No description provided for @creditOtherFee.
  ///
  /// In id, this message translates to:
  /// **'Biaya lain'**
  String get creditOtherFee;

  /// No description provided for @creditTotalPayment.
  ///
  /// In id, this message translates to:
  /// **'Total pembayaran estimasi'**
  String get creditTotalPayment;

  /// No description provided for @creditValidUntil.
  ///
  /// In id, this message translates to:
  /// **'Program berlaku sampai'**
  String get creditValidUntil;

  /// No description provided for @creditAddComparison.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke perbandingan'**
  String get creditAddComparison;

  /// No description provided for @creditComparisonTitle.
  ///
  /// In id, this message translates to:
  /// **'Perbandingan skenario'**
  String get creditComparisonTitle;

  /// No description provided for @creditScenarioCount.
  ///
  /// In id, this message translates to:
  /// **'{count} dari 3 skenario'**
  String creditScenarioCount(int count);

  /// No description provided for @creditScenarioLimit.
  ///
  /// In id, this message translates to:
  /// **'Maksimal tiga skenario dapat dibandingkan.'**
  String get creditScenarioLimit;

  /// No description provided for @creditScenarioDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Skenario ini sudah ada dalam perbandingan.'**
  String get creditScenarioDuplicate;

  /// No description provided for @creditSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan simulasi'**
  String get creditSave;

  /// No description provided for @creditSaving.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan…'**
  String get creditSaving;

  /// No description provided for @creditSavedTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulasi tersimpan'**
  String get creditSavedTitle;

  /// No description provided for @creditSavedDescription.
  ///
  /// In id, this message translates to:
  /// **'Snapshot program dan hasil perhitungan tersimpan di Aktivitas Saya.'**
  String get creditSavedDescription;

  /// No description provided for @creditRequestSales.
  ///
  /// In id, this message translates to:
  /// **'Minta dihubungi sales'**
  String get creditRequestSales;

  /// No description provided for @creditFollowUpConsentTitle.
  ///
  /// In id, this message translates to:
  /// **'Teruskan ke tim sales?'**
  String get creditFollowUpConsentTitle;

  /// No description provided for @creditFollowUpConsentDescription.
  ///
  /// In id, this message translates to:
  /// **'Saya setuju data kontak dan snapshot simulasi ini digunakan tim sales untuk menindaklanjuti permintaan.'**
  String get creditFollowUpConsentDescription;

  /// No description provided for @creditContactChannel.
  ///
  /// In id, this message translates to:
  /// **'Channel kontak'**
  String get creditContactChannel;

  /// No description provided for @creditContactWhatsapp.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp'**
  String get creditContactWhatsapp;

  /// No description provided for @creditContactPhone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get creditContactPhone;

  /// No description provided for @creditContactEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get creditContactEmail;

  /// No description provided for @creditFollowUpSuccess.
  ///
  /// In id, this message translates to:
  /// **'Permintaan follow-up sudah diteruskan ke tim sales.'**
  String get creditFollowUpSuccess;

  /// No description provided for @creditEstimateDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Estimasi ini bukan persetujuan kredit. Nilai final mengikuti verifikasi sales dan partner pembiayaan.'**
  String get creditEstimateDisclaimer;

  /// No description provided for @creditExpiredAppraisalConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya memahami hasil appraisal mungkin sudah kedaluwarsa dan perlu diverifikasi ulang.'**
  String get creditExpiredAppraisalConsent;

  /// No description provided for @creditDraftAppraisalNotice.
  ///
  /// In id, this message translates to:
  /// **'Hasil appraisal terpilih akan digunakan sebagai indikasi trade-in.'**
  String get creditDraftAppraisalNotice;

  /// No description provided for @creditActivityLabel.
  ///
  /// In id, this message translates to:
  /// **'Simulasi kredit'**
  String get creditActivityLabel;

  /// No description provided for @creditActivityLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas simulasi kredit gagal dimuat. Aktivitas lain tetap ditampilkan.'**
  String get creditActivityLoadFailed;

  /// No description provided for @creditProgramExpired.
  ///
  /// In id, this message translates to:
  /// **'Program pada snapshot ini sudah berakhir. Rincian lama tetap dapat dilihat.'**
  String get creditProgramExpired;

  /// No description provided for @creditLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data simulasi kredit belum dapat dimuat.'**
  String get creditLoadFailed;

  /// No description provided for @creditStartNew.
  ///
  /// In id, this message translates to:
  /// **'Buat simulasi baru'**
  String get creditStartNew;

  /// No description provided for @creditViewSaved.
  ///
  /// In id, this message translates to:
  /// **'Lihat simulasi tersimpan'**
  String get creditViewSaved;

  /// No description provided for @creditShareSummary.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ringkasan'**
  String get creditShareSummary;

  /// No description provided for @creditSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber program'**
  String get creditSource;

  /// No description provided for @bodyPaintFlowTitle.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Body & Paint'**
  String get bodyPaintFlowTitle;

  /// No description provided for @bodyPaintFlowSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih panel yang rusak dan unggah foto untuk menerima rentang estimasi dari estimator.'**
  String get bodyPaintFlowSubtitle;

  /// No description provided for @bodyPaintVehicle.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan'**
  String get bodyPaintVehicle;

  /// No description provided for @bodyPaintLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi inspeksi atau perbaikan'**
  String get bodyPaintLocation;

  /// No description provided for @bodyPaintDamage.
  ///
  /// In id, this message translates to:
  /// **'Kerusakan'**
  String get bodyPaintDamage;

  /// No description provided for @bodyPaintAddDamage.
  ///
  /// In id, this message translates to:
  /// **'Tambah panel rusak'**
  String get bodyPaintAddDamage;

  /// No description provided for @bodyPaintPanel.
  ///
  /// In id, this message translates to:
  /// **'Panel kendaraan'**
  String get bodyPaintPanel;

  /// No description provided for @bodyPaintDamageType.
  ///
  /// In id, this message translates to:
  /// **'Jenis kerusakan'**
  String get bodyPaintDamageType;

  /// No description provided for @bodyPaintSeverity.
  ///
  /// In id, this message translates to:
  /// **'Tingkat kerusakan'**
  String get bodyPaintSeverity;

  /// No description provided for @bodyPaintDamageNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan kerusakan (opsional)'**
  String get bodyPaintDamageNote;

  /// No description provided for @bodyPaintClosePhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto dekat kerusakan'**
  String get bodyPaintClosePhoto;

  /// No description provided for @bodyPaintContextPhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto konteks kendaraan'**
  String get bodyPaintContextPhoto;

  /// No description provided for @bodyPaintChoosePhoto.
  ///
  /// In id, this message translates to:
  /// **'Pilih foto'**
  String get bodyPaintChoosePhoto;

  /// No description provided for @bodyPaintReplacePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get bodyPaintReplacePhoto;

  /// No description provided for @bodyPaintPhotoReady.
  ///
  /// In id, this message translates to:
  /// **'Foto siap dikirim'**
  String get bodyPaintPhotoReady;

  /// No description provided for @bodyPaintNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan untuk estimator (opsional)'**
  String get bodyPaintNotes;

  /// No description provided for @bodyPaintConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui foto dan data kendaraan digunakan untuk proses estimasi serta memahami hasilnya bersifat indikatif sampai inspeksi fisik.'**
  String get bodyPaintConsent;

  /// No description provided for @bodyPaintSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim permintaan estimasi'**
  String get bodyPaintSubmit;

  /// No description provided for @bodyPaintSubmitting.
  ///
  /// In id, this message translates to:
  /// **'Mengirim estimasiâ€¦'**
  String get bodyPaintSubmitting;

  /// No description provided for @bodyPaintRequirementNotice.
  ///
  /// In id, this message translates to:
  /// **'Setiap panel membutuhkan satu foto dekat dan seluruh permintaan membutuhkan satu foto konteks.'**
  String get bodyPaintRequirementNotice;

  /// No description provided for @bodyPaintSubmittedTitle.
  ///
  /// In id, this message translates to:
  /// **'Permintaan estimasi terkirim'**
  String get bodyPaintSubmittedTitle;

  /// No description provided for @bodyPaintSubmittedDescription.
  ///
  /// In id, this message translates to:
  /// **'Estimator akan memeriksa foto sebelum hasil ditampilkan. Pantau progresnya di Aktivitas Saya.'**
  String get bodyPaintSubmittedDescription;

  /// No description provided for @bodyPaintViewEstimate.
  ///
  /// In id, this message translates to:
  /// **'Lihat progres estimasi'**
  String get bodyPaintViewEstimate;

  /// No description provided for @bodyPaintActivityLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Body & Paint'**
  String get bodyPaintActivityLabel;

  /// No description provided for @bodyPaintActivityLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Body & Paint gagal dimuat. Aktivitas lain tetap ditampilkan.'**
  String get bodyPaintActivityLoadFailed;

  /// No description provided for @bodyPaintNoEstimates.
  ///
  /// In id, this message translates to:
  /// **'Belum ada estimasi Body & Paint.'**
  String get bodyPaintNoEstimates;

  /// No description provided for @bodyPaintEstimateResult.
  ///
  /// In id, this message translates to:
  /// **'Rentang estimasi'**
  String get bodyPaintEstimateResult;

  /// No description provided for @bodyPaintVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi estimasi'**
  String get bodyPaintVersion;

  /// No description provided for @bodyPaintDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi pengerjaan'**
  String get bodyPaintDuration;

  /// No description provided for @bodyPaintDays.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get bodyPaintDays;

  /// No description provided for @bodyPaintValidUntil.
  ///
  /// In id, this message translates to:
  /// **'Berlaku sampai'**
  String get bodyPaintValidUntil;

  /// No description provided for @bodyPaintPhysicalInspection.
  ///
  /// In id, this message translates to:
  /// **'Nilai final tetap memerlukan inspeksi fisik kendaraan.'**
  String get bodyPaintPhysicalInspection;

  /// No description provided for @bodyPaintAssumptions.
  ///
  /// In id, this message translates to:
  /// **'Asumsi estimator'**
  String get bodyPaintAssumptions;

  /// No description provided for @bodyPaintTimeline.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan estimasi'**
  String get bodyPaintTimeline;

  /// No description provided for @bodyPaintAccept.
  ///
  /// In id, this message translates to:
  /// **'Terima estimasi'**
  String get bodyPaintAccept;

  /// No description provided for @bodyPaintDecline.
  ///
  /// In id, this message translates to:
  /// **'Tidak lanjut'**
  String get bodyPaintDecline;

  /// No description provided for @bodyPaintDeclineReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan tidak melanjutkan (opsional)'**
  String get bodyPaintDeclineReason;

  /// No description provided for @bodyPaintRequestBooking.
  ///
  /// In id, this message translates to:
  /// **'Lanjut booking Body & Paint'**
  String get bodyPaintRequestBooking;

  /// No description provided for @bodyPaintBookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih jadwal booking'**
  String get bodyPaintBookingTitle;

  /// No description provided for @bodyPaintPrimarySlot.
  ///
  /// In id, this message translates to:
  /// **'Jadwal utama'**
  String get bodyPaintPrimarySlot;

  /// No description provided for @bodyPaintAlternativeSlot.
  ///
  /// In id, this message translates to:
  /// **'Jadwal alternatif'**
  String get bodyPaintAlternativeSlot;

  /// No description provided for @bodyPaintComplaint.
  ///
  /// In id, this message translates to:
  /// **'Catatan untuk bengkel'**
  String get bodyPaintComplaint;

  /// No description provided for @bodyPaintMileage.
  ///
  /// In id, this message translates to:
  /// **'Kilometer saat ini'**
  String get bodyPaintMileage;

  /// No description provided for @bodyPaintBookingConsent.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui data estimasi diteruskan untuk permintaan booking.'**
  String get bodyPaintBookingConsent;

  /// No description provided for @bodyPaintRequestPhotos.
  ///
  /// In id, this message translates to:
  /// **'Estimator meminta perbaikan foto'**
  String get bodyPaintRequestPhotos;

  /// No description provided for @bodyPaintResubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang foto'**
  String get bodyPaintResubmit;

  /// No description provided for @bodyPaintAdminQueue.
  ///
  /// In id, this message translates to:
  /// **'Antrean Estimasi Body & Paint'**
  String get bodyPaintAdminQueue;

  /// No description provided for @bodyPaintAdminEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada estimasi di antrean.'**
  String get bodyPaintAdminEmpty;

  /// No description provided for @bodyPaintCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get bodyPaintCustomer;

  /// No description provided for @bodyPaintEstimator.
  ///
  /// In id, this message translates to:
  /// **'Estimator'**
  String get bodyPaintEstimator;

  /// No description provided for @bodyPaintEngineEstimate.
  ///
  /// In id, this message translates to:
  /// **'Saran mesin'**
  String get bodyPaintEngineEstimate;

  /// No description provided for @bodyPaintStartReview.
  ///
  /// In id, this message translates to:
  /// **'Mulai review'**
  String get bodyPaintStartReview;

  /// No description provided for @bodyPaintAssignSelf.
  ///
  /// In id, this message translates to:
  /// **'Ambil estimasi ini'**
  String get bodyPaintAssignSelf;

  /// No description provided for @bodyPaintPublish.
  ///
  /// In id, this message translates to:
  /// **'Terbitkan estimasi'**
  String get bodyPaintPublish;

  /// No description provided for @bodyPaintPublishDescription.
  ///
  /// In id, this message translates to:
  /// **'Periksa biaya per panel. Perubahan dari saran mesin wajib disertai alasan.'**
  String get bodyPaintPublishDescription;

  /// No description provided for @bodyPaintWorkType.
  ///
  /// In id, this message translates to:
  /// **'Tindakan'**
  String get bodyPaintWorkType;

  /// No description provided for @bodyPaintLowCost.
  ///
  /// In id, this message translates to:
  /// **'Biaya minimum'**
  String get bodyPaintLowCost;

  /// No description provided for @bodyPaintHighCost.
  ///
  /// In id, this message translates to:
  /// **'Biaya maksimum'**
  String get bodyPaintHighCost;

  /// No description provided for @bodyPaintMinHours.
  ///
  /// In id, this message translates to:
  /// **'Durasi minimum (jam)'**
  String get bodyPaintMinHours;

  /// No description provided for @bodyPaintMaxHours.
  ///
  /// In id, this message translates to:
  /// **'Durasi maksimum (jam)'**
  String get bodyPaintMaxHours;

  /// No description provided for @bodyPaintRecommendation.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi (opsional)'**
  String get bodyPaintRecommendation;

  /// No description provided for @bodyPaintAssumption.
  ///
  /// In id, this message translates to:
  /// **'Asumsi, pisahkan tiap baris'**
  String get bodyPaintAssumption;

  /// No description provided for @bodyPaintDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Disclaimer'**
  String get bodyPaintDisclaimer;

  /// No description provided for @bodyPaintValidDays.
  ///
  /// In id, this message translates to:
  /// **'Masa berlaku (hari)'**
  String get bodyPaintValidDays;

  /// No description provided for @bodyPaintOverrideReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan koreksi atau override'**
  String get bodyPaintOverrideReason;

  /// No description provided for @bodyPaintAdminActionSuccess.
  ///
  /// In id, this message translates to:
  /// **'Estimasi berhasil diperbarui.'**
  String get bodyPaintAdminActionSuccess;

  /// No description provided for @bodyPaintCompleteFields.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi seluruh data, foto, dan persetujuan terlebih dahulu.'**
  String get bodyPaintCompleteFields;

  /// No description provided for @bodyPaintLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data Estimasi Body & Paint belum dapat dimuat.'**
  String get bodyPaintLoadFailed;

  /// No description provided for @bodyPaintRequestPhotoReason.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan foto yang perlu diperbaiki'**
  String get bodyPaintRequestPhotoReason;

  /// No description provided for @bodyPaintLabor.
  ///
  /// In id, this message translates to:
  /// **'Jasa'**
  String get bodyPaintLabor;

  /// No description provided for @bodyPaintMaterial.
  ///
  /// In id, this message translates to:
  /// **'Material'**
  String get bodyPaintMaterial;

  /// No description provided for @bodyPaintParts.
  ///
  /// In id, this message translates to:
  /// **'Suku cadang'**
  String get bodyPaintParts;

  /// No description provided for @bodyPaintOther.
  ///
  /// In id, this message translates to:
  /// **'Biaya lain'**
  String get bodyPaintOther;

  /// No description provided for @bodyPaintRepair.
  ///
  /// In id, this message translates to:
  /// **'Perbaikan panel'**
  String get bodyPaintRepair;

  /// No description provided for @bodyPaintPaint.
  ///
  /// In id, this message translates to:
  /// **'Pengecatan'**
  String get bodyPaintPaint;

  /// No description provided for @bodyPaintReplace.
  ///
  /// In id, this message translates to:
  /// **'Penggantian'**
  String get bodyPaintReplace;

  /// No description provided for @bodyPaintPolish.
  ///
  /// In id, this message translates to:
  /// **'Poles'**
  String get bodyPaintPolish;

  /// No description provided for @bodyPaintPublishAssumptionDefault.
  ///
  /// In id, this message translates to:
  /// **'Estimasi dibuat dari kondisi yang terlihat pada foto.'**
  String get bodyPaintPublishAssumptionDefault;

  /// No description provided for @bodyPaintPublishDisclaimerDefault.
  ///
  /// In id, this message translates to:
  /// **'Estimasi bersifat indikatif dan nilai final ditentukan setelah inspeksi fisik kendaraan.'**
  String get bodyPaintPublishDisclaimerDefault;

  /// No description provided for @bodyPaintSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari referensi, pelanggan, atau kendaraan'**
  String get bodyPaintSearch;

  /// No description provided for @bodyPaintAllStatuses.
  ///
  /// In id, this message translates to:
  /// **'Semua status'**
  String get bodyPaintAllStatuses;

  /// No description provided for @bodyPaintLight.
  ///
  /// In id, this message translates to:
  /// **'Ringan'**
  String get bodyPaintLight;

  /// No description provided for @bodyPaintMedium.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get bodyPaintMedium;

  /// No description provided for @bodyPaintHeavy.
  ///
  /// In id, this message translates to:
  /// **'Berat'**
  String get bodyPaintHeavy;

  /// No description provided for @bodyPaintInspect.
  ///
  /// In id, this message translates to:
  /// **'Inspeksi'**
  String get bodyPaintInspect;
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
