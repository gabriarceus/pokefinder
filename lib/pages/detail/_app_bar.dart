import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key, required this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Color itemsColor = itemColorExtractor(backgroundColor);
    return AppBar(
      iconTheme: IconThemeData(color: itemsColor),
      title: Text(
        AppLocalizations.of(context).details,
        style: TextStyle(color: itemsColor),
      ),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Color itemColorExtractor(Color? backgroundColor) {
    return backgroundColor!.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }
}
