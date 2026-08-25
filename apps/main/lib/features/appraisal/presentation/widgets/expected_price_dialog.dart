import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Batas bawah yang sama dengan validasi backend, supaya salah ketik tertahan
/// sebelum request dikirim.
const int expectedPriceMinimum = 1000000;

/// Menanyakan harga harapan pelanggan begitu dia menyatakan harga appraisal
/// belum cocok. Notulensi 19 Agustus 2026 meminta angka ini diambil saat itu
/// juga supaya penolakan berubah menjadi lead yang bisa ditindaklanjuti sales.
Future<int?> showExpectedPriceDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) => const _ExpectedPriceDialog(),
  );
}

class _ExpectedPriceDialog extends StatefulWidget {
  const _ExpectedPriceDialog();

  @override
  State<_ExpectedPriceDialog> createState() => _ExpectedPriceDialogState();
}

class _ExpectedPriceDialogState extends State<_ExpectedPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _parse(String? raw) {
    final value = rupiahValueOf(raw ?? '');

    return value == 0 ? null : value;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.expectedPriceTitle),
      // Layar kecil dengan keyboard terbuka menyisakan ruang sempit; pesan
      // validasi yang muncul tidak boleh membuat dialog meluap.
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.expectedPriceDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.expectedPriceLabel,
                  prefixText: 'Rp ',
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final parsed = _parse(value);
                  if (parsed == null || parsed < expectedPriceMinimum) {
                    return l10n.expectedPriceInvalid;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.expectedPriceSubmit),
        ),
      ],
    );
  }
}
