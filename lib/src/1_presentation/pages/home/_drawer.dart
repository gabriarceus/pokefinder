import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Navigation drawer of the home page.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final destinations = [
      (Icons.catching_pokemon, t.browsePokedex, '/pokedex'),
      (Icons.favorite_rounded, t.favorites, '/favorites'),
      (Icons.compare_arrows_rounded, t.compareTitle, '/compare'),
      (Icons.table_chart_rounded, t.matchupTitle, '/matchups'),
      (Icons.groups_rounded, t.teamsTitle, '/teams'),
      (Icons.tune_rounded, t.settings, '/settings'),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: theme.appBarTheme.backgroundColor,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 16,
              16,
              20,
            ),
            child: Text(
              'PokéFinder',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final (icon, label, path) in destinations)
            ListTile(
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(label),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                context.push(path);
              },
            ),
        ],
      ),
    );
  }
}
