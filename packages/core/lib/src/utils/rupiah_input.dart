import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Menampilkan angka rupiah dengan pemisah ribuan sambil diketik.
///
/// Notulensi 19 Agustus 2026 meminta menu simulasi kredit disiapkan dengan
/// rapi; nominal berdigit sembilan tanpa pemisah adalah bagian yang paling
/// sulit dibaca dan paling mudah salah ketik.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = digitsOnly(newValue.text);
    if (digits.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    final formatted = formatRupiahDigits(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Membuang seluruh karakter selain angka, termasuk pemisah ribuan.
String digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

/// Membaca nominal dari teks yang sudah berpemisah ribuan.
int rupiahValueOf(String value) {
  final digits = digitsOnly(value);
  if (digits.isEmpty) return 0;

  return int.tryParse(digits) ?? 0;
}

/// Menyusun teks berpemisah ribuan dari nominal.
String formatRupiahAmount(int amount) =>
    NumberFormat.decimalPattern('id_ID').format(amount);

String formatRupiahDigits(String digits) =>
    formatRupiahAmount(int.parse(digits));
