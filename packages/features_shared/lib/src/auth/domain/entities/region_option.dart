class CityOption {
  const CityOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;
}

class ProvinceOption {
  const ProvinceOption({
    required this.id,
    required this.code,
    required this.name,
    required this.cities,
  });

  final int id;
  final String code;
  final String name;
  final List<CityOption> cities;
}
