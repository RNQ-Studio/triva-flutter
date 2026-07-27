import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triva_app/features/credit/data/credit_repository.dart';
import 'package:triva_app/features/credit/domain/credit_models.dart';

class _MockDio extends Mock implements Dio {}

class _MemoryStorage implements StorageService {
  final values = <String, String>{};

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  late _MockDio dio;
  late CreditRepository repository;

  setUp(() {
    dio = _MockDio();
    repository = CreditRepository(
      dio: dio,
      storage: _MemoryStorage(),
      userId: 'customer-1',
    );
  });

  test('program pagination collects all pages', () async {
    final pages = <int>[];
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final query =
          invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
      final page = query['page'] as int;
      pages.add(page);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/credit/programs'),
        data: {
          'data': [_programJson('program-$page')],
          'meta': {
            'pagination': {'current_page': page, 'last_page': 2},
          },
        },
      );
    });

    final programs = await repository.listPrograms();

    expect(programs.map((item) => item.id), ['program-1', 'program-2']);
    expect(pages, [1, 2]);
  });

  test('calculate and save send server-authoritative fields and idempotency',
      () async {
    Map<String, dynamic>? calculatePayload;
    Map<String, dynamic>? savePayload;
    Options? saveOptions;
    when(
      () => dio.post<dynamic>(
        'v1/credit/simulations/calculate',
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      calculatePayload =
          invocation.namedArguments[#data] as Map<String, dynamic>;
      return Response<dynamic>(
        requestOptions: RequestOptions(
          path: 'v1/credit/simulations/calculate',
        ),
        data: {'data': _calculationJson()},
      );
    });
    when(
      () => dio.post<dynamic>(
        'v1/credit/simulations',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      savePayload = invocation.namedArguments[#data] as Map<String, dynamic>;
      saveOptions = invocation.namedArguments[#options] as Options;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: 'v1/credit/simulations'),
        data: {'data': _simulationJson()},
      );
    });
    const draft = CreditSimulationDraft(
      programId: 'program-1',
      otrPrice: 320000000,
      cashDownPayment: 70000000,
      manualTradeInValue: 0,
      tenorMonths: 60,
      idempotencyKey: 'idem-1',
      comparisonGroupId: 'group-1',
      campaignSource: 'sales_share',
    );

    await repository.calculate(draft);
    await repository.save(draft);

    expect(calculatePayload?['program_id'], 'program-1');
    expect(calculatePayload?['otr_price'], 320000000);
    expect(savePayload?['comparison_group_id'], 'group-1');
    expect(savePayload?['campaign_source'], 'sales_share');
    expect(saveOptions?.headers?['Idempotency-Key'], 'idem-1');
  });

  test('draft storage is isolated by signed-in customer', () async {
    final storage = _MemoryStorage();
    final first = CreditRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-a',
    );
    final second = CreditRepository(
      dio: dio,
      storage: storage,
      userId: 'customer-b',
    );
    await first.saveDraft(
      const CreditSimulationDraft(
        programId: 'program-a',
        otrPrice: 320000000,
        tenorMonths: 60,
      ),
    );

    expect((await first.loadDraft()).programId, 'program-a');
    expect((await second.loadDraft()).programId, isNull);
  });
}

Map<String, dynamic> _programJson(String id) => {
      'id': id,
      'program_code': 'TAF-001',
      'version': 1,
      'partner_name': 'TAF',
      'program_name': 'Program Flat',
      'city': 'Surabaya',
      'vehicle': {
        'model': 'Avanza',
        'variant': '1.5 G CVT',
        'model_year': 2026,
        'otr_price': 320000000,
        'approved_discount': 10000000,
      },
      'minimum_dp_amount': 64000000,
      'maximum_dp_amount': 256000000,
      'tenor_options': [
        {
          'tenor_months': 60,
          'annual_flat_rate_basis_points': 525,
          'administration_fee': 2500000,
          'provision_fee': 1000000,
          'upfront_insurance': 7500000,
          'other_upfront_costs': 500000,
        },
      ],
      'formula_version': 'flat-v1',
      'effective_from': '2026-07-01',
      'effective_to': '2026-08-31',
      'source_reference': 'Dokumen program.',
      'disclaimer': 'Estimasi.',
    };

Map<String, dynamic> _calculationJson() => {
      'program': {
        'id': 'program-1',
        'program_name': 'Program Flat',
        'partner_name': 'TAF',
        'source_reference': 'Dokumen program.',
      },
      'inputs': {
        'otr_price': 320000000,
        'cash_down_payment': 70000000,
        'trade_in_value': 0,
        'use_trade_in_as_dp': false,
        'old_vehicle_payoff': 0,
        'tenor_months': 60,
      },
      'calculation': {
        'trade_in_equity': 0,
        'approved_discount': 10000000,
        'total_down_payment': 80000000,
        'principal': 240000000,
        'annual_flat_rate_basis_points': 525,
        'total_flat_interest': 63000000,
        'monthly_installment': 5050000,
        'administration_fee': 2500000,
        'provision_fee': 1000000,
        'upfront_insurance': 7500000,
        'other_upfront_costs': 500000,
        'initial_payment': 81500000,
        'total_payment': 384500000,
      },
      'formula_version': 'flat-v1',
      'valid_until': '2026-08-31',
      'warnings': <String>[],
      'disclaimer': 'Estimasi.',
    };

Map<String, dynamic> _simulationJson() => {
      'id': 'simulation-1',
      'reference_no': 'SK-001',
      'status': 'saved',
      'status_label': 'Simulasi tersimpan',
      'program': _calculationJson()['program'],
      'inputs': _calculationJson()['inputs'],
      'calculation': _calculationJson()['calculation'],
      'formula_version': 'flat-v1',
      'valid_until': '2026-08-31',
      'is_program_expired': false,
      'disclaimer': 'Estimasi.',
      'saved_at': '2026-07-27T02:00:00Z',
    };
