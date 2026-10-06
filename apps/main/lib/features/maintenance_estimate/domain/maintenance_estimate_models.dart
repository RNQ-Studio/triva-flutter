/// Paket servis berkala beserta perkiraan biayanya.
///
/// Notulensi 19 Agustus 2026 meminta simulasi biaya servis berkala memakai
/// data paket reguler cabang.
class MaintenancePackage {
  const MaintenancePackage({
    required this.id,
    required this.code,
    required this.name,
    required this.kmInterval,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.includes,
    required this.durationMinMinutes,
    required this.durationMaxMinutes,
    this.description,
    this.vehicleModel,
    this.disclaimer,
    this.isActive = true,
    this.isEffective = true,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final String? vehicleModel;
  final int kmInterval;
  final int partsCost;
  final int laborCost;
  final int totalCost;
  final List<String> includes;
  final int durationMinMinutes;
  final int durationMaxMinutes;
  final String? disclaimer;

  /// Dua field berikut hanya dikirim endpoint admin. [isEffective] palsu
  /// berarti paket aktif tetapi tanggal hari ini di luar masa berlakunya.
  final bool isActive;
  final bool isEffective;

  factory MaintenancePackage.fromJson(Map<String, dynamic> json) =>
      MaintenancePackage(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        vehicleModel: json['vehicle_model']?.toString(),
        kmInterval: (json['km_interval'] as num?)?.toInt() ?? 0,
        partsCost: (json['parts_cost'] as num?)?.toInt() ?? 0,
        laborCost: (json['labor_cost'] as num?)?.toInt() ?? 0,
        totalCost: (json['total_cost'] as num?)?.toInt() ?? 0,
        includes: (json['includes'] as List<dynamic>? ?? const [])
            .map((value) => value.toString())
            .toList(growable: false),
        durationMinMinutes:
            (json['duration_min_minutes'] as num?)?.toInt() ?? 0,
        durationMaxMinutes:
            (json['duration_max_minutes'] as num?)?.toInt() ?? 0,
        disclaimer: json['disclaimer']?.toString(),
        isActive: json['is_active'] as bool? ?? true,
        isEffective: json['is_effective'] as bool? ?? true,
      );
}

class MaintenanceEstimate {
  const MaintenanceEstimate({
    required this.packages,
    this.recommended,
    this.vehicleModel,
    this.mileage,
    this.availableModels = const [],
  });

  final MaintenancePackage? recommended;
  final List<MaintenancePackage> packages;
  final String? vehicleModel;
  final int? mileage;

  /// Model yang punya paket khusus, untuk saran isian model kendaraan.
  final List<String> availableModels;

  bool get hasPackages => packages.isNotEmpty || recommended != null;

  factory MaintenanceEstimate.fromJson(Map<String, dynamic> json) =>
      MaintenanceEstimate(
        vehicleModel: json['vehicle_model']?.toString(),
        mileage: (json['mileage'] as num?)?.toInt(),
        recommended: json['recommended'] is Map<String, dynamic>
            ? MaintenancePackage.fromJson(
                json['recommended'] as Map<String, dynamic>,
              )
            : null,
        packages: (json['packages'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MaintenancePackage.fromJson)
            .toList(growable: false),
        availableModels:
            (json['available_models'] as List<dynamic>? ?? const [])
                .map((value) => value.toString())
                .where((value) => value.trim().isNotEmpty)
                .toList(growable: false),
      );
}

/// Isian form admin paket servis. Nama kosong membuat server memakai nama
/// baku "Servis Berkala … km"; model kosong berarti berlaku untuk semua model.
class ServicePackageInput {
  const ServicePackageInput({
    required this.kmInterval,
    required this.laborCost,
    required this.partsCost,
    required this.isActive,
    this.vehicleModel = '',
    this.name = '',
    this.includes = const [],
  });

  final String vehicleModel;
  final int kmInterval;
  final int laborCost;
  final int partsCost;
  final String name;
  final List<String> includes;
  final bool isActive;

  Map<String, Object?> toJson() {
    final model = vehicleModel.trim();
    final packageName = name.trim();
    return {
      'vehicle_model': model.isEmpty ? null : model,
      'km_interval': kmInterval,
      'labor_cost': laborCost,
      'parts_cost': partsCost,
      'name': packageName.isEmpty ? null : packageName,
      'includes': [
        for (final item in includes)
          if (item.trim().isNotEmpty) item.trim(),
      ],
      'is_active': isActive,
    };
  }
}
