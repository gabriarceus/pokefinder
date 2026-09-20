import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/2_application/bloc/preferences_cubit/preferences_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/recent_history_cubit/recent_history_cubit.dart';
import 'package:pokefinder/src/2_application/hydrated_bloc/language_storage.dart';
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
      await context.read<PreferencesCubit>().clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.cacheClearedSuccessfully),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      confirmBackgroundColor: AppPalette.brandRed,
      confirmForegroundColor: AppPalette.onBrandRed,
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
    final isSystemLanguage = languageState.languageId == Language.system.id;

    final formattedCacheSize = MeasurementFormatter.formatByteSize(
      prefState.cacheSizeBytes,
      locale: Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(color: AppPalette.onBrandRed),
        ),
        backgroundColor: AppPalette.brandRed,
        iconTheme: const IconThemeData(color: AppPalette.onBrandRed),
      ),
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
          SwitchListTile(
            title: Text(t.useDeviceLanguage),
            subtitle: Text(
              t.useDeviceLanguageInfo,
              style: theme.textTheme.bodySmall,
            ),
            value: isSystemLanguage,
            activeTrackColor: AppPalette.brandRed,
            onChanged: (bool value) {
              if (value) {
                context.read<LanguageCubit>().enableSystemLanguage();
              } else {
                context.read<LanguageCubit>().disableSystemLanguage();
              }
            },
          ),
          if (!isSystemLanguage)
            RadioGroup<int>(
              groupValue: languageState.languageId,
              onChanged: (int? value) {
                if (value != null) {
                  context.read<LanguageCubit>().setLanguage(value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: Language.selectable.map((language) {
                  return RadioListTile<int>(
                    title: Text(language.nativeName),
                    value: language.id,
                  );
                }).toList(),
              ),
            ),
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
            activeTrackColor: AppPalette.brandRed,
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
              activeColor: AppPalette.brandRed,
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
            activeTrackColor: AppPalette.brandRed,
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
            trailing: ElevatedButton(
              onPressed: () => _showClearCacheDialog(context, t),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.brandRed,
                foregroundColor: AppPalette.onBrandRed,
              ),
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
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }
}
