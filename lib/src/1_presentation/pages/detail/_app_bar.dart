import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key, required this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final itemsColor = contrastingTextColor(backgroundColor);
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
}
