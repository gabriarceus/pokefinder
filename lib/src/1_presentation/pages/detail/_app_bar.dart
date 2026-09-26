import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Collapsing app bar of the detail page.
///
/// Shows [background] when expanded and keeps the toolbar and [bottom]
/// pinned when collapsed. Icons and title use [foregroundColor].
class DetailAppBar extends StatelessWidget {
  const DetailAppBar({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.expandedHeight,
    required this.background,
    this.bottom,
    this.showShiny = false,
    this.isStale = false,
    this.onToggleShiny,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onShare,
    this.isInComparison = false,
    this.onCompare,
    this.onTeam,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final double expandedHeight;
  final Widget background;
  final PreferredSizeWidget? bottom;
  final bool showShiny;
  final bool isStale;
  final VoidCallback? onToggleShiny;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;
  final bool isInComparison;
  final VoidCallback? onCompare;
  final VoidCallback? onTeam;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDarkForeground =
        foregroundColor.computeLuminance() < backgroundColor.computeLuminance();
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: isDarkForeground
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      title: Text(t.details),
      actions: [
        if (isStale)
          Tooltip(
            message: t.staleDataNotice,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.cloud_off_rounded,
                color: foregroundColor.withValues(alpha: 0.75),
                size: 20,
              ),
            ),
          ),
        if (onToggleShiny != null)
          IconButton(
            icon: Icon(
              showShiny ? Icons.star_rounded : Icons.star_border_rounded,
            ),
            tooltip: t.spriteToggleShiny,
            onPressed: onToggleShiny,
          ),
        if (onShare != null)
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: t.shareLink,
            onPressed: onShare,
          ),
        if (onCompare != null)
          IconButton(
            icon: Icon(
              isInComparison
                  ? Icons.playlist_add_check_rounded
                  : Icons.compare_arrows_rounded,
            ),
            tooltip: isInComparison ? t.compareRemove : t.compareAdd,
            onPressed: onCompare,
          ),
        if (onTeam != null)
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            tooltip: t.teamAddMember,
            onPressed: onTeam,
          ),
        if (onToggleFavorite != null)
          IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            tooltip: isFavorite ? t.removeFromFavorites : t.addToFavorites,
            onPressed: onToggleFavorite,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: background,
      ),
      bottom: bottom,
    );
  }
}
