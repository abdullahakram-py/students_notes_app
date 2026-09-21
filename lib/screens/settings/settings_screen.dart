import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/note_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    final subjectsState = ref.watch(subjectsProvider);
    final notesState = ref.watch(notesProvider);

    final totalSubjects = subjectsState.valueOrNull?.length ?? 0;
    final totalNotes = notesState.valueOrNull?.length ?? 0;
    final totalAttachments = notesState.valueOrNull?.fold<int>(0, (sum, n) => sum + n.attachments.length) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance & Theming', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.lightSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wb_sunny_rounded, color: AppColors.lightPrimaryDark, size: 20),
                  ),
                  title: const Text('Light Mode ("Yellow & White")'),
                  subtitle: const Text('Bright, high-contrast academic theme'),
                  trailing: themeMode == ThemeMode.light
                      ? Icon(Icons.check_circle_rounded, color: primaryColor)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C2411),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nightlight_round, color: AppColors.darkPrimary, size: 20),
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Luminous yellow accents for late-night study'),
                  trailing: themeMode == ThemeMode.dark
                      ? Icon(Icons.check_circle_rounded, color: primaryColor)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white10 : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.brightness_auto_rounded, size: 20),
                  ),
                  title: const Text('System Default'),
                  subtitle: const Text('Matches your Android device theme settings'),
                  trailing: themeMode == ThemeMode.system
                      ? Icon(Icons.check_circle_rounded, color: primaryColor)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Storage Statistics
          _buildSectionHeader('Storage & Statistics', isDark),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('Total Subjects', '$totalSubjects', Icons.folder_rounded, Colors.orange),
                  const Divider(height: 20),
                  _buildStatRow('Total Notes', '$totalNotes', Icons.description_rounded, Colors.blue),
                  const Divider(height: 20),
                  _buildStatRow('Attached Files (Images & PDFs)', '$totalAttachments', Icons.attach_file_rounded, Colors.green),
                  const Divider(height: 20),
                  _buildStatRow('Local Database', 'Offline Hive NoSQL', Icons.storage_rounded, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: About
          _buildSectionHeader('About', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text(AppConstants.appName),
                  subtitle: const Text('Version ${AppConstants.version} (Academic Release)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_rounded),
                  title: const Text('Academic Note-Taking'),
                  subtitle: const Text('Structured subject management, geometric diagramming & PDF export.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
