import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:world_cup_app/main.dart';

void main() {
  test('uses a playful light green and red color system', () {
    expect(AppColors.background, Colors.white);
    expect(AppColors.primary, const Color(0xff16a34a));
    expect(AppColors.accent, const Color(0xffef233c));
    expect(AppColors.navBackground, Colors.white);
    expect(AppColors.navSelected, const Color(0xffffe3e8));
  });

  testWidgets('knockout round header matches inactive match filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BracketRoundHeader(stage: 'Round of 32')),
      ),
    );

    final containerFinder = find.descendant(
      of: find.byType(BracketRoundHeader),
      matching: find.byType(Container),
    );
    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    final label = tester.widget<Text>(find.text('Round of 32'));

    expect(decoration.color, AppColors.card);
    expect(decoration.borderRadius, BorderRadius.circular(18));
    expect(border.top.color, AppColors.border);
    expect(label.style?.color, AppColors.mutedForeground);
    expect(label.style?.fontWeight, FontWeight.w700);
  });

  testWidgets('renders tournament shell and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('World Cup 2026'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Knockout'), findsOneWidget);
    expect(find.text('Mexico'), findsOneWidget);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Pts'), findsWidgets);

    await tester.tap(find.text('Knockout'));
    await tester.pumpAndSettle();

    expect(find.text('Round of 32'), findsWidgets);
    expect(find.text('TBD'), findsWidgets);
  });

  testWidgets('group standings rows stay white', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    final topRow = find.byKey(const ValueKey('standing-row-1-Mexico'));
    final lowerRow = find.byKey(const ValueKey('standing-row-3-Ecuador'));

    expect(topRow, findsOneWidget);
    expect(lowerRow, findsOneWidget);

    final topContainer = tester.widget<Container>(topRow);
    final lowerContainer = tester.widget<Container>(lowerRow);

    expect((topContainer.decoration! as BoxDecoration).color, AppColors.card);
    expect((lowerContainer.decoration! as BoxDecoration).color, AppColors.card);
  });

  testWidgets('shows scheduled matches and completed results clearly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('KO'), findsWidgets);
    expect(find.text('FT'), findsWidgets);
    expect(
      find.byKey(const ValueKey('match-card-spain-germany')),
      findsOneWidget,
    );
    expect(find.text('2 - 1'), findsOneWidget);
  });

  testWidgets('match cards show teams around a centered score without codes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final matchCard = find.byKey(const ValueKey('match-card-spain-germany'));
    await tester.ensureVisible(matchCard);

    expect(
      find.descendant(
        of: matchCard,
        matching: find.byKey(const ValueKey('matchup-row-spain-germany')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: matchCard, matching: find.text('Spain')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: matchCard, matching: find.text('2 - 1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: matchCard, matching: find.text('Germany')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: matchCard, matching: find.text('ESP')),
      findsNothing,
    );
    expect(
      find.descendant(of: matchCard, matching: find.text('GER')),
      findsNothing,
    );
  });

  testWidgets('match filter chips switch between group stage and rounds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Group Stage'), findsOneWidget);
    expect(find.text('Round of 32'), findsOneWidget);
    expect(find.text('Quarter-finals'), findsOneWidget);
    expect(find.text('Semi-finals'), findsOneWidget);
    expect(find.text('3rd Place'), findsWidgets);
    expect(find.widgetWithText(ChoiceChip, 'Final'), findsOneWidget);

    final finalChip = find.widgetWithText(ChoiceChip, 'Final');
    await tester.ensureVisible(finalChip);
    await tester.tap(finalChip);
    await tester.pumpAndSettle();

    expect(find.text('Mexico'), findsNothing);
    expect(find.byKey(const ValueKey('match-card-final')), findsOneWidget);
    expect(find.textContaining('MetLife Stadium'), findsOneWidget);

    final groupStageChip = find.widgetWithText(ChoiceChip, 'Group Stage');
    await tester.ensureVisible(groupStageChip);
    await tester.tap(groupStageChip);
    await tester.pumpAndSettle();

    expect(find.text('Mexico'), findsOneWidget);
    expect(find.text('Winner Group A'), findsNothing);
  });

  testWidgets('knockout tab renders a horizontal bracket without filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Knockout'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('knockout-bracket')), findsOneWidget);
    expect(find.byKey(const ValueKey('knockout-tree')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bracket-connector-tree')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-slot-round-32-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-slot-round-16-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-Round of 32')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-Round of 16')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-Quarter-finals')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-Semi-finals')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-3rd Place')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('bracket-round-Final')), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Semi-finals'), findsNothing);
    expect(find.text('TBD'), findsWidgets);
    expect(find.byKey(const ValueKey('bracket-match-final')), findsOneWidget);
  });

  testWidgets('opens match detail with final score and venue metadata', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final spainGermany = find.byKey(const ValueKey('match-card-spain-germany'));
    await tester.ensureVisible(spainGermany);
    await tester.tap(spainGermany);
    await tester.pumpAndSettle();

    expect(find.text('Match detail'), findsOneWidget);
    expect(find.text('Final score'), findsOneWidget);
    expect(find.text('Spain 2 - 1 Germany'), findsOneWidget);
    expect(find.text('Mercedes-Benz Stadium'), findsOneWidget);
    expect(find.text('Group E'), findsOneWidget);
  });
}
