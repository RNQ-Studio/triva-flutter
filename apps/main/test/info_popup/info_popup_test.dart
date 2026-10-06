import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/info_popup/data/info_popup_repository.dart';
import 'package:triva_app/features/info_popup/domain/info_popup_models.dart';
import 'package:triva_app/features/info_popup/presentation/info_popup_controller.dart';

class _MemoryStorage implements StorageService {
  final values = <String, String>{};

  @override
  Future<void> init() async {}

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}

class _MockDio extends Mock implements Dio {}

InfoPopup _popup(
  String id, {
  int order = 0,
  int hours = 24,
  String? updatedAt = '2026-10-06T01:00:00.000Z',
}) =>
    InfoPopup.fromJson({
      'id': id,
      'title': 'Popup $id',
      'image_url': 'https://example.test/$id.jpg',
      'sort_order': order,
      'interval_hours': hours,
      'updated_at': updatedAt,
    });

void main() {
  group('InfoPopup', () {
    test('button needs both a label and a link', () {
      final withButton = InfoPopup.fromJson({
        'id': 'a',
        'title': 'Promo',
        'image_url': 'https://example.test/a.jpg',
        'button_label': 'Lihat promo',
        'button_url': 'https://auto2000.co.id/promo',
        'sort_order': 2,
        'interval_hours': 6,
      });
      final labelOnly = InfoPopup.fromJson({
        'id': 'b',
        'title': 'Info',
        'image_url': 'https://example.test/b.jpg',
        'button_label': 'Lihat',
        'button_url': '',
      });

      expect(withButton.hasButton, isTrue);
      expect(withButton.sortOrder, 2);
      expect(withButton.intervalHours, 6);
      expect(labelOnly.hasButton, isFalse);
      expect(labelOnly.buttonUrl, isNull);
      expect(labelOnly.intervalHours, 24);
    });
  });

  group('isInfoPopupDue', () {
    final now = DateTime(2026, 10, 6, 12);

    test('a popup that was never shown is due', () {
      expect(isInfoPopupDue(_popup('a'), null, now), isTrue);
    });

    test('waits for the configured number of hours', () {
      final popup = _popup('a', hours: 6);
      final version = popup.updatedAt!.toIso8601String();

      expect(
        isInfoPopupDue(
          popup,
          InfoPopupShownRecord(
            shownAt: now.subtract(const Duration(hours: 5, minutes: 59)),
            version: version,
          ),
          now,
        ),
        isFalse,
      );
      expect(
        isInfoPopupDue(
          popup,
          InfoPopupShownRecord(
            shownAt: now.subtract(const Duration(hours: 6)),
            version: version,
          ),
          now,
        ),
        isTrue,
      );
    });

    test('an edited popup is shown again before its interval ends', () {
      final popup = _popup('a', updatedAt: '2026-10-06T05:00:00.000Z');

      expect(
        isInfoPopupDue(
          popup,
          InfoPopupShownRecord(
            shownAt: now.subtract(const Duration(minutes: 5)),
            version: '2026-10-06T01:00:00.000Z',
          ),
          now,
        ),
        isTrue,
      );
    });
  });

  group('InfoPopupSchedule', () {
    test('remembers shown popups per device and orders due slides', () async {
      final storage = _MemoryStorage();
      final schedule = InfoPopupSchedule(storage);
      final first = _popup('first', order: 1, hours: 2);
      final second = _popup('second', order: 2, hours: 48);
      final shownAt = DateTime(2026, 10, 6, 8);

      expect(
        (await schedule.due([second, first], now: shownAt))
            .map((popup) => popup.id),
        ['first', 'second'],
      );

      await schedule.markShown([first, second], now: shownAt);

      expect(
        await schedule.due(
          [first, second],
          now: shownAt.add(const Duration(hours: 1)),
        ),
        isEmpty,
      );
      expect(
        (await schedule.due(
          [first, second],
          now: shownAt.add(const Duration(hours: 3)),
        ))
            .map((popup) => popup.id),
        ['first'],
      );
    });

    test('a corrupted record is treated as never shown', () async {
      final storage = _MemoryStorage()
        ..values['info_popup_last_shown_v1'] = '{not json';
      final schedule = InfoPopupSchedule(storage);

      expect(await schedule.due([_popup('a')]), hasLength(1));
    });
  });

  group('InfoPopupRepository', () {
    test('sends multipart fields and clears the button with empty strings',
        () async {
      final dio = _MockDio();
      final repository = InfoPopupRepository(dio: dio);
      FormData? sent;
      when(
        () => dio.post<dynamic>('v1/admin/info-popups/p1',
            data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        sent = invocation.namedArguments[#data] as FormData;
        return Response<dynamic>(
          requestOptions: RequestOptions(path: 'v1/admin/info-popups/p1'),
          data: {
            'data': {
              'id': 'p1',
              'title': 'Promo Oktober',
              'image_url': 'https://example.test/p1.jpg',
              'sort_order': 3,
              'interval_hours': 12,
              'is_active': false,
              'is_running': false,
            },
          },
        );
      });

      final updated = await repository.update(
        'p1',
        InfoPopupInput(
          title: ' Promo Oktober ',
          sortOrder: 3,
          intervalHours: 12,
          isActive: false,
          startsOn: DateTime(2026, 10, 1),
        ),
      );

      final fields = {for (final field in sent!.fields) field.key: field.value};
      expect(fields['title'], 'Promo Oktober');
      expect(fields['button_label'], '');
      expect(fields['button_url'], '');
      expect(fields['sort_order'], '3');
      expect(fields['interval_hours'], '12');
      expect(fields['is_active'], '0');
      expect(fields['starts_on'], '2026-10-01');
      expect(fields['ends_on'], '');
      expect(sent!.files, isEmpty);
      expect(updated.isActive, isFalse);
      expect(updated.isRunning, isFalse);
    });
  });
}
