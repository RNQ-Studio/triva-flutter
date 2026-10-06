/// Membaca objek `data` dari amplop `ApiResponse`.
Map<String, dynamic> dataMap(Object? payload) {
  if (payload is Map && payload['data'] is Map) {
    return Map<String, dynamic>.from(payload['data'] as Map);
  }
  throw const FormatException('Respons server tidak dikenali.');
}

/// Tanggal tanpa jam (`yyyy-MM-dd`) sesuai validasi `date` Laravel; string
/// kosong dipakai untuk mengosongkan tanggal.
String apiDate(DateTime? date) {
  if (date == null) return '';
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
