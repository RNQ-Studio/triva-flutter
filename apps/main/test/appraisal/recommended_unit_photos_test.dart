import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva_app/features/appraisal/domain/recommended_unit_photos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each recommended unit key points at its own photo', () {
    expect(
      recommendedUnitPhoto(unitKey: 'raize', vehicleModel: 'Raize'),
      'assets/units/raize.jpg',
    );
    expect(
      recommendedUnitPhoto(
        unitKey: 'veloz_hybrid',
        vehicleModel: 'Veloz Hybrid',
      ),
      'assets/units/veloz_hybrid.jpg',
    );
    expect(
      recommendedUnitPhoto(
        unitKey: 'zenix_hybrid',
        vehicleModel: 'Kijang Innova Zenix Hybrid',
      ),
      'assets/units/zenix_hybrid.jpg',
    );
    expect(
      recommendedUnitPhoto(
        unitKey: 'innova_reborn',
        vehicleModel: 'Kijang Innova Reborn',
      ),
      'assets/units/innova_reborn.jpg',
    );
  });

  test('programs without a unit key fall back to the model name', () {
    expect(
      recommendedUnitPhoto(vehicleModel: 'Kijang Innova Zenix'),
      'assets/units/zenix_hybrid.jpg',
    );
    expect(
      recommendedUnitPhoto(vehicleModel: 'Kijang Innova Reborn'),
      'assets/units/innova_reborn.jpg',
    );
    expect(
      recommendedUnitPhoto(vehicleModel: 'Veloz Hybrid'),
      'assets/units/veloz_hybrid.jpg',
    );
    expect(
      recommendedUnitPhoto(vehicleModel: 'New Agya'),
      'assets/units/agya.jpg',
    );
  });

  test('a unit without a matching photo keeps the placeholder', () {
    // Veloz bensin bukan Veloz Hybrid; lebih baik ikon daripada mobil yang
    // salah.
    expect(recommendedUnitPhoto(vehicleModel: 'Veloz'), isNull);
    expect(recommendedUnitPhoto(unitKey: 'rush', vehicleModel: 'Rush'), isNull);
  });

  test('every mapped photo is bundled with the app', () async {
    for (final path in recommendedUnitPhotos.values) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000), reason: path);
    }
  });
}
