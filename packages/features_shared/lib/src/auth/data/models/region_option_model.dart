import '../../domain/entities/region_option.dart';

abstract final class RegionOptionModel {
  static ProvinceOption provinceFromJson(Map<String, dynamic> json) {
    final cities = (json['cities'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(cityFromJson)
        .toList(growable: false);

    return ProvinceOption(
      id: _parseId(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cities: cities,
    );
  }

  static CityOption cityFromJson(Map<String, dynamic> json) {
    return CityOption(
      id: _parseId(json['id']),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  static int _parseId(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
