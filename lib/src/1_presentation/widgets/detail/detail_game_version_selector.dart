import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_cubit.dart';

/// Compact dropdown that selects the game version shown by the detail tabs.
class DetailGameVersionSelector extends StatelessWidget {
  const DetailGameVersionSelector({super.key, required this.typeColor});

  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailGameVersionCubit, DetailGameVersionState>(
      builder: (context, state) {
        if (state.availableVersions.isEmpty) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<DetailGameVersionCubit>();

        final textTheme = Theme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: typeColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_esports_outlined, size: 16, color: typeColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  context.t().filterByVersion,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final hasSelected =
                        state.isAllVersions ||
                        state.availableVersions.contains(state.selectedVersion);
                    final activeValue = hasSelected
                        ? state.selectedVersion
                        : DetailGameVersionState.allVersions;

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: activeValue,
                        isDense: true,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(16),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: typeColor,
                        ),
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: DetailGameVersionState.allVersions,
                            child: Text(
                              context.t().allGameVersions,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...state.availableVersions.map((version) {
                            return DropdownMenuItem<String>(
                              value: version,
                              child: Text(
                                context.translateGameVersion(version),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            cubit.selectVersion(val);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
