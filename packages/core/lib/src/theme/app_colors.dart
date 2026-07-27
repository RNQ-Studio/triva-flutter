import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color brandNavy = Color(0xFF062A66);
  static const Color brandNavyDark = Color(0xFF031A42);
  static const Color brandNavyLight = Color(0xFFDCE8F8);
  static const Color brandTeal = Color(0xFF008078);
  static const Color brandTealLight = Color(0xFFBDECE8);
  static const Color brandRed = Color(0xFFD80C18);

  static const Color appraisalBlue = Color(0xFF176BDA);
  static const Color appraisalBlueSoft = Color(0xFFDCEBFF);
  static const Color serviceOrange = Color(0xFFE46F16);
  static const Color serviceOrangeSoft = Color(0xFFFFE7D2);
  static const Color serviceViolet = Color(0xFF7754D6);
  static const Color serviceVioletSoft = Color(0xFFECE5FF);
  static const Color serviceGreen = Color(0xFF16865F);
  static const Color serviceGreenSoft = Color(0xFFD8F4E9);
  static const Color serviceRose = Color(0xFFC9406E);
  static const Color serviceRoseSoft = Color(0xFFFFDFE9);

  static const Color canvasLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFEFEFF);
  static const Color surfaceMutedLight = Color(0xFFF0F4F8);
  static const Color inkLight = Color(0xFF172033);
  static const Color inkMutedLight = Color(0xFF4D5B70);
  static const Color outlineLight = Color(0xFFC5CEDA);

  static const Color canvasDark = Color(0xFF0D1420);
  static const Color surfaceDark = Color(0xFF141D2B);
  static const Color surfaceMutedDark = Color(0xFF1C2838);
  static const Color inkDark = Color(0xFFE8EEF7);
  static const Color inkMutedDark = Color(0xFFB6C2D2);
  static const Color outlineDark = Color(0xFF425167);
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
    booking: AppColors.serviceOrange,
    onBooking: AppColors.surfaceLight,
    bookingContainer: AppColors.serviceOrangeSoft,
    onBookingContainer: AppColors.inkLight,
    confirmed: AppColors.brandTeal,
    confirmedContainer: AppColors.brandTealLight,
    onConfirmedContainer: AppColors.brandNavyDark,
  );

  static const dark = AppServiceColors(
    booking: Color(0xFFFFB77A),
    onBooking: Color(0xFF4F2500),
    bookingContainer: Color(0xFF512400),
    onBookingContainer: Color(0xFFFFDCC2),
    confirmed: Color(0xFF72D8CE),
    confirmedContainer: Color(0xFF00504B),
    onConfirmedContainer: Color(0xFF9CF1E7),
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
