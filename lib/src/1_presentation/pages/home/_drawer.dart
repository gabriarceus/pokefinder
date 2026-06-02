import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/src/2_application/hydrated_bloc/language_storage.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final languageState = context.watch<LanguageCubit>().state;
    final currentLanguageId = languageState.languageId;
    final isSystemLanguage = currentLanguageId == Language.system.id;

    return BlocListener<HomeBloc, HomeBlocState>(
      listenWhen: (previous, current) =>
          current.cacheCleared && !previous.cacheCleared,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t().cacheClearedSuccessfully),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Drawer(
        child: Column(
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.05,
                  MediaQuery.of(context).padding.top,
                  0,
                  20),
              child: Text(
                context.t().settings,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // "Use device language" toggle
            SwitchListTile(
              title: Text(context.t().useDeviceLanguage),
              subtitle: Text(
                context.t().useDeviceLanguageInfo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: isSystemLanguage,
              activeTrackColor: Colors.red,
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close drawer
                  context.read<HomeBloc>().add(ClearCacheEvent());
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(context.t().clearCache),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
