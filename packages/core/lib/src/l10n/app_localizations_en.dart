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
  String get privacyAndAccount => 'Privacy and account';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'Learn how TRIVA handles and protects your data';

  @override
  String get accountDeletion => 'Delete account';

  @override
  String get accountDeletionSubtitle =>
      'Request deletion of your TRIVA account and data';

  @override
  String get openLinkError => 'The page could not be opened. Please try again.';

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
      'Submit vehicle details and photos for an automatically processed indicative value.';

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
  String get processReviewTitle => 'Automatic analysis';

  @override
  String get processReviewDescription =>
      'TRIVA searches OLX comparables and uses OpenAI as fallback before the engine calculates the result.';

  @override
  String get processResultTitle => 'Receive and continue';

  @override
  String get processResultDescription =>
      'Use the appraisal result to choose financing, repairs, or a service booking.';

  @override
  String get homeFooter =>
      'TRIVA · Trade-In Vehicle Appraisal · Auto2000 Kertajaya';

  @override
  String get loginHeroTitle => 'Know your vehicle\'s value with confidence';

  @override
  String get loginHeroDescription =>
      'Transparent, automatically processed appraisal tracked from one app.';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get profileSetupDescription =>
      'This information helps us prepare your appraisal and contact you if anything needs confirmation.';

  @override
  String get phoneNumber => 'Mobile number';

  @override
  String get city => 'City of residence';

  @override
  String get province => 'Province';

  @override
  String get cityOrRegency => 'City/regency';

  @override
  String get chooseProvince => 'Choose a province';

  @override
  String get chooseCity => 'Choose a city/regency';

  @override
  String get chooseProvinceFirst => 'Choose a province first';

  @override
  String get regionLoading => 'Preparing region options…';

  @override
  String get regionLoadError =>
      'We could not load region options. Check your connection and try again.';

  @override
  String get regionEmpty =>
      'Province and city master data is not available yet.';

  @override
  String get serviceConsentLabel =>
      'I consent to data processing for the TRIVA appraisal service.';

  @override
  String get marketingConsentLabel =>
      'I would like to receive relevant service and promotion updates.';

  @override
  String get consentRequired => 'Service consent is required.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get phoneInvalid => 'Enter a 9–15 digit mobile number.';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get profileSetupError =>
      'We could not save your profile. Check the details and try again.';

  @override
  String get next => 'Continue';

  @override
  String get retry => 'Try again';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get activity => 'Activity';

  @override
  String get notifications => 'Notifications';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeGreetingSubtitle => 'What does your vehicle need today?';

  @override
  String get homeMarketSourceBadge => 'OLX price comparables';

  @override
  String get homePartnersTitle => 'Official partners';

  @override
  String get homePartnersSubtitle =>
      'Follow-up services are delivered by the Astra partner network.';

  @override
  String get myVehicle => 'My Vehicle';

  @override
  String get emptyVehicleTitle => 'No vehicle yet';

  @override
  String get emptyVehicleDescription =>
      'Start your first appraisal and your vehicle will be saved automatically.';

  @override
  String get startAppraisal => 'Start appraisal';

  @override
  String get comingSoon => 'This service is coming soon.';

  @override
  String appraisalStep(int current) {
    return 'Step $current of 4';
  }

  @override
  String get vehicleIdentityTitle => 'Vehicle identity';

  @override
  String get vehicleIdentityDescription =>
      'Enter the identity shown on the registration for better comparisons.';

  @override
  String get vehicleMake => 'Make';

  @override
  String get chooseVehicleMake => 'Choose a vehicle make';

  @override
  String get searchVehicleMake => 'Search vehicle makes';

  @override
  String get vehicleMakeLoadError =>
      'Vehicle make master data could not be loaded. Check your connection and try again.';

  @override
  String get vehicleMakeEmpty =>
      'Vehicle make master data is not available yet.';

  @override
  String get vehicleModel => 'Model';

  @override
  String get chooseVehicleModel => 'Choose a vehicle model';

  @override
  String chooseVehicleModelFor(String make) {
    return 'Choose a $make model';
  }

  @override
  String get searchVehicleModel => 'Search vehicle models';

  @override
  String get chooseVehicleMakeFirst => 'Choose a make first';

  @override
  String get vehicleModelLoading => 'Loading vehicle models...';

  @override
  String get vehicleModelLoadError =>
      'Vehicle model master data could not be loaded.';

  @override
  String get vehicleModelEmpty => 'No model is available for this make yet.';

  @override
  String get vehicleVariant => 'Variant';

  @override
  String get chooseVehicleVariant => 'Choose a vehicle variant';

  @override
  String chooseVehicleVariantFor(String model) {
    return 'Choose a $model variant';
  }

  @override
  String get searchVehicleVariant => 'Search vehicle variants';

  @override
  String get chooseVehicleModelFirst => 'Choose a model first';

  @override
  String get vehicleVariantLoading => 'Loading vehicle variants...';

  @override
  String get vehicleVariantLoadError =>
      'Vehicle variant master data could not be loaded.';

  @override
  String get vehicleVariantEmpty =>
      'No master variant is available for this model.';

  @override
  String vehicleVariantAvailable(int count) {
    return '$count variants available. Tap to choose.';
  }

  @override
  String get vehicleVariantNotFound => 'Variant not found? Enter it manually';

  @override
  String get vehicleVariantManualHelper =>
      'Use the variant name shown on the registration or vehicle document.';

  @override
  String get chooseFromVariantMaster => 'Choose from variant master';

  @override
  String get vehicleYear => 'Year';

  @override
  String get chooseVehicleYear => 'Choose vehicle year';

  @override
  String get vehicleDetailsTitle => 'Vehicle details';

  @override
  String get vehicleDetailsDescription =>
      'Complete the current specification and usage details.';

  @override
  String get editVehicleIdentity => 'Edit identity';

  @override
  String get transmission => 'Transmission';

  @override
  String get automatic => 'Automatic';

  @override
  String get manual => 'Manual';

  @override
  String get fuelType => 'Fuel';

  @override
  String get gasoline => 'Gasoline';

  @override
  String get diesel => 'Diesel';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get electric => 'Electric';

  @override
  String get mileage => 'Mileage';

  @override
  String get vehicleColor => 'Color';

  @override
  String get licensePlate => 'License plate';

  @override
  String get vehicleCity => 'Vehicle city';

  @override
  String get conditionTitle => 'Vehicle condition';

  @override
  String get conditionDescription =>
      'Answer truthfully so the engine can adjust the indicative value.';

  @override
  String get conditionGrade => 'Vehicle condition grade';

  @override
  String get conditionGradeDescription =>
      'Pick the grade closest to your car. OLX and dealers use these same grades when valuing a unit.';

  @override
  String get conditionGradeA => 'Grade A - Excellent, ready to drive';

  @override
  String get conditionGradeB => 'Grade B - Good, light servicing only';

  @override
  String get conditionGradeC => 'Grade C - Fair, some repairs needed';

  @override
  String get conditionGradeD => 'Grade D - Needs major repairs';

  @override
  String get engineCondition => 'Engine condition';

  @override
  String get engineConditionNormal => 'Normal';

  @override
  String get engineConditionWet => 'Wet or seeping';

  @override
  String get tyreCondition => 'Tyre condition';

  @override
  String get tyreConditionNormal => 'Normal';

  @override
  String get tyreConditionDamaged => 'Damaged';

  @override
  String get taxStatus => 'Tax status';

  @override
  String get taxActive => 'Active';

  @override
  String get taxOverdue => 'Overdue';

  @override
  String get unknown => 'Not sure';

  @override
  String get floodHistory => 'Has it been flooded?';

  @override
  String get majorAccidentHistory => 'Any major accident?';

  @override
  String get answerYes => 'Yes';

  @override
  String get answerNo => 'No';

  @override
  String get serviceHistory => 'Service history';

  @override
  String get serviceComplete => 'Complete';

  @override
  String get servicePartial => 'Partial';

  @override
  String get serviceNone => 'None';

  @override
  String get ownership => 'Ownership';

  @override
  String get ownershipFirst => 'First owner';

  @override
  String get ownershipSecond => 'Second owner';

  @override
  String get ownershipMore => 'More than two';

  @override
  String get photosTitle => 'Vehicle photos';

  @override
  String get photosDescription =>
      'Take five bright, complete, unfiltered photos.';

  @override
  String get photoFront => 'Front view';

  @override
  String get photoRear => 'Rear view';

  @override
  String get photoLeft => 'Left side';

  @override
  String get photoRight => 'Right side';

  @override
  String get photoDashboard => 'Dashboard & odometer';

  @override
  String get photoAdd => 'Take photo';

  @override
  String get photoReplace => 'Replace photo';

  @override
  String get photosComplete => 'All photos complete';

  @override
  String get reviewTitle => 'Review submission';

  @override
  String get reviewDescription =>
      'Make sure the following details are correct before submitting.';

  @override
  String get reviewVehicle => 'Vehicle';

  @override
  String get reviewCondition => 'Condition';

  @override
  String get reviewPhotos => 'Photos';

  @override
  String get reviewConsent =>
      'I understand the appraisal is indicative and may require a physical inspection.';

  @override
  String get submitAppraisal => 'Submit appraisal';

  @override
  String get submittingAppraisal => 'Submitting appraisal';

  @override
  String get draftSaved => 'Draft saved automatically';

  @override
  String get submittedTitle => 'Appraisal submitted';

  @override
  String get submittedDescription =>
      'Processing continues in the background. We search OLX comparables and ask OpenAI for a price decision when needed. You will be notified when it finishes.';

  @override
  String get referenceNumber => 'Reference number';

  @override
  String get viewProgress => 'View progress';

  @override
  String get backToHome => 'Back to home';

  @override
  String get activityTitle => 'My Activity';

  @override
  String get activityEmpty => 'No activity yet.';

  @override
  String get demoActivityNotice =>
      'The following entries are sample activity data and will be replaced automatically when your transactions are available.';

  @override
  String get demoActivityRecentTitle => 'Recent activity';

  @override
  String get demoActivityAppraisalTitle => 'Toyota Avanza appraisal';

  @override
  String get demoActivityAppraisalSubtitle =>
      'Today, 09:30 · TIA-20260727-0001';

  @override
  String get demoActivityReviewStatus => 'Under review';

  @override
  String get demoActivityServiceTitle => 'Periodic service booking';

  @override
  String get demoActivityServiceSubtitle =>
      'Tomorrow, 10:00 · Auto2000 Kertajaya';

  @override
  String get demoActivityConfirmedStatus => 'Schedule confirmed';

  @override
  String get demoActivityCreditTitle => 'Innova Zenix credit simulation';

  @override
  String get demoActivityCreditSubtitle => '26 Jul 2026 · 60-month term';

  @override
  String get demoActivitySavedStatus => 'Simulation saved';

  @override
  String get demoActivityBodyPaintTitle => 'Body & Paint estimate';

  @override
  String get demoActivityBodyPaintSubtitle => '25 Jul 2026 · Rear bumper';

  @override
  String get demoActivityDraftStatus => 'Draft';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyDescription =>
      'Appraisal updates, service schedules, and offers will appear here.';

  @override
  String get appraisalProgressTitle => 'Appraisal progress';

  @override
  String get refresh => 'Refresh';

  @override
  String get needsActionTitle => 'A photo needs correction';

  @override
  String get needsActionDescription =>
      'Replace the marked photo so automatic processing can continue.';

  @override
  String get sendReplacement => 'Send replacement photo';

  @override
  String get underReviewTitle => 'Processing market comparables';

  @override
  String get underReviewDescription =>
      'TRIVA searches OLX and asks OpenAI for a price decision from the submitted specifications when comparables are insufficient.';

  @override
  String get processingFailedTitle => 'Processing was not completed';

  @override
  String get processingFailedDescription =>
      'OLX and the OpenAI fallback did not provide enough comparables. Your data remains saved.';

  @override
  String get resultTitle => 'Appraisal result';

  @override
  String get tradeInEstimate => 'Trade-in estimate';

  @override
  String validUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get expectedPriceTitle => 'What price were you hoping for?';

  @override
  String get expectedPriceDescription =>
      'Tell us the figure you had in mind for this car. Our team will follow up with you.';

  @override
  String get expectedPriceLabel => 'Expected price';

  @override
  String get expectedPriceInvalid =>
      'Enter an expected price of at least Rp 1,000,000.';

  @override
  String get expectedPriceSubmit => 'Send expected price';

  @override
  String get expectedPriceRecorded => 'We have recorded your expected price.';

  @override
  String get upgradeOfferTitle => 'Trade in for a new car';

  @override
  String upgradeOfferSubtitle(String amount) {
    return 'Your appraisal of $amount already covers the down payment on these units.';
  }

  @override
  String upgradeOfferInstallment(int months) {
    return '$months-month instalment';
  }

  @override
  String get upgradeOfferDownPayment => 'Down payment from appraisal';

  @override
  String get upgradeOfferSimulate => 'Simulate';

  @override
  String get upgradeOfferDismiss => 'Maybe later';

  @override
  String get upgradeOfferEstimateNotice =>
      'Instalment figures are estimates, not credit approval.';

  @override
  String get whatsappHandoffOpening => 'Opening the branch WhatsApp...';

  @override
  String get whatsappHandoffFailed =>
      'WhatsApp could not be opened. Your data is saved and our team will contact you.';

  @override
  String get whatsappHandoffOtoxpertTitle =>
      'Hello OtoXpert Auto2000, I would like to book a service through the TRIVA app.';

  @override
  String get whatsappHandoffToyotaTitle =>
      'Hello Auto2000 Kertajaya, I would like to book a service through the TRIVA app.';

  @override
  String get whatsappHandoffBodyPaintTitle =>
      'Hello Auto2000 Kertajaya Body & Paint, I have submitted an estimate request through the TRIVA app.';

  @override
  String get whatsappHandoffReference => 'Reference number';

  @override
  String get whatsappHandoffCustomer => 'Customer name';

  @override
  String get whatsappHandoffVehicle => 'Vehicle';

  @override
  String get whatsappHandoffPlate => 'Licence plate';

  @override
  String get whatsappHandoffSchedule => 'Requested schedule';

  @override
  String get whatsappHandoffLocation => 'Location';

  @override
  String get whatsappHandoffComplaint => 'Complaint';

  @override
  String get whatsappHandoffInsurance => 'Insurance';

  @override
  String get whatsappContactBranch => 'Contact via WhatsApp';

  @override
  String get benefitCheckTitle => 'Check chassis number';

  @override
  String get benefitCheckSubtitle =>
      'Find out whether your car is part of an SSC campaign and how much T-Care is left.';

  @override
  String get benefitCheckVin => 'Chassis number';

  @override
  String get benefitCheckVinHint =>
      'Shown on your STNK or BPKB, 17 characters.';

  @override
  String get benefitCheckYear => 'Vehicle year';

  @override
  String get benefitCheckSubmit => 'Check now';

  @override
  String get benefitCheckVinRequired => 'Enter your vehicle chassis number.';

  @override
  String get benefitCheckYearInvalid => 'Enter a plausible vehicle year.';

  @override
  String get benefitCheckSscTitle => 'SSC status';

  @override
  String get benefitCheckTcareTitle => 'T-Care coverage';

  @override
  String benefitCheckTcareRemaining(int months) {
    return 'About $months months left';
  }

  @override
  String benefitCheckTcareUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get benefitCheckRecheck => 'Check another chassis number';

  @override
  String get promoSectionTitle => 'This month\'s promos';

  @override
  String get promoPopupCta => 'See the promo';

  @override
  String get promoPopupDismiss => 'Maybe later';

  @override
  String get promoCategorySales => 'Sales';

  @override
  String get promoCategoryServiceGr => 'Scheduled service';

  @override
  String get promoCategoryServiceBp => 'Body & Paint';

  @override
  String get promoCategoryOtoxpert => 'OtoXpert';

  @override
  String get maintenanceEstimateTitle => 'Service cost estimate';

  @override
  String get maintenanceEstimateSubtitle =>
      'Estimate your next scheduled service before booking.';

  @override
  String get maintenanceEstimateMileage => 'Current mileage';

  @override
  String get maintenanceEstimateModel => 'Vehicle model';

  @override
  String get maintenanceEstimateSubmit => 'Calculate estimate';

  @override
  String get maintenanceEstimateParts => 'Parts cost';

  @override
  String get maintenanceEstimateLabor => 'Labour cost';

  @override
  String get maintenanceEstimateTotal => 'Estimated total';

  @override
  String get maintenanceEstimateIncludes => 'What is covered';

  @override
  String maintenanceEstimateDuration(int min, int max) {
    return 'Around $min-$max minutes of work';
  }

  @override
  String get maintenanceEstimateEmpty =>
      'Service package data is not available yet. Contact Auto2000 Kertajaya for an estimate.';

  @override
  String get maintenanceEstimateOtherPackages => 'Other packages';

  @override
  String get maintenanceEstimateBook => 'Book a Toyota service';

  @override
  String get acceptPrice => 'Accept price';

  @override
  String get declinePrice => 'Not a fit';

  @override
  String get scheduleInspection => 'Schedule inspection';

  @override
  String get inspectionDate => 'Inspection time';

  @override
  String get inspectionNotes => 'Notes (optional)';

  @override
  String get decisionAcceptedTitle => 'Appraisal price accepted';

  @override
  String get decisionAcceptedDescription =>
      'The trade-in value is ready for your next vehicle purchase step.';

  @override
  String get decisionRejectedTitle => 'Decision saved';

  @override
  String get decisionRejectedDescription =>
      'Your vehicle data stays available for a repair estimate.';

  @override
  String get statusDraft => 'Draft';

  @override
  String get loadFailed => 'We could not load the data.';

  @override
  String get photoGallery => 'Choose from gallery';

  @override
  String get photoPermissionError =>
      'Camera or gallery could not be opened. Check the app permissions.';

  @override
  String get photoReadError =>
      'The photo could not be read. Please take or choose it again.';

  @override
  String get uploadPreparingVehicle => 'Preparing vehicle details';

  @override
  String get uploadCreatingRequest => 'Creating appraisal request';

  @override
  String get uploadSavingCondition => 'Saving condition checklist';

  @override
  String uploadingPhoto(int current) {
    return 'Uploading photo $current of 5';
  }

  @override
  String get uploadSending => 'Submitting appraisal';

  @override
  String get uploadSuccess => 'Appraisal submitted';

  @override
  String get incompleteDraftError =>
      'Complete all required information before submitting.';

  @override
  String get photosExpiredError =>
      'Some photos are no longer stored on this device. Take them again before submitting.';

  @override
  String get submissionNetworkError =>
      'Connection lost. Your draft is saved; try submitting again.';

  @override
  String get submissionAuthError =>
      'Your session ended. Sign in again to continue.';

  @override
  String get submissionGeneralError =>
      'The appraisal could not be submitted. Your draft remains saved.';

  @override
  String get inspectionScheduledDescription =>
      'The schedule is saved. The TRIVA team will contact you to confirm the inspection.';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get adminPanelTitle => 'Operations center';

  @override
  String get adminPanelSubtitle =>
      'Manage services according to the access granted to your account.';

  @override
  String get adminVisitDashboardTitle => 'Visit statistics';

  @override
  String get adminVisitDashboardDescription =>
      'Android, web app, and landing-page sessions grouped in Jakarta time.';

  @override
  String get adminVisitRefresh => 'Refresh visit statistics';

  @override
  String get adminVisitDaily => 'Today';

  @override
  String get adminVisitWeekly => 'This week';

  @override
  String get adminVisitMonthly => 'This month';

  @override
  String get adminVisitOverall => 'All time';

  @override
  String get adminVisitAndroid => 'Android';

  @override
  String get adminVisitWeb => 'Web app';

  @override
  String get adminVisitLandingPage => 'Landing';

  @override
  String get adminVisitTrackingStartsNow =>
      'Tracking starts when this feature is enabled; historical data is not reconstructed.';

  @override
  String adminVisitRecordedSince(String date) {
    return 'Recorded since $date.';
  }

  @override
  String adminVisitUpdatedAt(String date) {
    return 'Updated $date.';
  }

  @override
  String get adminVisitEmptyTitle => 'No visits recorded yet';

  @override
  String get adminVisitEmptyDescription =>
      'Figures will appear after Android, the web app, or the landing page receives a new session.';

  @override
  String get adminVisitOfflineTitle => 'Statistics are offline';

  @override
  String get adminVisitOfflineDescription =>
      'Check the connection and try loading statistics again. Operational menus remain available.';

  @override
  String get adminVisitErrorTitle => 'Statistics could not be loaded';

  @override
  String get adminVisitErrorDescription =>
      'Something interrupted the statistics request. Operational menus remain available.';

  @override
  String get adminAccessDenied => 'Admin access is unavailable';

  @override
  String get adminAccessDeniedDescription =>
      'This account does not have permission to open operational modules.';

  @override
  String get adminUserAccessTitle => 'Manage admin access';

  @override
  String get adminUserAccessDescription =>
      'Find an existing user and grant access to the Admin Panel.';

  @override
  String get adminUserSearchHint => 'Search by user name or email';

  @override
  String get adminUserEmptyTitle => 'No users found';

  @override
  String get adminUserEmptyDescription =>
      'Check the search term or try another name or email.';

  @override
  String get adminUserAlreadyAdmin => 'Already has admin access';

  @override
  String get adminUserInactive => 'Inactive';

  @override
  String get adminUserGrantAction => 'Make admin';

  @override
  String adminUserGrantConfirmTitle(String name) {
    return 'Make $name an admin?';
  }

  @override
  String get adminUserGrantConfirmDescription =>
      'The user will receive permission to access and manage operational modules.';

  @override
  String adminUserGrantSuccess(String name) {
    return 'Admin access was granted to $name.';
  }

  @override
  String get adminUserGrantFailed =>
      'Admin access could not be granted. Try again.';

  @override
  String get loadMore => 'Load more';

  @override
  String get clear => 'Clear';

  @override
  String get moduleActive => 'Active';

  @override
  String get moduleUnavailable => 'Not enabled';

  @override
  String get adminBookingQueue => 'Toyota Booking';

  @override
  String get adminBookingQueueDescription =>
      'Confirmation queue, schedules, and service progress.';

  @override
  String get adminNoBookings => 'The booking queue is empty';

  @override
  String get adminNoBookingsDescription =>
      'Toyota Booking requests will appear here.';

  @override
  String get adminNoValidSlots =>
      'No valid future slot is available for this action.';

  @override
  String get sortUpdatedDesc => 'Recently updated';

  @override
  String get sortDueAsc => 'Nearest SLA due';

  @override
  String get sortSlotAsc => 'Nearest requested slot';

  @override
  String get searchBookings => 'Search reference, customer, or vehicle';

  @override
  String get bookingToyotaTitle => 'Toyota Booking';

  @override
  String get bookingStepVehicle => 'Vehicle';

  @override
  String get bookingStepService => 'Service';

  @override
  String get bookingStepSchedule => 'Schedule';

  @override
  String get bookingStepReview => 'Review';

  @override
  String get bookingSelectVehicleTitle => 'Choose a Toyota vehicle';

  @override
  String get bookingSelectVehicleDescription =>
      'Use a saved vehicle so you do not need to re-enter service details.';

  @override
  String get bookingNoVehicles => 'No saved vehicles yet';

  @override
  String get bookingNoVehiclesDescription =>
      'Add a vehicle first, then return to Toyota Booking.';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get bookingAddVehicleTitle => 'Add a vehicle for booking';

  @override
  String get bookingAddVehicleDescription =>
      'Complete the vehicle details once so it can be reused across TRIVA services.';

  @override
  String get useThisVehicle => 'Use this vehicle';

  @override
  String get chooseAnotherVehicle => 'Choose another vehicle';

  @override
  String get nonToyotaTitle => 'This vehicle is not a Toyota';

  @override
  String get nonToyotaDescription =>
      'Toyota Booking is only available for Toyota vehicles. You can still continue through the OtoXpert network.';

  @override
  String get continueOtoxpert => 'Continue to OtoXpert Booking';

  @override
  String get otoxpertUnavailableMessage =>
      'OtoXpert Booking is not enabled yet. Your vehicle remains saved.';

  @override
  String get serviceWhereTitle => 'Where should we service it?';

  @override
  String get serviceWhereDescription =>
      'Choose the service method that suits you.';

  @override
  String get workshopService => 'Auto2000 Workshop';

  @override
  String get workshopServiceDescription =>
      'Visit the workshop at the confirmed schedule.';

  @override
  String get thsService => 'Toyota Home Service (THS)';

  @override
  String get thsServiceDescription =>
      'A technician visits an address within the service area.';

  @override
  String get scheduleNeedsConfirmation =>
      'Your selected schedule still needs staff confirmation.';

  @override
  String get chooseServiceType => 'Choose service type';

  @override
  String get serviceTypeTitle => 'What do you need?';

  @override
  String get serviceTypeDescription => 'Choose one service for your Toyota.';

  @override
  String get serviceTypesEmpty => 'No service types are available';

  @override
  String get serviceTypesEmptyDescription =>
      'An admin has not enabled a service for this option.';

  @override
  String get serviceAdvisorConfirmation =>
      'The final recommendation will be confirmed by a Service Advisor.';

  @override
  String get continueServiceDetails => 'Continue to service details';

  @override
  String get serviceDetailsTitle => 'Service details';

  @override
  String get serviceDetailsDescription =>
      'Add mileage and the concern so staff can prepare the service.';

  @override
  String get currentMileage => 'Current mileage';

  @override
  String get complaint => 'Concern or notes';

  @override
  String get complaintHint => 'Describe the symptom or service need';

  @override
  String get supportingPhotoOptional => 'Supporting photo (optional)';

  @override
  String get addSupportingPhoto => 'Add photo';

  @override
  String get removeSupportingPhoto => 'Remove photo';

  @override
  String get supportingPhotoPrivacy =>
      'Only authorized staff can view this photo.';

  @override
  String get chooseSchedule => 'Choose schedule';

  @override
  String get schedulePreferenceTitle => 'When would you like service?';

  @override
  String get schedulePreferenceDescription =>
      'Choose two different times as your primary and alternate preferences.';

  @override
  String get primaryPreference => 'Primary schedule';

  @override
  String get alternativePreference => 'Alternate schedule';

  @override
  String get preferenceNotSlot =>
      'This time is a preference and does not reserve a slot.';

  @override
  String bookingLeadTimeNotice(int days) {
    return 'Request at least $days days before the selected date.';
  }

  @override
  String get availabilityEmpty => 'No requestable times yet';

  @override
  String get availabilityEmptyDescription =>
      'Change the location or service, then check the schedule again.';

  @override
  String get availabilityLoadFailed =>
      'The schedule could not be loaded. Check your connection and try again.';

  @override
  String get reviewBooking => 'Review booking';

  @override
  String get thsAddressTitle => 'THS visit location';

  @override
  String get thsAddressDescription =>
      'An address and pin are required so staff can check service coverage.';

  @override
  String get fullAddress => 'Full address';

  @override
  String get locationNotes => 'Location notes';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get setManualPin => 'Set pin manually';

  @override
  String get pinLocationSet => 'Location pin is set';

  @override
  String get thsAddressPinRequired =>
      'Address, city, and location pin are required for THS.';

  @override
  String get thsCoverageAvailable => 'Service area available';

  @override
  String get thsCoverageUnavailable =>
      'This address is not yet within the THS service area';

  @override
  String get manualPinTitle => 'Set location coordinates';

  @override
  String get manualPinDescription =>
      'Enter coordinates from your device map if location permission is unavailable.';

  @override
  String get savePin => 'Save pin';

  @override
  String get reviewServiceRequestTitle => 'Review service request';

  @override
  String get reviewServiceRequestDescription =>
      'Check the details before sending your request.';

  @override
  String get location => 'Location';

  @override
  String get service => 'Service';

  @override
  String get primarySchedule => 'Primary schedule';

  @override
  String get alternativeSchedule => 'Alternate';

  @override
  String get contactChannel => 'Confirmation channel';

  @override
  String get requestToConfirmNotice =>
      'Your schedule is a preference and is not yet confirmed.';

  @override
  String get serviceBookingConsent =>
      'I agree to data processing for this service request.';

  @override
  String get submitServiceRequest => 'Send service request';

  @override
  String get serviceRequestSubmittedTitle => 'Service request sent';

  @override
  String get serviceRequestSubmittedDescription =>
      'Your schedule is not yet confirmed.';

  @override
  String get awaitingStaffConfirmation => 'Awaiting staff confirmation';

  @override
  String get viewBookingDetail => 'View booking details';

  @override
  String get bookingDetailTitle => 'Booking details';

  @override
  String get bookingTimelineTitle => 'Booking progress';

  @override
  String get alternativeProposedTitle => 'Alternate schedule proposed';

  @override
  String get originalScheduleUnavailable =>
      'The primary schedule is unavailable';

  @override
  String get advisorProposal => 'Service Advisor proposal';

  @override
  String get proposalDeadline => 'Response deadline';

  @override
  String get noScheduleConfirmed => 'No schedule has been confirmed.';

  @override
  String get acceptAlternative => 'Accept alternate schedule';

  @override
  String get rejectAlternative => 'Reject and choose another schedule';

  @override
  String get chooseReplacementSchedule => 'Choose replacement schedule';

  @override
  String get rejectionReasonOptional => 'Reason for change (optional)';

  @override
  String get bookingRejectedTitle => 'Service could not be scheduled';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get createNewRequest => 'Create a new request';

  @override
  String get backToActivity => 'Back to activity';

  @override
  String get bookingConfirmedTitle => 'Booking confirmed';

  @override
  String get confirmedSchedule => 'Your service schedule';

  @override
  String get serviceAdvisor => 'PIC (Service Advisor)';

  @override
  String get partnerBookingNumber => 'Partner booking number';

  @override
  String get arrivalInstructions => 'Arrival instructions';

  @override
  String get openDirections => 'Open directions';

  @override
  String get requestReschedule => 'Request reschedule';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get rescheduleTitle => 'Request reschedule';

  @override
  String get currentConfirmedSchedule => 'Current schedule (confirmed)';

  @override
  String get newPrimarySchedule => 'New primary choice';

  @override
  String get newAlternativeSchedule => 'New alternate choice';

  @override
  String get changeReason => 'Reason for change';

  @override
  String get oldScheduleRemains =>
      'The old schedule remains valid until staff confirms the change.';

  @override
  String get submitReschedule => 'Send reschedule request';

  @override
  String get serviceInProgressTitle => 'Service in progress';

  @override
  String get vehicleBeingServiced => 'Your vehicle is being serviced';

  @override
  String get contactServiceAdvisor => 'Contact Service Advisor';

  @override
  String get viewServiceDetails => 'View service details';

  @override
  String get serviceCompletedTitle => 'Service completed';

  @override
  String get serviceCompletedDescription => 'Your vehicle service is complete.';

  @override
  String get workshopFinalDetailsNotice =>
      'Final work and cost details follow the workshop document.';

  @override
  String get viewInActivity => 'View in Activity';

  @override
  String get leaveServiceFeedback => 'Leave service feedback';

  @override
  String get bookingCancelledTitle => 'Booking cancelled';

  @override
  String get bookingExpiredTitle => 'Request expired';

  @override
  String get bookingNoShowTitle => 'Visit not recorded';

  @override
  String get bookingGenericDescription =>
      'Check the timeline for the latest staff update.';

  @override
  String get cancelReason => 'Cancellation reason';

  @override
  String get confirmCancellation => 'Cancel this booking?';

  @override
  String get confirmCancellationDescription =>
      'The booking history remains in My Activity.';

  @override
  String get bookingMutationFailed =>
      'The change could not be saved. Try again.';

  @override
  String get bookingOfflineError =>
      'You are offline. Your draft is saved; connect to the internet and try again.';

  @override
  String get bookingRateLimitError =>
      'Too many booking attempts were made. Wait a moment, then submit again. Your draft is saved.';

  @override
  String get bookingDuplicateError =>
      'An active booking with the same vehicle and schedule already exists.';

  @override
  String get bookingIncompleteError =>
      'Complete all required information before submitting.';

  @override
  String get bookingSubmissionError =>
      'The service request could not be submitted. Your draft is saved; please try again.';

  @override
  String get activityEmptyDescription =>
      'Your appraisals, bookings, Body & Paint estimates, and credit simulations will appear here.';

  @override
  String get activityAppraisalsLoadFailed =>
      'Appraisal activity could not be loaded. Your service bookings are still shown.';

  @override
  String get activityBookingsLoadFailed =>
      'Service booking activity could not be loaded. Your appraisals are still shown.';

  @override
  String get activityAppraisalLabel => 'Trade-in appraisal';

  @override
  String get activityToyotaBookingLabel => 'Toyota Booking';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsMarkAllReadError =>
      'Could not mark notifications as read. Please try again.';

  @override
  String get notificationsLoadError => 'Notifications could not be loaded.';

  @override
  String get notificationsOfflineError =>
      'Notifications cannot be refreshed while offline.';

  @override
  String get notificationOpenAction => 'Open details';

  @override
  String get adminConfirmBooking => 'Confirm booking';

  @override
  String get adminProposeAlternative => 'Propose alternate schedule';

  @override
  String get adminRejectBooking => 'Reject request';

  @override
  String get adminApproveReschedule => 'Approve reschedule';

  @override
  String get adminRejectReschedule => 'Reject reschedule';

  @override
  String get adminCheckIn => 'Record check-in';

  @override
  String get adminStartService => 'Start service';

  @override
  String get adminCompleteService => 'Complete service';

  @override
  String get adminMarkNoShow => 'Mark no-show';

  @override
  String get adminActionReason => 'Reason or notes';

  @override
  String get advisorName => 'Service Advisor name';

  @override
  String get advisorPhone => 'Service Advisor phone';

  @override
  String get externalBookingNumber => 'Partner booking number';

  @override
  String get internalNote => 'Internal note';

  @override
  String get proposalExpiryInvalid =>
      'The response deadline must be after now and before both the proposed slot and the still-active confirmed appointment.';

  @override
  String get proposedPicName => 'Proposed appointment PIC';

  @override
  String get proposedArrivalInstructions => 'Proposed arrival instructions';

  @override
  String timelineActor(String name, String type) {
    return 'By $name ($type)';
  }

  @override
  String get assignedAdvisor => 'Assigned admin advisor';

  @override
  String get instructions => 'Instructions for customer';

  @override
  String get sendAdminAction => 'Save action';

  @override
  String get adminActionSuccess => 'Booking status updated.';

  @override
  String get customer => 'Customer';

  @override
  String get status => 'Status';

  @override
  String get fulfillment => 'Service method';

  @override
  String get updatedAt => 'Updated';

  @override
  String get copyReference => 'Copy reference number';

  @override
  String get referenceCopied => 'Reference number copied.';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get locationServicesDisabled =>
      'Device location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permission was not granted.';

  @override
  String get locationMapFallback => 'Choose the point manually on the map.';

  @override
  String get photoUploadFailed =>
      'The photo could not be uploaded. Check your connection and try again.';

  @override
  String get photoTooLarge => 'Photo size must not exceed 10 MB.';

  @override
  String get photoInvalidType => 'Use a JPG, JPEG, PNG, HEIC, or HEIF photo.';

  @override
  String get benefitVehicleTitle => 'Vehicle benefits';

  @override
  String get supportingPhotosTitle => 'Supporting photos';

  @override
  String get preferencePrimary => 'Primary preference';

  @override
  String get preferenceAlternative => 'Alternative preference';

  @override
  String get proposedScheduleLabel => 'Advisor-proposed schedule';

  @override
  String get confirmedScheduleLabel => 'Confirmed schedule';

  @override
  String get reschedulePrimaryLabel => 'New primary schedule request';

  @override
  String get rescheduleAlternativeLabel => 'New alternative schedule request';

  @override
  String get proposalReasonLabel => 'Proposal reason';

  @override
  String get proposalContextLabel => 'Proposal context';

  @override
  String get rescheduleReasonLabel => 'Reschedule reason';

  @override
  String get responseDeadline => 'Response deadline';

  @override
  String get completedAtLabel => 'Completed at';

  @override
  String get slaOverdueLabel => 'SLA overdue';

  @override
  String get dateIsoLabel => 'Date (YYYY-MM-DD)';

  @override
  String get timeWindowLabel => 'Time window';

  @override
  String get picNameLabel => 'PIC name';

  @override
  String get arrivalInstructionsLabel => 'Arrival instructions';

  @override
  String get alternativeReasonLabel => 'Alternative reason';

  @override
  String get responseDeadlineIsoLabel => 'Response deadline (ISO 8601)';

  @override
  String get reasonCodeLabel => 'Reason code';

  @override
  String get benefitTypeLabel => 'Benefit type';

  @override
  String get benefitStatusLabel => 'Benefit status';

  @override
  String get verificationSourceLabel => 'Verification source';

  @override
  String get benefitNotesLabel => 'Benefit notes';

  @override
  String get confirmActionPrompt => 'Continue with this action?';

  @override
  String get pendingVerificationLabel => 'Will be verified by an advisor';

  @override
  String get bookingAwaitingNotice =>
      'The request is not confirmed yet. An advisor will check both schedule preferences.';

  @override
  String get bookingAlternativeNotice =>
      'The primary schedule is unavailable. Review the proposed alternative before the response deadline.';

  @override
  String get bookingRescheduleNotice =>
      'The reschedule request is under review. The previous schedule remains valid until the change is confirmed.';

  @override
  String get bookingCheckedInNotice =>
      'The vehicle has checked in and is waiting for service.';

  @override
  String get bookingInServiceNotice =>
      'The vehicle is currently being serviced.';

  @override
  String get bookingCompletedNotice =>
      'Service is complete. Final work and pricing follow the workshop document.';

  @override
  String get bookingTerminalNotice =>
      'This booking cannot continue. You can create a new request.';

  @override
  String get profilePhoneRequired =>
      'Add a phone number to your profile before submitting the booking.';

  @override
  String get thsOperationalVerification =>
      'An advisor will verify this area before confirmation.';

  @override
  String get thsTemporarilyUnavailable =>
      'Toyota Home Service is not available while the operational coverage area is being verified.';

  @override
  String get serviceFulfillmentUnavailableTitle =>
      'Service location unavailable';

  @override
  String get serviceFulfillmentUnavailableDescription =>
      'No operational workshop or Toyota Home Service location is available right now. Please try again later.';

  @override
  String get serviceSelectionChanged =>
      'This saved service selection is no longer operational. Choose the location and service again before submitting.';

  @override
  String get chooseServiceLocationAgain => 'Choose service again';

  @override
  String get otoxpertFlowTitle => 'OtoXpert Booking';

  @override
  String get otoxpertSelectVehicle => 'Select a vehicle';

  @override
  String get otoxpertSelectVehicleDescription =>
      'Choose a saved vehicle to show compatible workshops.';

  @override
  String get otoxpertChooseWorkshop => 'Choose an OtoXpert workshop';

  @override
  String get otoxpertWorkshopEmpty =>
      'No compatible workshop is currently available for this vehicle.';

  @override
  String get otoxpertChooseService => 'Choose a workshop service';

  @override
  String get otoxpertSymptoms => 'Vehicle symptoms';

  @override
  String get otoxpertLastServiceDate => 'Last service date (optional)';

  @override
  String get otoxpertPickupDelivery => 'Request vehicle pickup and delivery';

  @override
  String get otoxpertPartnerConsent =>
      'I consent to sharing the vehicle and complaint details with the OtoXpert workshop to process this request.';

  @override
  String get otoxpertIndicativePrice => 'Indicative estimate';

  @override
  String get otoxpertPriceDisclaimer =>
      'The workshop determines the final price after inspecting the vehicle.';

  @override
  String get otoxpertRequestSubmitted =>
      'The OtoXpert request was submitted and is awaiting workshop confirmation.';

  @override
  String get otoxpertAdminQueue => 'OtoXpert Booking Queue';

  @override
  String get otoxpertAllStatuses => 'All statuses';

  @override
  String get otoxpertMaximumPrice => 'Maximum estimate';

  @override
  String get otoxpertFollowUpOutcome => 'Follow-up outcome';

  @override
  String get activityOtoxpertBookingLabel => 'OtoXpert Booking';

  @override
  String get activityOtoxpertLoadFailed =>
      'OtoXpert activity could not be loaded. Other activity is still shown.';

  @override
  String get loadingData => 'Preparing data…';

  @override
  String get creditFlowTitle => 'Credit simulation';

  @override
  String get creditFlowSubtitle =>
      'Compare installments from active programs. This result is an estimate, not a credit approval.';

  @override
  String get creditProgramLabel => 'Program and target vehicle';

  @override
  String get creditProgramHelper =>
      'The program determines OTR price, term, rate, and fees.';

  @override
  String get creditSpektaBadge => 'SPEKTA 20% down payment';

  @override
  String get creditRecommendedDp => 'Package recommended down payment';

  @override
  String get creditProgramName => 'Program name';

  @override
  String get creditPartner => 'Financing partner';

  @override
  String get creditDemoBadge => 'Demo';

  @override
  String get creditDemoProgramNotice =>
      'This program uses demo data for testing. Its figures are not a credit offer or approval.';

  @override
  String get creditNoProgramsTitle => 'No credit program available';

  @override
  String get creditNoProgramsDescription =>
      'An active program for the target city and vehicle has not been entered yet. Try again after the team updates the program.';

  @override
  String get creditTargetVehicle => 'Target vehicle';

  @override
  String get creditOtrCity => 'OTR city';

  @override
  String get creditOtrPrice => 'OTR price';

  @override
  String get creditDownPaymentSection => 'Initial funds';

  @override
  String get creditCashDownPayment => 'Cash down payment';

  @override
  String get creditDpRange => 'Total down payment range';

  @override
  String creditDpBelowMinimum(String minimum) {
    return 'The minimum total down payment is $minimum.';
  }

  @override
  String creditDpAboveMaximum(String maximum) {
    return 'The maximum total down payment is $maximum.';
  }

  @override
  String get creditTradeInManual => 'Manual trade-in value';

  @override
  String get creditTradeInRequired =>
      'Enter the trade-in value to use as a down payment.';

  @override
  String get creditExpiredAppraisalWarning =>
      'The appraisal result has expired and must be verified again.';

  @override
  String get creditTradeInFromAppraisal =>
      'The trade-in value will be taken from this appraisal result.';

  @override
  String get creditUseTradeInAsDp => 'Use trade-in equity as down payment';

  @override
  String get creditOldVehiclePayoff => 'Outstanding old vehicle payoff';

  @override
  String get creditTenorSection => 'Tenor and instalment';

  @override
  String get creditTenorSectionHelper =>
      'Pick the tenor that fits your budget.';

  @override
  String get creditTenor => 'Term';

  @override
  String get creditMonths => 'months';

  @override
  String get creditInvalidNumber => 'Enter a valid Rupiah amount.';

  @override
  String get creditRatePerYear => 'Annual flat rate';

  @override
  String get creditCalculate => 'Calculate estimate';

  @override
  String get creditCalculating => 'Calculating…';

  @override
  String get creditResultTitle => 'Estimate summary';

  @override
  String get creditMonthlyInstallment => 'Monthly installment';

  @override
  String get creditInitialPayment => 'Initial payment';

  @override
  String get creditPrincipal => 'Financed principal';

  @override
  String get creditTotalDownPayment => 'Total down payment composition';

  @override
  String get creditTradeInEquity => 'Trade-in equity';

  @override
  String get creditApprovedDiscount => 'Program discount';

  @override
  String get creditTotalInterest => 'Total flat interest';

  @override
  String get creditAdministrationFee => 'Administration';

  @override
  String get creditProvisionFee => 'Provision';

  @override
  String get creditInsuranceFee => 'Upfront insurance';

  @override
  String get creditFeeNotIncluded => 'Not included yet';

  @override
  String get creditOtherFee => 'Other fees';

  @override
  String get creditTotalPayment => 'Estimated total payment';

  @override
  String get creditValidUntil => 'Program valid until';

  @override
  String get creditAddComparison => 'Add to comparison';

  @override
  String get creditComparisonTitle => 'Scenario comparison';

  @override
  String creditScenarioCount(int count) {
    return '$count of 3 scenarios';
  }

  @override
  String get creditScenarioLimit => 'You can compare up to three scenarios.';

  @override
  String get creditScenarioDuplicate =>
      'This scenario is already in the comparison.';

  @override
  String get creditSave => 'Save simulation';

  @override
  String get creditSaving => 'Saving…';

  @override
  String get creditSavedTitle => 'Simulation saved';

  @override
  String get creditSavedDescription =>
      'The program snapshot and calculation are saved in My Activity.';

  @override
  String get creditRequestSales => 'Request a sales call';

  @override
  String get creditRequestingFollowUp => 'Sending request…';

  @override
  String get creditFollowUpConsentTitle => 'Send this to the sales team?';

  @override
  String get creditFollowUpConsentDescription =>
      'I consent to the sales team using my contact details and this simulation snapshot to follow up.';

  @override
  String get creditContactChannel => 'Contact channel';

  @override
  String get creditContactWhatsapp => 'WhatsApp';

  @override
  String get creditContactPhone => 'Phone';

  @override
  String get creditContactEmail => 'Email';

  @override
  String get creditFollowUpSuccess =>
      'The follow-up request was sent to the sales team.';

  @override
  String get creditEstimateDisclaimer =>
      'This estimate is not a credit approval. Final values are subject to sales and financing partner verification.';

  @override
  String get creditExpiredAppraisalConsent =>
      'I understand the appraisal result may be expired and require reverification.';

  @override
  String get creditDraftAppraisalNotice =>
      'The selected appraisal result will be used as the trade-in indication.';

  @override
  String get creditActivityLabel => 'Credit simulation';

  @override
  String get creditActivityLoadFailed =>
      'Credit simulation activity could not be loaded. Other activity is still shown.';

  @override
  String get creditProgramExpired =>
      'The program in this snapshot has ended. The saved details remain available.';

  @override
  String get creditLoadFailed => 'Credit simulation data could not be loaded.';

  @override
  String get creditStartNew => 'Create a new simulation';

  @override
  String get creditViewSaved => 'View saved simulation';

  @override
  String get creditShareSummary => 'Share summary';

  @override
  String get creditSource => 'Program source';

  @override
  String get bodyPaintFlowTitle => 'Body & Paint Estimate';

  @override
  String get bodyPaintFlowSubtitle =>
      'Select damaged panels and upload photos to receive an estimate range from an estimator.';

  @override
  String get bodyPaintVehicle => 'Vehicle';

  @override
  String get bodyPaintLocation => 'Inspection or repair location';

  @override
  String get bodyPaintDamage => 'Damage';

  @override
  String get bodyPaintAddDamage => 'Add damaged panel';

  @override
  String get bodyPaintPanel => 'Vehicle panel';

  @override
  String get bodyPaintDamageType => 'Damage type';

  @override
  String get bodyPaintSeverity => 'Damage severity';

  @override
  String get bodyPaintDamageNote => 'Damage note (optional)';

  @override
  String get bodyPaintClosePhoto => 'Close-up damage photo';

  @override
  String get bodyPaintContextPhoto => 'Vehicle context photo';

  @override
  String get bodyPaintChoosePhoto => 'Choose photo';

  @override
  String get bodyPaintReplacePhoto => 'Replace photo';

  @override
  String get bodyPaintPhotoReady => 'Photo ready to send';

  @override
  String get bodyPaintInsuranceQuestion => 'Is this vehicle insured?';

  @override
  String get bodyPaintInsuranceYes => 'Yes, it is insured';

  @override
  String get bodyPaintInsuranceNo => 'No insurance';

  @override
  String get bodyPaintInsuranceProvider => 'Insurance company';

  @override
  String get bodyPaintInsuranceHint =>
      'Repairs handled through an insurance claim do not show a cost estimate. Our team will help with the claim.';

  @override
  String get bodyPaintNotes => 'Note for estimator (optional)';

  @override
  String get bodyPaintConsent =>
      'I consent to my vehicle photos and data being used for the estimate and understand the result is indicative until a physical inspection.';

  @override
  String get bodyPaintSubmit => 'Submit estimate request';

  @override
  String get bodyPaintSubmitting => 'Submitting estimateâ€¦';

  @override
  String get bodyPaintRequirementNotice =>
      'Each panel needs one close-up photo and every request needs one vehicle context photo.';

  @override
  String get bodyPaintSubmittedTitle => 'Estimate request submitted';

  @override
  String get bodyPaintSubmittedDescription =>
      'An estimator will review the photos before the result is displayed. Track progress in My Activity.';

  @override
  String get bodyPaintViewEstimate => 'View estimate progress';

  @override
  String get bodyPaintActivityLabel => 'Body & Paint estimate';

  @override
  String get bodyPaintActivityLoadFailed =>
      'Body & Paint activity could not be loaded. Other activity is still shown.';

  @override
  String get bodyPaintNoEstimates => 'No Body & Paint estimates yet.';

  @override
  String get bodyPaintEstimateResult => 'Estimate range';

  @override
  String get bodyPaintVersion => 'Estimate version';

  @override
  String get bodyPaintDuration => 'Work duration';

  @override
  String get bodyPaintDays => 'days';

  @override
  String get bodyPaintValidUntil => 'Valid until';

  @override
  String get bodyPaintPhysicalInspection =>
      'The final amount still requires a physical vehicle inspection.';

  @override
  String get bodyPaintAssumptions => 'Estimator assumptions';

  @override
  String get bodyPaintTimeline => 'Estimate timeline';

  @override
  String get bodyPaintAccept => 'Accept estimate';

  @override
  String get bodyPaintDecline => 'Do not continue';

  @override
  String get bodyPaintDeclineReason => 'Reason for not continuing (optional)';

  @override
  String get bodyPaintRequestBooking => 'Continue to Body & Paint booking';

  @override
  String get bodyPaintBookingTitle => 'Choose booking schedule';

  @override
  String get bodyPaintPrimarySlot => 'Primary schedule';

  @override
  String get bodyPaintAlternativeSlot => 'Alternative schedule';

  @override
  String get bodyPaintComplaint => 'Note for workshop';

  @override
  String get bodyPaintMileage => 'Current mileage';

  @override
  String get bodyPaintBookingConsent =>
      'I consent to forwarding this estimate data for the booking request.';

  @override
  String get bodyPaintRequestPhotos => 'The estimator requested updated photos';

  @override
  String get bodyPaintResubmit => 'Resubmit photos';

  @override
  String get bodyPaintAdminQueue => 'Body & Paint Estimate Queue';

  @override
  String get bodyPaintAdminEmpty => 'There are no estimates in the queue.';

  @override
  String get bodyPaintCustomer => 'Customer';

  @override
  String get bodyPaintEstimator => 'Estimator';

  @override
  String get bodyPaintEngineEstimate => 'Engine suggestion';

  @override
  String get bodyPaintStartReview => 'Start review';

  @override
  String get bodyPaintAssignSelf => 'Take this estimate';

  @override
  String get bodyPaintPublish => 'Publish estimate';

  @override
  String get bodyPaintPublishDescription =>
      'Review the cost for each panel. Changes from the engine suggestion require a reason.';

  @override
  String get bodyPaintWorkType => 'Work type';

  @override
  String get bodyPaintLowCost => 'Minimum cost';

  @override
  String get bodyPaintHighCost => 'Maximum cost';

  @override
  String get bodyPaintMinHours => 'Minimum duration (hours)';

  @override
  String get bodyPaintMaxHours => 'Maximum duration (hours)';

  @override
  String get bodyPaintRecommendation => 'Recommendation (optional)';

  @override
  String get bodyPaintAssumption => 'Assumptions, one per line';

  @override
  String get bodyPaintDisclaimer => 'Disclaimer';

  @override
  String get bodyPaintValidDays => 'Validity (days)';

  @override
  String get bodyPaintOverrideReason => 'Correction or override reason';

  @override
  String get bodyPaintAdminActionSuccess => 'Estimate updated successfully.';

  @override
  String get bodyPaintCompleteFields =>
      'Complete all data, photos, and consent first.';

  @override
  String get bodyPaintLoadFailed =>
      'Body & Paint estimate data could not be loaded.';

  @override
  String get bodyPaintRequestPhotoReason =>
      'Explain which photos need to be updated';

  @override
  String get bodyPaintLabor => 'Labor';

  @override
  String get bodyPaintMaterial => 'Material';

  @override
  String get bodyPaintParts => 'Parts';

  @override
  String get bodyPaintOther => 'Other costs';

  @override
  String get bodyPaintRepair => 'Panel repair';

  @override
  String get bodyPaintPaint => 'Painting';

  @override
  String get bodyPaintReplace => 'Replacement';

  @override
  String get bodyPaintPolish => 'Polish';

  @override
  String get bodyPaintPublishAssumptionDefault =>
      'The estimate is based on the visible condition in the submitted photos.';

  @override
  String get bodyPaintPublishDisclaimerDefault =>
      'This estimate is indicative and the final amount is determined after a physical vehicle inspection.';

  @override
  String get bodyPaintSearch => 'Search reference, customer, or vehicle';

  @override
  String get bodyPaintAllStatuses => 'All statuses';

  @override
  String get bodyPaintLight => 'Light';

  @override
  String get bodyPaintMedium => 'Medium';

  @override
  String get bodyPaintHeavy => 'Heavy';

  @override
  String get bodyPaintInspect => 'Inspection';

  @override
  String get gender => 'Gender';

  @override
  String get chooseGender => 'Choose gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderUndisclosed => 'Prefer not to say';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get chooseBirthDate => 'Choose date of birth';

  @override
  String get adminDemographicsTitle => 'User gender & age';

  @override
  String get adminDemographicsDescription =>
      'Registered customers grouped by gender and age range.';

  @override
  String get adminDemographicsRegistered => 'Registered users';

  @override
  String adminDemographicsCompleted(String count, String percent) {
    return '$count have completed their data ($percent)';
  }

  @override
  String get adminDemographicsGender => 'Gender';

  @override
  String get adminDemographicsAge => 'Age range';

  @override
  String get adminDemographicsEmptyTitle => 'No users yet';

  @override
  String get adminDemographicsEmptyDescription =>
      'Gender and age breakdowns appear once customers register.';

  @override
  String get adminMenuUsageTitle => 'Most used menus';

  @override
  String get adminMenuUsageDescription =>
      'Menus ranked by how often customers tap them.';

  @override
  String get adminMenuUsageTotal => 'Total menu taps';

  @override
  String get adminMenuUsageEmptyTitle => 'No menu taps yet';

  @override
  String get adminMenuUsageEmptyDescription =>
      'Data appears once customers start opening menus in the app.';

  @override
  String get adminMenuUsagePeriodEmpty =>
      'No menus were opened in this period.';

  @override
  String get adminPlayStoreTitle => 'Total app downloads';

  @override
  String get adminPlayStoreDescription =>
      'Unique devices that have opened TRIVA.';

  @override
  String get adminPlayStoreRefresh => 'Refresh Play Store downloads';

  @override
  String get adminPlayStoreSourceUniqueDevices =>
      'Counted from unique devices that have opened the app. Devices that installed but never signed in are not counted, so this reads lower than Play Store downloads.';

  @override
  String get adminPlayStoreTotal => 'Total downloads';

  @override
  String get adminPlayStoreSourceManual => 'Entered by hand from Play Console.';

  @override
  String get adminPlayStoreSourceReports =>
      'Read automatically from Play Console reports.';

  @override
  String adminPlayStoreReportedAt(String date) {
    return 'Figure as of $date.';
  }

  @override
  String get adminPlayStoreEmptyTitle => 'Downloads not filled in yet';

  @override
  String get adminPlayStoreEmptyDescription =>
      'No device has opened the app yet. The figure appears once the first person signs in from their device.';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminValueYes => 'Yes';

  @override
  String get adminValueNo => 'No';

  @override
  String get adminValueNotSet => 'Not provided';

  @override
  String adminAgeYears(int years) {
    return '$years years old';
  }

  @override
  String get adminUserActive => 'Active';

  @override
  String get adminRoleCustomer => 'Customer';

  @override
  String get adminReferenceOrCustomerHint =>
      'Search reference number or customer';

  @override
  String get adminUserDirectoryTitle => 'Registered users';

  @override
  String get adminUserDirectoryDescription =>
      'Every registered account with its full data';

  @override
  String get adminUserDirectorySearchHint =>
      'Search name, email, or phone number';

  @override
  String get adminUserDirectoryEmptyTitle => 'No users';

  @override
  String get adminUserDirectoryEmptyDescription =>
      'No user matches this search or filter.';

  @override
  String get adminUserDetailTitle => 'User detail';

  @override
  String get adminSectionAccount => 'Account';

  @override
  String get adminSectionDemographics => 'Demographics';

  @override
  String get adminSectionConsent => 'Consent';

  @override
  String get adminSectionActivity => 'Activity';

  @override
  String get adminSectionDevices => 'Devices';

  @override
  String get adminSectionCustomer => 'Customer';

  @override
  String get adminSectionSummary => 'Summary';

  @override
  String get adminSectionValuation => 'Valuation';

  @override
  String get adminSectionCondition => 'Vehicle condition';

  @override
  String get adminSectionTimeline => 'Status history';

  @override
  String get adminSectionSimulation => 'Simulation details';

  @override
  String get adminFieldAccountStatus => 'Account status';

  @override
  String get adminFieldRoles => 'Roles';

  @override
  String get adminFieldRegisteredAt => 'Registered';

  @override
  String get adminFieldLastActive => 'Last active';

  @override
  String get adminFieldAge => 'Age';

  @override
  String get adminFieldServiceConsent => 'Service consent';

  @override
  String get adminFieldMarketingConsent => 'Marketing consent';

  @override
  String get adminFieldEmailVerified => 'Email verified';

  @override
  String get adminFieldPhoneVerified => 'Phone verified';

  @override
  String get adminFieldReference => 'Reference number';

  @override
  String get adminFieldSubmittedAt => 'Submitted';

  @override
  String get adminFieldUpdatedAt => 'Updated';

  @override
  String get adminFieldExpectedPrice => 'Customer expected price';

  @override
  String get adminFieldTradeInEstimate => 'Trade-in estimate';

  @override
  String get adminFieldDecision => 'Customer decision';

  @override
  String get adminAppraisalQueueTitle => 'Appraisal list';

  @override
  String get adminAppraisalEmptyTitle => 'No appraisals yet';

  @override
  String get adminAppraisalEmptyDescription =>
      'Customer appraisals appear here once created.';

  @override
  String get adminAppraisalDetailTitle => 'Appraisal detail';

  @override
  String get adminConditionTaxStatus => 'Tax status';

  @override
  String get adminConditionFlood => 'Flood history';

  @override
  String get adminConditionAccident => 'Major accident history';

  @override
  String get adminConditionService => 'Service history';

  @override
  String get adminConditionOwnership => 'Ownership';

  @override
  String get adminConditionGrade => 'Condition grade';

  @override
  String get adminConditionEngine => 'Engine condition';

  @override
  String get adminConditionTyre => 'Tyre condition';

  @override
  String get adminCreditQueueTitle => 'Credit simulations';

  @override
  String get adminCreditEmptyTitle => 'No simulations yet';

  @override
  String get adminCreditEmptyDescription =>
      'Customer credit simulations appear here once saved.';

  @override
  String get adminCreditDetailTitle => 'Credit simulation detail';

  @override
  String adminCreditInstallmentPerMonth(String amount, int months) {
    return '$amount per month · $months months';
  }

  @override
  String get adminFieldProgram => 'Program';

  @override
  String get adminFieldSavedAt => 'Saved';

  @override
  String get adminFieldFollowUp => 'Follow-up';

  @override
  String get adminFieldOtr => 'OTR price';

  @override
  String get adminFieldDownPayment => 'Total down payment';

  @override
  String get adminFieldTradeIn => 'Trade-in value';

  @override
  String get adminFieldTenor => 'Tenor';

  @override
  String adminTenorMonths(int months) {
    return '$months months';
  }

  @override
  String get adminFieldMonthlyInstallment => 'Monthly installment';

  @override
  String get adminFieldInitialPayment => 'Initial payment';

  @override
  String get adminFieldTotalPayment => 'Total payment';

  @override
  String get adminPanelUserDirectoryDescription =>
      'Browse every user and their data';

  @override
  String get adminPanelAppraisalDescription =>
      'Browse every customer appraisal';

  @override
  String get adminPanelCreditDescription =>
      'Browse every customer credit simulation';

  @override
  String get maintenanceBadge => 'Service Status';

  @override
  String get maintenanceTitle => 'System Under Maintenance';

  @override
  String get maintenanceDefaultMessage =>
      'TRIVA is undergoing scheduled maintenance. Please try again shortly.';

  @override
  String maintenanceEstimate(String time) {
    return 'Expected to be back at $time';
  }

  @override
  String get maintenanceStillDown =>
      'The system is still under maintenance. Please try again later.';

  @override
  String get maintenanceThanks => 'Thank you for your patience.';
}
