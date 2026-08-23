import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF14B8A6); // Teal
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Neutral Light Mode
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardBgLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Dark Mode
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardBgDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Priority colors
  static const Color priorityUrgent = Color(0xFFEF4444); // Red
  static const Color priorityHigh = Color(0xFFF97316); // Orange
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityLow = Color(0xFF3B82F6); // Blue

  // Status colors
  static const Color statusTodo = Color(0xFF64748B); // Slate
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue
  static const Color statusReview = Color(0xFF8B5CF6); // Purple
  static const Color statusDone = Color(0xFF10B981); // Emerald

  // Helper colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
}
