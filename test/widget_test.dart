import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/main.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';

void main() {
  test('uses a playful light green and red color system', () {
    expect(AppColors.background, Colors.white);
    expect(AppColors.primary, const Color(0xff16a34a));
    expect(AppColors.accent, const Color(0xffef233c));
    expect(AppColors.navBackground, Colors.white);
    expect(AppColors.navSelected, const Color(0xffffe3e8));
  });

  testWidgets('shows loading state before tournament data resolves', (
    WidgetTester tester,
  ) async {
    final completer = Completer<Tournament>();

    await tester.pumpWidget(MyApp(tournamentLoader: () => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('World Cup 2026'), findsNothing);

    completer.complete(_baselineTournament());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('World Cup 2026'), findsOneWidget);
  });

  testWidgets('renders real match data and opens match detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => _completedTournament()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mexico'), findsOneWidget);
    expect(find.text('Zuid-Afrika'), findsOneWidget);
    expect(find.text('2 - 1'), findsOneWidget);
    expect(find.textContaining('Mexico City Stadium'), findsNothing);
    expect(find.byKey(const ValueKey('match-card-match-001')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('match-card-match-001')));
    await tester.pumpAndSettle();

    expect(find.text('Wedstrijddetail'), findsOneWidget);
    expect(find.text('Eindstand'), findsOneWidget);
    expect(find.text('Mexico 2 - 1 Zuid-Afrika'), findsOneWidget);
    expect(find.text('Groep A'), findsOneWidget);
    expect(find.textContaining('Mexico City Stadium'), findsNothing);
    expect(find.text('Mexico City'), findsNothing);
  });

  testWidgets('groups tab renders zeroed standings when standings are absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => _baselineTournament()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Groepen'));
    await tester.pumpAndSettle();

    expect(find.text('Groep A'), findsOneWidget);
    expect(find.text('Ptn'), findsWidgets);
    expect(find.byKey(const ValueKey('standing-row-1-Mexico')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('standing-row-2-Zuid-Afrika')),
      findsOneWidget,
    );
    expect(find.text('0'), findsWidgets);
  });

  testWidgets(
    'knockout tab renders empty state when no knockout matches exist',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(tournamentLoader: () async => _baselineTournament()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Knock-out'));
      await tester.pumpAndSettle();

      expect(
        find.text('Geen knock-outwedstrijden beschikbaar'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('knockout-bracket')), findsNothing);
    },
  );

  testWidgets('shows an error state when baseline data cannot load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => throw const FormatException('bad')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kan toernooigegevens niet laden'), findsOneWidget);
    expect(
      find.text('Controleer de meegeleverde WK-gegevens en probeer opnieuw.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'knockout tab renders a bracket when real knockout matches exist',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(tournamentLoader: () async => _knockoutTournament()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Knock-out'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('knockout-bracket')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('bracket-match-round-32-1')),
        findsOneWidget,
      );
      expect(find.text('Winnaar groep A'), findsOneWidget);
      expect(find.text('Nummer 2 groep B'), findsOneWidget);
    },
  );

  testWidgets('knockout bracket uses unique keys across multiple rounds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => _multiRoundKnockoutTournament()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Knock-out'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('knockout-bracket')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bracket-round-Ronde van 32')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bracket-round-Achtste finales')),
      findsOneWidget,
    );
  });

  testWidgets('knockout bracket grows vertically for dense rounds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => _denseKnockoutTournament()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Knock-out'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('knockout-bracket')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bracket-match-round-32-16')),
      findsOneWidget,
    );
  });

  testWidgets('knockout round header matches inactive match filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BracketRoundHeader(stage: 'Ronde van 32')),
      ),
    );

    final containerFinder = find.descendant(
      of: find.byType(BracketRoundHeader),
      matching: find.byType(Container),
    );
    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    final label = tester.widget<Text>(find.text('Ronde van 32'));

    expect(decoration.color, AppColors.card);
    expect(decoration.borderRadius, BorderRadius.circular(18));
    expect(border.top.color, AppColors.border);
    expect(label.style?.color, AppColors.mutedForeground);
    expect(label.style?.fontWeight, FontWeight.w700);
  });
}

