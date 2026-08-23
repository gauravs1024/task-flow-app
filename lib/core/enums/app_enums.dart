import 'package:flutter/material.dart';
import 'package:task_flow_app/app/theme/app_colors.dart';

// ─────────────────────────────────────────────
// Task Status
// ─────────────────────────────────────────────

enum TaskStatus {
  todo,
  inProgress,
  review,
  done;

  /// Parses the raw JSON string value from mock-data.json
  static TaskStatus fromJson(String? value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'done':
        return TaskStatus.done;
      case 'todo':
      default:
        return TaskStatus.todo;
    }
  }

  /// Serializes back to the JSON string value
  String toJson() {
    switch (this) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.review:
        return 'review';
      case TaskStatus.done:
        return 'done';
      case TaskStatus.todo:
        return 'todo';
    }
  }

  /// Human-readable label shown in the UI
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.review:
        return AppColors.statusReview;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }
}

// ─────────────────────────────────────────────
// Task Priority
// ─────────────────────────────────────────────

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  static TaskPriority fromJson(String? value) {
    switch (value) {
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }

  String toJson() => name; // 'low' | 'medium' | 'high' | 'urgent'

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }
}

// ─────────────────────────────────────────────
// Project Status
// ─────────────────────────────────────────────

enum ProjectStatus {
  active,
  archived,
  completed;

  static ProjectStatus fromJson(String? value) {
    switch (value) {
      case 'archived':
        return ProjectStatus.archived;
      case 'completed':
        return ProjectStatus.completed;
      case 'active':
      default:
        return ProjectStatus.active;
    }
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.archived:
        return 'Archived';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  Color get badgeColor {
    switch (this) {
      case ProjectStatus.active:
        return AppColors.statusDone;
      case ProjectStatus.archived:
        return AppColors.textSecondaryLight;
      case ProjectStatus.completed:
        return AppColors.secondary;
    }
  }
}

// ─────────────────────────────────────────────
// App Theme Mode
// ─────────────────────────────────────────────

enum AppThemeMode {
  light,
  dark,
  system;

  static AppThemeMode fromString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  String toStorageString() => name; // 'light' | 'dark' | 'system'

  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
