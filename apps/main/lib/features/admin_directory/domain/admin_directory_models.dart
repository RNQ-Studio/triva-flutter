/// Model bersama untuk daftar admin: pengguna, appraisal, dan simulasi kredit.
///
/// Parsingnya sengaja permisif karena backend dapat menambah field baru
/// kapan saja; yang wajib ada hanya pengenal dan label utama.
library;

class AdminCustomerRef {
  const AdminCustomerRef({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.city,
  });

  static AdminCustomerRef? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return AdminCustomerRef(
      id: '${value['id']}',
      name: value['name'] as String? ?? '',
      email: value['email'] as String?,
      phone: value['phone'] as String?,
      city: value['city'] as String?,
    );
  }

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? city;
}

class AdminUserActivity {
  const AdminUserActivity({
    required this.appraisals,
    required this.toyotaServiceBookings,
    required this.otoxpertBookings,
    required this.creditSimulations,
    required this.bodyPaintEstimates,
    required this.vehicles,
    required this.devices,
  });

  static AdminUserActivity? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    int read(String key) => (value[key] as num?)?.toInt() ?? 0;
    return AdminUserActivity(
      appraisals: read('appraisals'),
      toyotaServiceBookings: read('toyota_service_bookings'),
      otoxpertBookings: read('otoxpert_bookings'),
      creditSimulations: read('credit_simulations'),
      bodyPaintEstimates: read('body_paint_estimates'),
      vehicles: read('vehicles'),
      devices: read('devices'),
    );
  }

  final int appraisals;
  final int toyotaServiceBookings;
  final int otoxpertBookings;
  final int creditSimulations;
  final int bodyPaintEstimates;
  final int vehicles;
  final int devices;

  int get total =>
      appraisals +
      toyotaServiceBookings +
      otoxpertBookings +
      creditSimulations +
      bodyPaintEstimates;
}

class AdminUserDevice {
  const AdminUserDevice({
    required this.id,
    required this.platform,
    this.deviceName,
    this.osVersion,
    this.appVersion,
    this.appBuild,
    this.lastActiveAt,
  });

  factory AdminUserDevice.fromJson(Map<String, dynamic> json) =>
      AdminUserDevice(
        id: '${json['id']}',
        platform: json['platform'] as String? ?? '',
        deviceName: json['device_name'] as String?,
        osVersion: json['os_version'] as String?,
        appVersion: json['app_version'] as String?,
        appBuild: json['app_build'] as String?,
        lastActiveAt: parseDate(json['last_active_at']),
      );

  final String id;
  final String platform;
  final String? deviceName;
  final String? osVersion;
  final String? appVersion;
  final String? appBuild;
  final DateTime? lastActiveAt;
}

class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.roles,
    required this.marketingConsent,
    required this.demographicsCompleted,
    this.phone,
    this.city,
    this.gender,
    this.genderLabel,
    this.birthDate,
    this.age,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.serviceConsentAt,
    this.createdAt,
    this.lastActiveAt,
    this.activity,
    this.devices = const [],
  });

  factory AdminUserRecord.fromJson(Map<String, dynamic> json) =>
      AdminUserRecord(
        id: '${json['id']}',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        isAdmin: json['is_admin'] as bool? ?? false,
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false),
        marketingConsent: json['marketing_consent'] as bool? ?? false,
        demographicsCompleted: json['demographics_completed'] as bool? ?? false,
        phone: json['phone'] as String?,
        city: json['city'] as String?,
        gender: json['gender'] as String?,
        genderLabel: json['gender_label'] as String?,
        birthDate: parseDate(json['birth_date']),
        age: (json['age'] as num?)?.toInt(),
        emailVerifiedAt: parseDate(json['email_verified_at']),
        phoneVerifiedAt: parseDate(json['phone_verified_at']),
        serviceConsentAt: parseDate(json['service_consent_at']),
        createdAt: parseDate(json['created_at']),
        lastActiveAt: parseDate(json['last_active_at']),
        activity: AdminUserActivity.fromJson(json['activity']),
        devices: (json['devices'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AdminUserDevice.fromJson)
            .toList(growable: false),
      );

  final String id;
  final String name;
  final String email;
  final bool isActive;
  final bool isAdmin;
  final List<String> roles;
  final bool marketingConsent;
  final bool demographicsCompleted;
  final String? phone;
  final String? city;
  final String? gender;
  final String? genderLabel;
  final DateTime? birthDate;
  final int? age;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime? serviceConsentAt;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  final AdminUserActivity? activity;
  final List<AdminUserDevice> devices;
}

