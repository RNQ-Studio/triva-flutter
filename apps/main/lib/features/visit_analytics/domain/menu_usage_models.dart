import 'visit_analytics_models.dart';

/// Menu pelanggan yang pemakaiannya dilaporkan ke backend.
///
/// Nilainya harus sama dengan `MenuKey` di sisi server supaya label pada
/// dashboard admin terbaca, tetapi server tetap menerima kunci yang belum
/// dikenalnya sehingga menu baru boleh ditambahkan lebih dulu di sini.
enum MenuKey {
  appraisal('appraisal'),
  toyotaService('toyota_service'),
  otoxpert('otoxpert'),
  credit('credit'),
  bodyPaint('body_paint'),
  vehicleBenefit('vehicle_benefit'),
  maintenanceEstimate('maintenance_estimate'),
  promotion('promotion'),
  notification('notification'),
  profile('profile');

  const MenuKey(this.apiValue);

  final String apiValue;
}

class MenuUsageEntry {
  const MenuUsageEntry({
    required this.key,
    required this.label,
    required this.total,
    required this.share,
  });

  factory MenuUsageEntry.fromJson(Map<String, dynamic> json) => MenuUsageEntry(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        total: (json['total'] as num?)?.toInt() ?? 0,
        share: (json['share'] as num?)?.toDouble() ?? 0,
      );

  final String key;
  final String label;
  final int total;
  final double share;
}

class MenuUsagePeriod {
  const MenuUsagePeriod({
    required this.total,
    required this.distinctMenus,
    required this.menus,
    this.startsAt,
    this.endsAt,
  });

  factory MenuUsagePeriod.fromJson(Map<String, dynamic> json) =>
      MenuUsagePeriod(
        total: (json['total'] as num?)?.toInt() ?? 0,
        distinctMenus: (json['distinct_menus'] as num?)?.toInt() ?? 0,
        startsAt: _parseDate(json['starts_at']),
        endsAt: _parseDate(json['ends_at']),
        menus: (json['menus'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MenuUsageEntry.fromJson)
            .toList(growable: false),
      );

  final int total;
  final int distinctMenus;
  final List<MenuUsageEntry> menus;
  final DateTime? startsAt;
  final DateTime? endsAt;
}

class MenuUsageSnapshot {
  const MenuUsageSnapshot({
    required this.timezone,
    required this.generatedAt,
    required this.periods,
    this.trackingStartedAt,
  });

  factory MenuUsageSnapshot.fromJson(Map<String, dynamic> json) {
    final periodData = json['periods'];
    if (periodData is! Map<String, dynamic>) {
      throw const FormatException('periods must be an object');
    }

    return MenuUsageSnapshot(
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      generatedAt: _parseDate(json['generated_at']) ?? DateTime.now(),
      trackingStartedAt: _parseDate(json['tracking_started_at']),
      periods: {
        for (final period in VisitPeriod.values)
          period: MenuUsagePeriod.fromJson(
            periodData[period.apiValue] as Map<String, dynamic>? ?? const {},
          ),
      },
    );
  }

  final String timezone;
  final DateTime generatedAt;
  final DateTime? trackingStartedAt;
  final Map<VisitPeriod, MenuUsagePeriod> periods;

  MenuUsagePeriod forPeriod(VisitPeriod period) =>
      periods[period] ??
      const MenuUsagePeriod(total: 0, distinctMenus: 0, menus: []);

  bool get isEmpty => forPeriod(VisitPeriod.overall).total == 0;
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
