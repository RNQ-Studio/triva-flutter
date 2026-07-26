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
  /// **'Menyiapkan pilihan wilayahâ€¦'**
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

  /// No description provided for @vehicleModel.
  ///
  /// In id, this message translates to:
  /// **'Model'**
  String get vehicleModel;

  /// No description provided for @vehicleVariant.
  ///
  /// In id, this message translates to:
  /// **'Varian'**
  String get vehicleVariant;

  /// No description provided for @vehicleYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get vehicleYear;

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
  /// **'Belum ada aktivitas appraisal.'**
  String get activityEmpty;

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
