import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String brandFont = 'BricolageGrotesque';
  static const String contentFont = 'CabinetGrotesk';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: contentFont,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkPrimary,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: contentFont,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.12,
          letterSpacing: -0.5,
          color: AppColors.inkPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: brandFont,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.inkPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: contentFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.inkPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: contentFont,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.inkSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: contentFont,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
