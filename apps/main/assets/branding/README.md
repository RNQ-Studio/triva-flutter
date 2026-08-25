# Aset merek TRIVA

Sumber autentik merek TRIVA:

```text
triva-docs/referensi/DKD - Auto2000 Kertajaya (TRIVA).pptx
ppt/media/image13.png
```

Turunan yang dipakai aplikasi:

- `packages/features_shared/assets/logo.png`: logo utama dengan tagline
  `Trade-In Vehicle Appraisal`.
- `triva_mark.png`: mark tanpa tagline untuk komposisi ikon.
- `triva_app_icon.png`: ikon legacy/iOS 1024 x 1024.
- `triva_app_icon_foreground.png`: foreground aman untuk adaptive icon Android.

Aset dipotong dari media transparan asli, tanpa menggambar ulang bentuk,
tipografi, atau warna. Background ikon memakai `#F6F8FA` agar tetap terbaca
pada launcher terang dan gelap.

## Logo mitra

Dipakai beranda melalui `PartnerBrand` di
`apps/main/lib/branding/partner_brands.dart`:

- `auto2000.png`: operator servis berkala dan Body & Paint.
- `otoxpert.png`: jaringan perawatan kendaraan non-Toyota. Dirender dari
  vektor resmi `https://otoxpert.co.id/front/assets/images/logo-otoxpert.svg`.
- `acc.png`: mitra pembiayaan pada baris simulasi kredit.
- `taf.png`: mitra pembiayaan pada strip mitra dan, berdampingan dengan
  `acc.png`, pada baris simulasi kredit — programnya memang datang dari kedua
  mitra, jadi barisnya memakai `PartnerLogoPlate.secondaryBrand`.
- `olx.png`: sumber pembanding harga pada hero appraisal.

Semua lockup mitra hanya dipangkas margin kosongnya dan diskalakan agar sisi
panjang maksimum 512 px. Bentuk, tipografi, dan warna aslinya tidak diubah, dan
tidak boleh diwarnai ulang mengikuti palet monokrom TRIVA. Karena itu logo
mitra selalu dialasi permukaan putih (`PartnerLogoPlate`) agar terbaca sama
pada tema terang maupun gelap.
