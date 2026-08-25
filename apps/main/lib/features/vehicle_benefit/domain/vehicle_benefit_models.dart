/// Hasil pemeriksaan mandiri No. Rangka.
///
/// Notulensi 19 Agustus 2026 meminta pelanggan bisa mengecek sendiri apakah
/// unitnya terlibat SSC serta menghitung mundur sisa fasilitas T-Care, supaya
/// pelanggan yang masih tercakup diarahkan servis ke Auto2000.
class VehicleBenefitCheckResult {
  const VehicleBenefitCheckResult({
    required this.vin,
    required this.ssc,
    required this.tCare,
    required this.recommendation,
    this.year,
  });

  final String vin;
  final int? year;
  final SscStatus ssc;
  final TCareStatus tCare;
  final BenefitRecommendation recommendation;

  factory VehicleBenefitCheckResult.fromJson(Map<String, dynamic> json) =>
      VehicleBenefitCheckResult(
        vin: json['vin']?.toString() ?? '',
        year: (json['year'] as num?)?.toInt(),
        ssc: SscStatus.fromJson(
          Map<String, dynamic>.from(json['ssc'] as Map? ?? const {}),
        ),
        tCare: TCareStatus.fromJson(
          Map<String, dynamic>.from(json['t_care'] as Map? ?? const {}),
        ),
        recommendation: BenefitRecommendation.fromJson(
          Map<String, dynamic>.from(json['recommendation'] as Map? ?? const {}),
        ),
      );
}

class SscCampaign {
  const SscCampaign({
    required this.campaignCode,
    required this.title,
    this.description,
    this.recommendedAction,
  });

  final String campaignCode;
  final String title;
  final String? description;
  final String? recommendedAction;

  factory SscCampaign.fromJson(Map<String, dynamic> json) => SscCampaign(
        campaignCode: json['campaign_code']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
        recommendedAction: json['recommended_action']?.toString(),
      );
}

class SscStatus {
  const SscStatus({
    required this.status,
    required this.label,
    required this.message,
    required this.campaigns,
  });

  final String status;
  final String label;
  final String message;
  final List<SscCampaign> campaigns;

  bool get isAffected => status == 'affected';
  bool get isUnverified => status == 'unverified';

  factory SscStatus.fromJson(Map<String, dynamic> json) => SscStatus(
        status: json['status']?.toString() ?? 'unverified',
        label: json['label']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        campaigns: (json['campaigns'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SscCampaign.fromJson)
            .toList(growable: false),
      );
}

class TCareStatus {
  const TCareStatus({
    required this.status,
    required this.label,
    required this.message,
    this.monthsRemaining,
    this.expiresOn,
  });

  final String status;
  final String label;
  final String message;
  final int? monthsRemaining;
  final String? expiresOn;

  bool get isActive => status == 'active';

  factory TCareStatus.fromJson(Map<String, dynamic> json) => TCareStatus(
        status: json['status']?.toString() ?? 'unknown',
        label: json['label']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        monthsRemaining: (json['months_remaining'] as num?)?.toInt(),
        expiresOn: json['expires_on']?.toString(),
      );
}

class BenefitRecommendation {
  const BenefitRecommendation({
    required this.channel,
    required this.title,
    required this.message,
  });

  final String channel;
  final String title;
  final String message;

  bool get isToyotaService => channel == 'toyota_service';

  factory BenefitRecommendation.fromJson(Map<String, dynamic> json) =>
      BenefitRecommendation(
        channel: json['channel']?.toString() ?? 'toyota_service',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );
}
