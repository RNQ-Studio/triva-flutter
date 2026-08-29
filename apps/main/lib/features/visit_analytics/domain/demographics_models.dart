class DemographicsSegment {
  const DemographicsSegment({
    required this.key,
    required this.label,
    required this.total,
    required this.share,
  });

  factory DemographicsSegment.fromJson(Map<String, dynamic> json) =>
      DemographicsSegment(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        total: (json['total'] as num?)?.toInt() ?? 0,
        share: (json['share'] as num?)?.toDouble() ?? 0,
      );

  final String key;
  final String label;
  final int total;
  final double share;

  bool get isUnknown => key == 'unknown';
}

class DemographicsSnapshot {
  const DemographicsSnapshot({
    required this.generatedAt,
    required this.totalUsers,
    required this.completedProfiles,
    required this.completionRate,
    required this.gender,
    required this.ageGroups,
  });

  factory DemographicsSnapshot.fromJson(Map<String, dynamic> json) =>
      DemographicsSnapshot(
        generatedAt:
            DateTime.tryParse(json['generated_at']?.toString() ?? '') ??
                DateTime.now(),
        totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
        completedProfiles: (json['completed_profiles'] as num?)?.toInt() ?? 0,
        completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
        gender: _segments(json['gender']),
        ageGroups: _segments(json['age_groups']),
      );

  final DateTime generatedAt;
  final int totalUsers;
  final int completedProfiles;
  final double completionRate;
  final List<DemographicsSegment> gender;
  final List<DemographicsSegment> ageGroups;

  bool get isEmpty => totalUsers == 0;

  /// Segmen usia terbanyak di luar "belum diisi".
  DemographicsSegment? get dominantAgeGroup {
    DemographicsSegment? best;
    for (final segment in ageGroups) {
      if (segment.isUnknown || segment.total == 0) continue;
      if (best == null || segment.total > best.total) best = segment;
    }
    return best;
  }

  static List<DemographicsSegment> _segments(Object? value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DemographicsSegment.fromJson)
          .toList(growable: false);
}
