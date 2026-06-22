import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_sync/data/repositories/habit_repository.dart';
import 'package:habit_sync/ui/core/theme/colors.dart';
import 'package:habit_sync/ui/core/theme/theme_provider.dart';
import 'package:flutter/services.dart';

/// App Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final repo = Provider.of<HabitRepository>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          floating: true,
          pinned: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            
            // ── Display Settings ──────────────────────────────────────
            _sectionHeader(context, 'Display'),
            _cardContainer(
              context,
              child: SwitchListTile(
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between dark and light appearance'),
                value: themeProvider.isDarkMode,
                onChanged: (val) {
                  themeProvider.toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Data & Backup ─────────────────────────────────────────
            _sectionHeader(context, 'Data & Backup'),
            _cardContainer(
              context,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_upload_rounded, color: AppColors.primary),
                    title: const Text('Export Data'),
                    subtitle: const Text('Copy backup code to clipboard'),
                    onTap: () async {
                      final jsonString = repo.exportJson();
                      await Clipboard.setData(ClipboardData(text: jsonString));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data exported to clipboard!')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.file_download_rounded, color: AppColors.primary),
                    title: const Text('Import Data'),
                    subtitle: const Text('Restore from backup code'),
                    onTap: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null && data!.text!.isNotEmpty) {
                        final success = await repo.importJson(data.text!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Data imported successfully!' : 'Invalid backup code!'),
                              backgroundColor: success ? Colors.green : AppColors.error,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Clipboard is empty')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── App Info ──────────────────────────────────────────────
            _sectionHeader(context, 'App Information'),
            _cardContainer(
              context,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    title: const Text('Version'),
                    trailing: Text(
                      '1.0.0 (Beta)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.code_rounded, color: AppColors.primary),
                    title: const Text('Framework'),
                    trailing: Text(
                      'Flutter 3.44',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Danger Zone ───────────────────────────────────────────
            _sectionHeader(context, 'Danger Zone'),
            _cardContainer(
              context,
              child: ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                title: const Text('Reset App Data'),
                subtitle: const Text('Permanently delete all habits and history'),
                onTap: () {
                  _showResetConfirmation(context, repo);
                },
              ),
            ),
            const SizedBox(height: 48),
          ]),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _cardContainer(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, HabitRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your habit entries and stats. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              // Reset all data by cleaning up list & invoking reload which sets defaults
              final sharedPrefs = await SharedPreferences.getInstance();
              await sharedPrefs.clear();
              await repo.loadHabits();
              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App data has been reset to defaults.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
