import 'package:flutter/material.dart';

/// TRIVA memakai satu keluarga warna: kanvas putih dengan satu aksen biru.
///
/// Seluruh permukaan dekoratif mengambil langkah dari ramp di bawah ini.
/// Tidak ada hue kedua selain merah semantik untuk error, sehingga identitas
/// per layanan dibedakan oleh logo mitra dan ikon, bukan oleh warna.
abstract final class AppColors {
  static const Color blue900 = Color(0xFF041C4A);
  static const Color blue800 = Color(0xFF062A66);
  static const Color blue700 = Color(0xFF0B3D8F);
  static const Color blue600 = Color(0xFF1153B5);
  static const Color blue500 = Color(0xFF176BDA);
  static const Color blue400 = Color(0xFF4B8FE6);
  static const Color blue300 = Color(0xFF85B4F0);
  static const Color blue200 = Color(0xFFC0D8F7);
  static const Color blue100 = Color(0xFFDCE8F8);
  static const Color blue50 = Color(0xFFF0F5FD);

  static const Color brandNavy = blue800;
  static const Color brandNavyDark = blue900;
  static const Color brandNavyLight = blue100;

  /// Aksen tunggal untuk glyph, chip, dan penanda aktif.
  static const Color accent = blue600;
  static const Color accentStrong = blue800;
  static const Color accentBright = blue500;
  static const Color accentSoft = blue50;
  static const Color accentMuted = blue100;

  /// Aksen versi tema gelap; kontras dibalik agar tetap satu keluarga.
  static const Color accentDark = blue300;
  static const Color accentStrongDark = blue200;
  static const Color accentSoftDark = Color(0xFF12233B);
  static const Color accentMutedDark = Color(0xFF1B3355);

  /// Merah hanya dipakai sebagai sinyal error; bukan bagian dari palet dekoratif.
  static const Color brandRed = Color(0xFFD80C18);

  static const Color canvasLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMutedLight = Color(0xFFF2F6FB);
  static const Color inkLight = Color(0xFF111C2E);
  static const Color inkMutedLight = Color(0xFF54627A);
  static const Color outlineLight = Color(0xFFC8D5E6);
  static const Color hairlineLight = Color(0xFFE4ECF7);

  static const Color canvasDark = Color(0xFF0B121D);
  static const Color surfaceDark = Color(0xFF121B29);
  static const Color surfaceMutedDark = Color(0xFF1A2537);
  static const Color inkDark = Color(0xFFE9EFF8);
  static const Color inkMutedDark = Color(0xFFB2C0D4);
  static const Color outlineDark = Color(0xFF3B4B64);
  static const Color hairlineDark = Color(0x99253246);
}

@immutable
class AppServiceColors extends ThemeExtension<AppServiceColors> {
  const AppServiceColors({
    required this.booking,
    required this.onBooking,
    required this.bookingContainer,
    required this.onBookingContainer,
    required this.confirmed,
    required this.confirmedContainer,
    required this.onConfirmedContainer,
  });

  final Color booking;
  final Color onBooking;
  final Color bookingContainer;
  final Color onBookingContainer;
  final Color confirmed;
  final Color confirmedContainer;
  final Color onConfirmedContainer;

  static const light = AppServiceColors(
    booking: AppColors.accent,
    onBooking: AppColors.surfaceLight,
    bookingContainer: AppColors.accentSoft,
    onBookingContainer: AppColors.inkLight,
    confirmed: AppColors.accentStrong,
    confirmedContainer: AppColors.accentMuted,
    onConfirmedContainer: AppColors.blue900,
  );

  static const dark = AppServiceColors(
    booking: AppColors.accentDark,
    onBooking: AppColors.blue900,
    bookingContainer: AppColors.accentSoftDark,
    onBookingContainer: AppColors.inkDark,
    confirmed: AppColors.accentStrongDark,
    confirmedContainer: AppColors.accentMutedDark,
    onConfirmedContainer: AppColors.blue100,
  );

  @override
  AppServiceColors copyWith({
    Color? booking,
    Color? onBooking,
    Color? bookingContainer,
    Color? onBookingContainer,
    Color? confirmed,
    Color? confirmedContainer,
    Color? onConfirmedContainer,
  }) =>
      AppServiceColors(
        booking: booking ?? this.booking,
        onBooking: onBooking ?? this.onBooking,
        bookingContainer: bookingContainer ?? this.bookingContainer,
        onBookingContainer: onBookingContainer ?? this.onBookingContainer,
        confirmed: confirmed ?? this.confirmed,
        confirmedContainer: confirmedContainer ?? this.confirmedContainer,
        onConfirmedContainer: onConfirmedContainer ?? this.onConfirmedContainer,
      );

  @override
  AppServiceColors lerp(
    covariant ThemeExtension<AppServiceColors>? other,
    double t,
  ) {
    if (other is! AppServiceColors) return this;
    return AppServiceColors(
      booking: Color.lerp(booking, other.booking, t)!,
      onBooking: Color.lerp(onBooking, other.onBooking, t)!,
      bookingContainer:
          Color.lerp(bookingContainer, other.bookingContainer, t)!,
      onBookingContainer:
          Color.lerp(onBookingContainer, other.onBookingContainer, t)!,
      confirmed: Color.lerp(confirmed, other.confirmed, t)!,
      confirmedContainer:
          Color.lerp(confirmedContainer, other.confirmedContainer, t)!,
      onConfirmedContainer:
          Color.lerp(onConfirmedContainer, other.onConfirmedContainer, t)!,
    );
  }
}
