import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.backgroundColor,
    this.showShiny = false,
    this.onToggleShiny,
  });

  final Color? backgroundColor;
  final bool showShiny;
  final VoidCallback? onToggleShiny;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final itemsColor = contrastingTextColor(backgroundColor);
    return AppBar(
      iconTheme: IconThemeData(color: itemsColor),
      leading: BackButton(
        color: itemsColor,
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
        ),
      ),
      title: Text(t.details, style: TextStyle(color: itemsColor)),
      backgroundColor: backgroundColor,
      actions: [
        if (onToggleShiny != null)
          IconButton(
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(48, 48)),
            ),
            icon: Icon(
              showShiny ? Icons.star_rounded : Icons.star_border_rounded,
              color: showShiny ? Colors.amber : itemsColor,
            ),
            tooltip: t.spriteToggleShiny,
            onPressed: onToggleShiny,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
