import 'package:features_shared/features_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses nested province and city master response', () {
    final province = RegionOptionModel.provinceFromJson({
      'id': 35,
      'code': '35',
      'name': 'JAWA TIMUR',
      'cities': [
        {
          'id': '3578',
          'code': '3578',
          'name': 'KOTA SURABAYA',
        },
      ],
    });

    expect(province.id, 35);
    expect(province.name, 'JAWA TIMUR');
    expect(province.cities, hasLength(1));
    expect(province.cities.single.id, 3578);
    expect(province.cities.single.name, 'KOTA SURABAYA');
  });
}
