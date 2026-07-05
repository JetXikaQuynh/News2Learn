import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignTokens {
  static const LinearGradient pastelBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5F3FF), Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient primaryAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static final List<BoxShadow> accentShadow = [
    BoxShadow(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static TextStyle get headingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF1E293B),
  );

  static TextStyle get subheadingStyle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF334155),
  );

  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF475569),
  );
}
