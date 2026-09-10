import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          tooltip: AppLocalizations.of(context).settings,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text('PokéFinder', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