Tournament _baselineTournament() {
  return Tournament(
    schemaVersion: 1,
    info: TournamentInfo(
      id: 'world-cup-2026',
      name: 'FIFA World Cup 2026',
      startDate: DateTime(2026, 6, 11),
      endDate: DateTime(2026, 7, 19),
    ),
    teams: const [
      Team(
        id: 'mexico',
        name: 'Mexico',
        shortName: 'MEX',
        countryCode: 'MEX',
        groupId: 'group-a',
      ),
      Team(
        id: 'south-africa',
        name: 'South Africa',
        shortName: 'RSA',
        countryCode: 'RSA',
        groupId: 'group-a',
      ),
    ],
    groups: [
      TournamentGroup(
        id: 'group-a',
        name: 'Group A',
        teamIds: const ['mexico', 'south-africa'],
      ),
    ],
    venues: const [
      Venue(
        id: 'mexico-city-stadium',
        name: 'Mexico City Stadium',
        city: 'Mexico City',
        country: 'Mexico',
      ),
    ],
    matches: [
      Match(
        id: 'match-001',
        stage: TournamentStage.group,
        groupId: 'group-a',
        kickoffUtc: DateTime.utc(2026, 6, 11, 19),
        venueId: 'mexico-city-stadium',
        homeTeamId: 'mexico',
        awayTeamId: 'south-africa',
      ),
    ],
  );
}

Tournament _completedTournament() {
  return _baselineTournament().copyWith(
    matches: [
      Match(
        id: 'match-001',
        stage: TournamentStage.group,
        groupId: 'group-a',
        kickoffUtc: DateTime.utc(2026, 6, 11, 19),
        venueId: 'mexico-city-stadium',
        homeTeamId: 'mexico',
        awayTeamId: 'south-africa',
        status: MatchStatus.completed,
        score: const MatchScore(home: 2, away: 1),
        winnerTeamId: 'mexico',
      ),
    ],
  );
}

Tournament _knockoutTournament() {
  return _baselineTournament().copyWith(
    matches: [
      Match(
        id: 'round-32-1',
        stage: TournamentStage.knockout,
        kickoffUtc: DateTime.utc(2026, 7, 4, 20),
        venueId: 'mexico-city-stadium',
        homePlaceholder: 'Winner Group A',
        awayPlaceholder: 'Runner-up Group B',
      ),
    ],
  );
}

Tournament _multiRoundKnockoutTournament() {
  return _baselineTournament().copyWith(
    matches: [
      Match(
        id: 'round-32-1',
        stage: TournamentStage.knockout,
        kickoffUtc: DateTime.utc(2026, 7, 4, 20),
        venueId: 'mexico-city-stadium',
        homePlaceholder: 'Winner Group A',
        awayPlaceholder: 'Runner-up Group B',
      ),
      Match(
        id: 'round-16-1',
        stage: TournamentStage.knockout,
        kickoffUtc: DateTime.utc(2026, 7, 8, 20),
        venueId: 'mexico-city-stadium',
        homePlaceholder: 'TBD',
        awayPlaceholder: 'TBD',
      ),
      Match(
        id: 'quarter-final-1',
        stage: TournamentStage.knockout,
        kickoffUtc: DateTime.utc(2026, 7, 12, 20),
        venueId: 'mexico-city-stadium',
        homePlaceholder: 'TBD',
        awayPlaceholder: 'TBD',
      ),
    ],
  );
}

Tournament _denseKnockoutTournament() {
  return _baselineTournament().copyWith(
    matches: [
      for (var index = 1; index <= 16; index += 1)
        Match(
          id: 'round-32-$index',
          stage: TournamentStage.knockout,
          kickoffUtc: DateTime.utc(2026, 7, index),
          venueId: 'mexico-city-stadium',
          homePlaceholder: 'TBD',
          awayPlaceholder: 'TBD',
        ),
    ],
  );
}
