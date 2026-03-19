import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color primaryLight = Color(0xFF9C27B0);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFFB2EBF2);

  // Tertiary Colors
  static const Color tertiary = Color(0xFFFFC107);
  static const Color tertiaryDark = Color(0xFFFFA000);

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Error Colors
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFEF5350);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // State Colors
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1F000000);
}

class AppTypography {
  // Display (Large prominent text)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.15,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.1,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );
}

class AppSpacing {
  // 8dp Grid System
  static const double xs = 4; // 0.5 grid
  static const double sm = 8; // 1 grid
  static const double md = 16; // 2 grids
  static const double lg = 24; // 3 grids
  static const double xl = 32; // 4 grids
  static const double xxl = 48; // 6 grids
  static const double xxxl = 64; // 8 grids
}

class AppRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

class AppShadows {
  static const BoxShadow elevation1 = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 1,
    offset: Offset(0, 1),
  );

  static const BoxShadow elevation2 = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 3,
    offset: Offset(0, 3),
  );

  static const BoxShadow elevation3 = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 6,
    offset: Offset(0, 3),
  );

  static const BoxShadow elevation4 = BoxShadow(
    color: Color(0x3D000000),
    blurRadius: 8,
    offset: Offset(0, 5),
  );

  static const BoxShadow elevation5 = BoxShadow(
    color: Color(0x48000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
