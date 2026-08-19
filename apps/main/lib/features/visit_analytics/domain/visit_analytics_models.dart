enum VisitSource {
  android('android'),
  web('web'),
  landingPage('landing_page');

  const VisitSource(this.apiValue);

  final String apiValue;

  static VisitSource fromApiValue(String value) => values.firstWhere(
        (source) => source.apiValue == value,
        orElse: () => throw FormatException('Unknown visit source: $value'),
      );
}

enum VisitPeriod {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  overall('overall');

  const VisitPeriod(this.apiValue);

  final String apiValue;
}

class VisitPeriodStatistics {
  const VisitPeriodStatistics({
    required this.total,
    required this.bySource,
    this.startsAt,
    this.endsAt,
  });

  factory VisitPeriodStatistics.fromJson(Map<String, dynamic> json) {
    final bySource = _requiredMap(json['by_source'], 'by_source');

    return VisitPeriodStatistics(
      total: _requiredInt(json['total'], 'total'),
      startsAt: _optionalDateTime(json['starts_at'], 'starts_at'),
      endsAt: _optionalDateTime(json['ends_at'], 'ends_at'),
      bySource: {
        for (final source in VisitSource.values)
          source: _optionalInt(bySource[source.apiValue]),
      },
    );
  }

  final int total;
  final Map<VisitSource, int> bySource;
  final DateTime? startsAt;
  final DateTime? endsAt;

  int countFor(VisitSource source) => bySource[source] ?? 0;
}

class VisitAnalyticsSnapshot {
  const VisitAnalyticsSnapshot({
    required this.timezone,
    required this.generatedAt,
    required this.periods,
    this.trackingStartedAt,
  });

  factory VisitAnalyticsSnapshot.fromJson(Map<String, dynamic> json) {
    final timezone = json['timezone'];
    if (timezone is! String || timezone.trim().isEmpty) {
      throw const FormatException('timezone must be a non-empty string');
    }
    final periodData = _requiredMap(json['periods'], 'periods');

    return VisitAnalyticsSnapshot(
      timezone: timezone,
      generatedAt: _requiredDateTime(json['generated_at'], 'generated_at'),
      trackingStartedAt: _optionalDateTime(
        json['tracking_started_at'],
        'tracking_started_at',
      ),
      periods: {
        for (final period in VisitPeriod.values)
          period: VisitPeriodStatistics.fromJson(
            _requiredMap(periodData[period.apiValue], period.apiValue),
          ),
      },
    );
  }

  final String timezone;
  final DateTime generatedAt;
  final DateTime? trackingStartedAt;
  final Map<VisitPeriod, VisitPeriodStatistics> periods;

  VisitPeriodStatistics forPeriod(VisitPeriod period) {
    final statistics = periods[period];
    if (statistics == null) {
      throw StateError('Missing statistics for ${period.apiValue}');
    }
    return statistics;
  }

  bool get isEmpty => forPeriod(VisitPeriod.overall).total == 0;
}

Map<String, dynamic> _requiredMap(Object? value, String field) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('$field must be an object');
}

int _requiredInt(Object? value, String field) {
  if (value is num) return value.toInt();
  throw FormatException('$field must be a number');
}

int _optionalInt(Object? value) => value is num ? value.toInt() : 0;

DateTime _requiredDateTime(Object? value, String field) {
  final parsed = _optionalDateTime(value, field);
  if (parsed == null) throw FormatException('$field must be an ISO timestamp');
  return parsed;
}

DateTime? _optionalDateTime(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) throw FormatException('$field must be a string');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('$field must be an ISO timestamp');
  return parsed;
}
