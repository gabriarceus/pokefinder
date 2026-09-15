import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/preferences_cubit/preferences_cubit.dart';
import 'package:pokefinder/src/2_application/hydrated_bloc/hydrated_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  Future<void> _showClearCacheDialog(BuildContext context) async {
    final confirmed = await showClearCacheConfirmationDialog(context);

    if (confirmed == true && context.mounted) {
      context.read<HomeBloc>().add(ClearCacheEvent());
      try {
        context.read<PreferencesCubit>().refreshCacheSize();
      } catch (_) {}
      if (context.mounted) {
        Navigator.of(context).pop(); // Close drawer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageState = context.watch<LanguageCubit>().state;
    final currentLanguageId = languageState.languageId;
    final isSystemLanguage = currentLanguageId == Language.system.id;

    int cacheSize = 0;
    try {
      cacheSize = context.watch<PreferencesCubit>().state.cacheSizeBytes;
    } catch (_) {}

    final formattedCacheSize = MeasurementFormatter.formatByteSize(
      cacheSize,
      locale: Localizations.localeOf(context).languageCode,
    );

    return Drawer(
      child: Column(
        children: <Widget>[
          // Header
          Container(
            width: double.infinity,
            color: AppPalette.brandRed,
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.05,
              MediaQuery.of(context).padding.top + 16,
              16,
              20,
            ),
            child: Text(
              t.settings,
              style: const TextStyle(
                color: AppPalette.onBrandRed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.catching_pokemon,
              color: AppPalette.brandRed,
            ),
            title: Text(t.browsePokedex),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/pokedex');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite_rounded,
              color: AppPalette.brandRed,
            ),
            title: Text(t.favorites),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.compare_arrows_rounded,
              color: AppPalette.brandRed,
            ),
            title: Text(t.compareTitle),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/compare');
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded, color: AppPalette.brandRed),
            title: Text(t.settings),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
          ),
          const Divider(height: 1),
          // "Use device language" toggle
          SwitchListTile(
            title: Text(context.t().useDeviceLanguage),
            subtitle: Text(
              context.t().useDeviceLanguageInfo,
              style: Theme.of(context).textTheme.bodySmall,
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
          const Divider(height: 1),
          // Language list – shown only when system language is off
          if (!isSystemLanguage)
            RadioGroup<int>(
              groupValue: currentLanguageId,
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
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.cacheSize(size: formattedCacheSize),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showClearCacheDialog(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppPalette.brandRed,
                    foregroundColor: AppPalette.onBrandRed,
                  ),
                  child: Text(t.clearCache),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
