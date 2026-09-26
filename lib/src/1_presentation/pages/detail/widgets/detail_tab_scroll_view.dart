import 'package:flutter/material.dart';

/// Scroll view of one detail tab inside the page's [NestedScrollView].
///
/// Starts below the pinned header and adds the page padding around [slivers].
class DetailTabScrollView extends StatelessWidget {
  const DetailTabScrollView({
    super.key,
    required this.storageKey,
    required this.slivers,
  });

  /// Keeps the scroll offset of this tab when the user switches tabs.
  final String storageKey;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey<String>(storageKey),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverMainAxisGroup(slivers: slivers),
        ),
      ],
    );
  }
}
