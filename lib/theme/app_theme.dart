import 'package:flutter/material.dart';

@immutable
class FasalXColors extends ThemeExtension<FasalXColors> {
  const FasalXColors({
    required this.softBackground,
    required this.surface,
    required this.surfaceAlt,
    required this.fieldFill,
    required this.selectedFill,
    required this.border,
    required this.textStrong,
    required this.textMuted,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.bottomNavActive,
    required this.bottomNavInactive,
  });

  final Color softBackground;
  final Color surface;
  final Color surfaceAlt;
  final Color fieldFill;
  final Color selectedFill;
  final Color border;
  final Color textStrong;
  final Color textMuted;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color info;
  final Color infoContainer;
  final Color bottomNavActive;
  final Color bottomNavInactive;

  @override
  FasalXColors copyWith({
    Color? softBackground,
    Color? surface,
    Color? surfaceAlt,
    Color? fieldFill,
    Color? selectedFill,
    Color? border,
    Color? textStrong,
    Color? textMuted,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? info,
    Color? infoContainer,
    Color? bottomNavActive,
    Color? bottomNavInactive,
  }) {
    return FasalXColors(
      softBackground: softBackground ?? this.softBackground,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      fieldFill: fieldFill ?? this.fieldFill,
      selectedFill: selectedFill ?? this.selectedFill,
      border: border ?? this.border,
      textStrong: textStrong ?? this.textStrong,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      bottomNavActive: bottomNavActive ?? this.bottomNavActive,
      bottomNavInactive: bottomNavInactive ?? this.bottomNavInactive,
    );
  }

