import 'package:flutter/material.dart';
import 'app_design_system.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.black,
        surface: AppColors.surface,
        onSurface: AppColors.grey900,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.surface,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        centerTitle: false,
        toolbarHeight: 56,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.grey900,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.grey900,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.grey900,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.grey900,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.grey900,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.grey900,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.grey900),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.grey800,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.grey700),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.grey900),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.grey800),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.grey700),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.grey900),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.grey800,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.grey700),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.grey700,
        ),
        errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.grey900,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.black,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.black,
        tertiary: AppColors.tertiaryDark,
        onTertiary: AppColors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.grey50,
        error: AppColors.errorLight,
        onError: AppColors.black,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppColors.white,
        centerTitle: false,
        toolbarHeight: 56,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.grey50,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.grey50,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.grey50,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.grey50,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.grey100,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.grey200,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.grey50),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.grey100,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.grey300),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.grey50),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.grey200),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.grey50),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.grey200,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.grey400),
      ),
    );
  }
}
