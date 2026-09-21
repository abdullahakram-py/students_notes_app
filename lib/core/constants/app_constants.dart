/// Core application constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Student Notes';
  static const String appTagline = 'Your Academic Study Companion';
  static const String version = '1.0.0';

  // Storage / Hive Box Names
  static const String subjectsBoxName = 'subjects_box';
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';

  // Default Subject
  static const String uncategorizedSubjectId = 'uncategorized_default';
  static const String uncategorizedSubjectName = 'Uncategorized';

  // Limits & Thresholds
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20 MB max file size limit
  static const int searchDebounceMs = 300;
  static const int autoSaveDebounceMs = 1200;
  static const int subjectWarningThreshold = 50;

  // SharedPreferences Keys
  static const String keyThemeMode = 'app_theme_mode';
}