  @override
  FasalXColors lerp(ThemeExtension<FasalXColors>? other, double t) {
    if (other is! FasalXColors) return this;
    return FasalXColors(
      softBackground: Color.lerp(softBackground, other.softBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      selectedFill: Color.lerp(selectedFill, other.selectedFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      bottomNavActive: Color.lerp(bottomNavActive, other.bottomNavActive, t)!,
      bottomNavInactive: Color.lerp(
        bottomNavInactive,
        other.bottomNavInactive,
        t,
      )!,
    );
  }

  Color get primaryLight => selectedFill;
  Color get onBackground => textStrong;
  Color get onSurface => textMuted;
  Color get textSecondary => textMuted;
  Color get divider => border;
}

extension FasalXTheme on BuildContext {
  FasalXColors get fx => Theme.of(this).extension<FasalXColors>()!;
}

class AppTheme {
  const AppTheme._();

  static const _lightColors = FasalXColors(
    softBackground: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFFFFFFF),
    fieldFill: Color(0xFFF3F4F6),
    selectedFill: Color(0xFFECFDF5),
    border: Color(0xFFF3F4F6),
    textStrong: Color(0xFF1F2937),
    textMuted: Color(0xFF6B7280),
    success: Color(0xFF10B981),
    successContainer: Color(0xFFECFDF5),
    warning: Color(0xFFF97316),
    warningContainer: Color(0xFFFFEDD5),
    danger: Color(0xFFEF4444),
    dangerContainer: Color(0xFFFEE2E2),
    info: Color(0xFF3B82F6),
    infoContainer: Color(0xFFEFF6FF),
    bottomNavActive: Color(0xFF059669),
    bottomNavInactive: Color(0xFF9CA3AF),
  );

  static const _darkColors = FasalXColors(
    softBackground: Color(0xFF111827),
    surface: Color(0xFF1F2937),
    surfaceAlt: Color(0xFF1F2937),
    fieldFill: Color(0xFF374151),
    selectedFill: Color(0xFF064E3B),
    border: Color(0xFF374151),
    textStrong: Color(0xFFF9FAFB),
    textMuted: Color(0xFF9CA3AF),
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    warning: Color(0xFFFB923C),
    warningContainer: Color(0xFF7C2D12),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF7F1D1D),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF1E3A8A),
    bottomNavActive: Color(0xFF10B981),
    bottomNavInactive: Color(0xFF6B7280),
  );

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF059669),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF047857),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF3B82F6),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF2563EB),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFFF97316),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFEDD5),
      onTertiaryContainer: Color(0xFF7C2D12),
      error: Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1F2937),
      surfaceContainerHighest: Color(0xFFF3F4F6),
      onSurfaceVariant: Color(0xFF6B7280),
      outline: Color(0xFFF3F4F6),
      outlineVariant: Color(0xFFE5E7EB),
      shadow: Color(0x33000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFF111827),
      onInverseSurface: Color(0xFFF9FAFB),
      inversePrimary: Color(0xFF10B981),
    );
    return _build(scheme, _lightColors);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF10B981),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF059669),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFF60A5FA),
      onSecondary: Color(0xFF111827),
      secondaryContainer: Color(0xFF3B82F6),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFFFB923C),
      onTertiary: Color(0xFF111827),
      tertiaryContainer: Color(0xFF7C2D12),
      onTertiaryContainer: Color(0xFFFFEDD5),
      error: Color(0xFFF87171),
      onError: Color(0xFF111827),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: Color(0xFF1F2937),
      onSurface: Color(0xFFF9FAFB),
      surfaceContainerHighest: Color(0xFF374151),
      onSurfaceVariant: Color(0xFF9CA3AF),
      outline: Color(0xFF374151),
      outlineVariant: Color(0xFF4B5563),
      shadow: Color(0x99000000),
      scrim: Color(0xCC000000),
      inverseSurface: Color(0xFFF9FAFB),
      onInverseSurface: Color(0xFF111827),
      inversePrimary: Color(0xFF059669),
    );
    return _build(scheme, _darkColors);
  }

  static ThemeData _build(ColorScheme scheme, FasalXColors fx) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: fx.softBackground,
      canvasColor: fx.softBackground,
      cardColor: fx.surface,
      dividerColor: fx.border,
      fontFamily: 'Roboto',
      extensions: const <ThemeExtension<dynamic>>[],
    );

    final textTheme = base.textTheme.apply(
      bodyColor: fx.textStrong,
      displayColor: fx.textStrong,
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[fx],
      textTheme: textTheme.copyWith(
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 15.5,
          height: 1.35,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16.5, height: 1.35),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: fx.surfaceAlt,
        foregroundColor: fx.textStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: fx.textStrong),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: fx.textStrong,
          fontWeight: FontWeight.w900,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: fx.surface,
        selectedItemColor: fx.bottomNavActive,
        unselectedItemColor: fx.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: fx.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: fx.selectedFill,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? fx.bottomNavActive : fx.bottomNavInactive,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? fx.bottomNavActive : fx.bottomNavInactive,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: fx.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: fx.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: fx.textStrong,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: fx.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: fx.surface,
        modalBackgroundColor: fx.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: fx.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: fx.textStrong, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: fx.textStrong, fontWeight: FontWeight.w700),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(fx.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: _inputDecorationTheme(scheme, fx),
      ),
      inputDecorationTheme: _inputDecorationTheme(scheme, fx),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withAlpha(55),
        selectionHandleColor: scheme.primary,
      ),
      iconTheme: IconThemeData(color: fx.textStrong, size: 24),
      chipTheme: ChipThemeData(
        backgroundColor: fx.surfaceAlt,
        selectedColor: fx.selectedFill,
        disabledColor: fx.fieldFill,
        side: BorderSide(color: fx.border),
        checkmarkColor: scheme.primary,
        labelStyle: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w800),
        secondaryLabelStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: fx.fieldFill,
          disabledForegroundColor: fx.textMuted,
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: fx.border, width: 1.2),
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: fx.textStrong,
          disabledForegroundColor: fx.textMuted,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        focusColor: scheme.primaryContainer,
        hoverColor: scheme.primaryContainer,
        splashColor: fx.selectedFill,
        shape: const CircleBorder(),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return fx.fieldFill;
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: fx.border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return fx.textMuted;
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return fx.textMuted;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: fx.fieldFill,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withAlpha(32),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: fx.fieldFill,
        circularTrackColor: fx.fieldFill,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: fx.textMuted,
        indicatorColor: scheme.primary,
        dividerColor: fx.border,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return fx.textMuted;
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return fx.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return fx.fieldFill;
        }),
        trackOutlineColor: WidgetStatePropertyAll(fx.border),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w800,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: fx.textStrong,
        textColor: fx.textStrong,
        subtitleTextStyle: TextStyle(color: fx.textMuted),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    ColorScheme scheme,
    FasalXColors fx,
  ) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: fx.border, width: 1.2),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: fx.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      prefixIconColor: scheme.primary,
      suffixIconColor: fx.textMuted,
      iconColor: scheme.primary,
      labelStyle: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w800),
      floatingLabelStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w900,
      ),
      hintStyle: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w700),
      errorStyle: TextStyle(color: fx.danger, fontWeight: FontWeight.w800),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.8),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: fx.danger, width: 1.4),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: fx.danger, width: 1.8),
      ),
    );
  }
}
