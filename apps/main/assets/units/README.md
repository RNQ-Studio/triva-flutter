# Foto unit rekomendasi

Foto bawaan untuk kartu "Mobil yang cocok untuk Anda" di hasil appraisal
(revisi 13 Oktober 2026). Sumbernya folder `triva-docs/gambar-mobil` yang
dikirim cabang; nama berkas mengikuti `credit_programs.unit_key`.

| Berkas | Sumber | Unit |
|---|---|---|
| `raize.jpg` | `Raize.jpeg` | `raize` |
| `veloz_hybrid.jpg` | `Veloz Hybrid.jpeg` | `veloz_hybrid` |
| `zenix_hybrid.jpg` | `Innova Zenix.jpeg` | `zenix_hybrid` |
| `innova_reborn.jpg` | `Innova.jpeg` | `innova_reborn` |
| `agya.jpg` | `Agya.jpeg` | disiapkan bila unit Agya ditambahkan |

Gambar dari panel admin (`image_url` program kredit) tetap didahulukan;
foto ini hanya dipakai bila program belum punya gambar atau gambarnya gagal
dimuat. Pemetaannya ada di
`lib/features/appraisal/domain/recommended_unit_photos.dart`.
