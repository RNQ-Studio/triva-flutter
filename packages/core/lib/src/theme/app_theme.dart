import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.brandNavy,
          onPrimary: AppColors.surfaceLight,
          primaryContainer: AppColors.brandNavyLight,
          onPrimaryContainer: AppColors.brandNavyDark,
          secondary: AppColors.brandTeal,
          onSecondary: AppColors.surfaceLight,
          secondaryContainer: AppColors.brandTealLight,
          onSecondaryContainer: AppColors.brandNavyDark,
          error: AppColors.brandRed,
          onError: AppColors.surfaceLight,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.inkLight,
          onSurfaceVariant: AppColors.inkMutedLight,
          outline: AppColors.outlineLight,
          outlineVariant: AppColors.brandNavyLight,
          surfaceContainerLow: AppColors.canvasLight,
          surfaceContainer: AppColors.surfaceMutedLight,
          surfaceContainerHighest: AppColors.brandNavyLight,
        ),
        scaffoldBackgroundColor: AppColors.canvasLight,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brandTealLight,
          onPrimary: AppColors.brandNavyDark,
          primaryContainer: AppColors.brandNavy,
          onPrimaryContainer: AppColors.inkDark,
          secondary: AppColors.brandTealLight,
          onSecondary: AppColors.brandNavyDark,
          secondaryContainer: AppColors.brandTeal,
          onSecondaryContainer: AppColors.surfaceLight,
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.inkDark,
          onSurfaceVariant: AppColors.inkMutedDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.outlineDark,
          surfaceContainerLow: AppColors.canvasDark,
          surfaceContainer: AppColors.surfaceMutedDark,
          surfaceContainerHighest: AppColors.surfaceMutedDark,
        ),
        scaffoldBackgroundColor: AppColors.canvasDark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: _textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.small,
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.small,
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.large,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: _textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
        ),
      ),
      extensions: [
        brightness == Brightness.light
            ? AppServiceColors.light
            : AppServiceColors.dark,
      ],
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelSmall: AppTextStyles.labelSmall,
  );
}
