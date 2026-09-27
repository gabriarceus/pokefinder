import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/2_application/bloc/preferences_cubit/preferences_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/recent_history_cubit/recent_history_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/language_cubit/language_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Screen displaying user preferences for theme, language, units, audio, and cache.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PreferencesCubit>().refreshCacheSize();
      }
    });
  }

  Future<void> _showClearCacheDialog(
    BuildContext context,
    AppLocalizations t,
  ) async {
    final confirmed = await showClearCacheConfirmationDialog(context);

    if (confirmed == true && context.mounted) {
      final cleared = await context.read<PreferencesCubit>().clearCache();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cleared ? t.cacheClearedSuccessfully : t.errorUnexpected,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    AppLocalizations t,
  ) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: t.clearHistory,
      content: t.clearHistoryConfirmation,
      confirmLabel: t.clear,
      cancelLabel: t.cancel,
    );

    if (confirmed == true && context.mounted) {
      context.read<RecentHistoryCubit>().clearAllHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final prefState = context.watch<PreferencesCubit>().state;
    final historyState = context.watch<RecentHistoryCubit>().state;
    final languageState = context.watch<LanguageCubit>().state;

    final formattedCacheSize = MeasurementFormatter.formatByteSize(
      prefState.cacheSizeBytes,
      locale: Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Section: Theme
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.theme,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(t.themeSystem),
                  icon: const Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(t.themeLight),
                  icon: const Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(t.themeDark),
                  icon: const Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {prefState.themeMode},
              onSelectionChanged: (selected) {
                context.read<PreferencesCubit>().setThemeMode(selected.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Section: Measurement Units
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.unitSystem,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<UnitSystem>(
              segments: [
                ButtonSegment(
                  value: UnitSystem.metric,
                  label: Text(t.unitSystemMetric),
                  icon: const Icon(Icons.straighten_rounded),
                ),
                ButtonSegment(
                  value: UnitSystem.imperial,
                  label: Text(t.unitSystemImperial),
                  icon: const Icon(Icons.square_foot_rounded),
                ),
              ],
              selected: {prefState.unitSystem},
              onSelectionChanged: (selected) {
                context.read<PreferencesCubit>().setUnitSystem(selected.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Section: Language
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.language,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: Language.system.id,
                  label: Text(t.useDeviceLanguage),
                  icon: const Icon(Icons.phone_android_rounded),
                ),
                for (final language in Language.selectable)
                  ButtonSegment(
                    value: language.id,
                    label: Text(language.nativeName),
                  ),
              ],
              selected: {languageState.languageId},
              onSelectionChanged: (selected) {
                context.read<LanguageCubit>().setLanguage(selected.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Section: Audio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.audioSettings,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(t.autoPlayCry),
            subtitle: Text(t.autoPlayCryInfo, style: theme.textTheme.bodySmall),
            value: prefState.autoPlayCry,
            onChanged: (val) {
              context.read<PreferencesCubit>().setAutoPlayCry(val);
            },
          ),
          ListTile(
            title: Text(t.cryVolume),
            subtitle: Slider(
              value: prefState.cryVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(prefState.cryVolume * 100).round()}%',
              onChanged: (val) {
                context.read<PreferencesCubit>().setCryVolume(val);
              },
            ),
          ),
          const Divider(height: 1),

          // Section: History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.recentlyViewed,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(t.historyEnabled),
            subtitle: Text(
              t.historyEnabledInfo,
              style: theme.textTheme.bodySmall,
            ),
            value: historyState.isHistoryEnabled,
            onChanged: (val) {
              context.read<RecentHistoryCubit>().setHistoryEnabled(val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded),
            title: Text(t.clearHistory),
            onTap: () => _showClearHistoryDialog(context, t),
          ),
          const Divider(height: 1),

          // Section: Storage & Cache
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.storageAndCache,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: Text(t.cacheSize(size: formattedCacheSize)),
            subtitle: Text(t.clearCache),
            trailing: FilledButton(
              onPressed: () => _showClearCacheDialog(context, t),
              child: Text(t.clear),
            ),
          ),
          const Divider(height: 1),

          // Section: About & Attribution
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.aboutPokeFinder,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(t.aboutPokeFinder),
            subtitle: Text(t.aboutAppDescription),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}