class AdminAppraisalRecord {
  const AdminAppraisalRecord({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.raw,
    this.customer,
    this.vehicleLabel,
    this.expectedPrice,
    this.customerDecision,
    this.tradeInLow,
    this.tradeInHigh,
    this.submittedAt,
    this.updatedAt,
  });

  factory AdminAppraisalRecord.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'];
    final result = json['result'];
    final tradeIn = result is Map<String, dynamic>
        ? result['trade_in_estimate'] as Map<String, dynamic>?
        : null;

    return AdminAppraisalRecord(
      id: '${json['id']}',
      referenceNo: json['reference_no'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      raw: json,
      customer: AdminCustomerRef.fromJson(json['customer']),
      vehicleLabel:
          vehicle is Map<String, dynamic> ? _vehicleLabel(vehicle) : null,
      expectedPrice: (json['expected_price'] as num?)?.toInt(),
      customerDecision: json['customer_decision'] as String?,
      tradeInLow: (tradeIn?['low'] as num?)?.toInt(),
      tradeInHigh: (tradeIn?['high'] as num?)?.toInt(),
      submittedAt: parseDate(json['submitted_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final Map<String, dynamic> raw;
  final AdminCustomerRef? customer;
  final String? vehicleLabel;
  final int? expectedPrice;
  final String? customerDecision;
  final int? tradeInLow;
  final int? tradeInHigh;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  Map<String, dynamic> get condition =>
      raw['condition'] as Map<String, dynamic>? ?? const {};

  List<Map<String, dynamic>> get timeline =>
      (raw['timeline'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
}

String _vehicleLabel(Map<String, dynamic> vehicle) {
  final parts = <String>[
    if (vehicle['make'] is String) vehicle['make'] as String,
    if (vehicle['model'] is String) vehicle['model'] as String,
    if (vehicle['variant'] is String) vehicle['variant'] as String,
  ];
  final year = vehicle['year'];
  final label = parts.join(' ').trim();
  if (year is num) return label.isEmpty ? '$year' : '$label $year';
  return label;
}

class AdminCreditSimulationRecord {
  const AdminCreditSimulationRecord({
    required this.id,
    required this.referenceNo,
    required this.status,
    required this.statusLabel,
    required this.raw,
    this.customer,
    this.programName,
    this.otrPrice,
    this.totalDownPayment,
    this.tenorMonths,
    this.monthlyInstallment,
    this.initialPayment,
    this.totalPayment,
    this.tradeInValue,
    this.savedAt,
    this.followUpStatusLabel,
  });

  factory AdminCreditSimulationRecord.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? const {};
    final program = json['program'] as Map<String, dynamic>?;
    final followUp = json['follow_up'];

    int? amount(String key) => (totals[key] as num?)?.toInt();

    return AdminCreditSimulationRecord(
      id: '${json['id']}',
      referenceNo: json['reference_no'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      raw: json,
      customer: AdminCustomerRef.fromJson(json['customer']),
      programName: program?['program_name'] as String?,
      otrPrice: amount('otr_price'),
      totalDownPayment: amount('total_down_payment'),
      tenorMonths: amount('tenor_months'),
      monthlyInstallment: amount('monthly_installment'),
      initialPayment: amount('initial_payment'),
      totalPayment: amount('total_payment'),
      tradeInValue: amount('trade_in_value'),
      savedAt: parseDate(json['saved_at']),
      followUpStatusLabel: followUp is Map<String, dynamic>
          ? followUp['status_label'] as String?
          : null,
    );
  }

  final String id;
  final String referenceNo;
  final String status;
  final String statusLabel;
  final Map<String, dynamic> raw;
  final AdminCustomerRef? customer;
  final String? programName;
  final int? otrPrice;
  final int? totalDownPayment;
  final int? tenorMonths;
  final int? monthlyInstallment;
  final int? initialPayment;
  final int? totalPayment;
  final int? tradeInValue;
  final DateTime? savedAt;
  final String? followUpStatusLabel;
}

class AdminStatusOption {
  const AdminStatusOption({required this.value, required this.label});

  factory AdminStatusOption.fromJson(Map<String, dynamic> json) =>
      AdminStatusOption(
        value: json['value'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );

  final String value;
  final String label;
}

DateTime? parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
