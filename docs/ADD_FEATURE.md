# Menambah fitur TRIVA

1. Baca requirement flow di `../../triva-docs/requirement/`.
2. Verifikasi route dan payload Laravel yang menjadi sumber kebenaran.
3. Letakkan fitur khusus produk di `apps/main/lib/features/<fitur>`.
4. Letakkan fitur lintas aplikasi di `packages/features_shared/lib/src/<fitur>`.
5. Pertahankan layer `data`, `domain`, dan `presentation`.
6. Tambahkan test parsing/repository/provider/widget sesuai perilaku.
7. Jalankan l10n, codegen, format, analyze, test, dan build.
