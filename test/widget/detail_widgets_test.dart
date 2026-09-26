import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/_app_bar.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/bold_label_value.dart';

void main() {
  Future<void> pumpInApp(WidgetTester tester, Widget child) {
    return mockNetworkImagesFor(
      () => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  /// [DetailAppBar] is a `SliverAppBar`, so it needs a scroll view around it.
  Widget appBarHost(Widget appBar) => Scaffold(
    body: CustomScrollView(
      slivers: [
        appBar,
        const SliverToBoxAdapter(child: SizedBox(height: 200)),
      ],
    ),
  );

  group('BoldLabelValue', () {
    testWidgets('renders nothing when the value is empty', (tester) async {
      await pumpInApp(
        tester,
        const BoldLabelValue(
          label: 'Ability 2',
          value: '',
          textColor: Colors.black,
        ),
      );

      expect(find.byType(Row), findsNothing);
      expect(find.textContaining('Ability 2'), findsNothing);
    });

    testWidgets('renders the label and the capitalized value', (tester) async {
      await pumpInApp(
        tester,
        const BoldLabelValue(
          label: 'Ability 1',
          value: 'overgrow',
          textColor: Colors.black,
        ),
      );

      expect(find.text('Ability 1: '), findsOneWidget);
      expect(find.text('Overgrow'), findsOneWidget);
    });
  });

  group('DetailAppBar stale indicator', () {
    testWidgets('displays cloud_off icon and tooltip when isStale is true', (
      tester,
    ) async {
      await pumpInApp(
        tester,
        appBarHost(
          const DetailAppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            expandedHeight: kToolbarHeight + 120,
            background: SizedBox.shrink(),
            isStale: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.byTooltip('Offline cached data'), findsOneWidget);
    });

    testWidgets('hides cloud_off icon when isStale is false', (tester) async {
      await pumpInApp(
        tester,
        appBarHost(
          const DetailAppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            expandedHeight: kToolbarHeight + 120,
            background: SizedBox.shrink(),
            isStale: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });
  });
}
