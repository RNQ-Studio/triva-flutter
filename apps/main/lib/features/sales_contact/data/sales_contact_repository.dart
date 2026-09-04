import 'package:dio/dio.dart';

import '../domain/sales_contact_models.dart';

class SalesContactRepository {
  SalesContactRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<SalesDirectory> list() async {
    final response = await _dio.get<dynamic>('v1/sales-contacts');
    final payload = response.data;
    if (payload is! Map || payload['data'] is! List) {
      return const SalesDirectory([]);
    }

    return SalesDirectory(
      (payload['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SalesContact.fromJson)
          .where((contact) => contact.whatsappNumber.isNotEmpty)
          .toList(growable: false),
    );
  }
}
