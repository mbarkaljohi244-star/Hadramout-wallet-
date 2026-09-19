import 'package:flutter/material.dart';

abstract final class WalletColors {
  static const navy = Color(0xFF092B5A);
  static const blue = Color(0xFF1464F4);
  static const brightBlue = Color(0xFF2A7BFF);
  static const paleBlue = Color(0xFFEAF2FF);
  static const ink = Color(0xFF132238);
  static const muted = Color(0xFF6C7A90);
  static const canvas = Color(0xFFF7F9FC);
  static const border = Color(0xFFDCE4F0);
  static const success = Color(0xFF16845A);
  static const danger = Color(0xFFD9485F);
}

ThemeData buildWalletTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: WalletColors.blue,
    brightness: Brightness.light,
  ).copyWith(
    primary: WalletColors.blue,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: WalletColors.ink,
    outline: WalletColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: WalletColors.canvas,
    fontFamily: 'Arial',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WalletColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WalletColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WalletColors.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WalletColors.danger),
      ),
      labelStyle: const TextStyle(color: WalletColors.muted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WalletColors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: WalletColors.blue,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
