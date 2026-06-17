import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/main.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';
import 'package:world_cup_app/src/presentation/tournament_display_models.dart';

void main() {
  test(
    'uses the World Cup green, rose, and configured neutral color system',
    () {
      expect(AppColors.background, const Color(0xfffaf9f7));
      expect(AppColors.primary, const Color(0xff16a34a));
      expect(AppColors.accent, const Color(0xffc42151));
      expect(AppColors.navBackground, const Color(0xfffaf9f7));
    },
  );

  testWidgets('bottom navigation has no selected indicator fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(tournamentLoader: () async => _baselineTournament()),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final navTheme = materialApp.theme!.navigationBarTheme;

    expect(navTheme.indicatorColor, Colors.transparent);
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

  testWidgets('matches tab scrolls to current match date', (
    WidgetTester tester,
  ) async {
    await _withSmallViewport(tester, () async {
      await tester.pumpWidget(
        MyApp(
          tournamentLoader: () async => _manyMatchDaysTournament(),
          currentDateProvider: () => DateTime(2026, 6, 16),
        ),
      );
      await tester.pumpAndSettle();

      expect(_headerTop(tester, 'Jun 16'), lessThan(180));
      expect(_headerTop(tester, 'Jun 11'), lessThan(0));
    });
  });

  testWidgets('matches tab scrolls to next future match date', (
    WidgetTester tester,
  ) async {
    await _withSmallViewport(tester, () async {
      await tester.pumpWidget(
        MyApp(
          tournamentLoader: () async => _manyMatchDaysTournament(),
          currentDateProvider: () => DateTime(2026, 6, 15),
        ),
      );
      await tester.pumpAndSettle();

      expect(_headerTop(tester, 'Jun 16'), lessThan(180));
      expect(_headerTop(tester, 'Jun 11'), lessThan(0));
    });
  });

  testWidgets('matches tab stays at start when all match dates are past', (
    WidgetTester tester,
  ) async {
    await _withSmallViewport(tester, () async {
      await tester.pumpWidget(
        MyApp(
          tournamentLoader: () async => _manyMatchDaysTournament(),
          currentDateProvider: () => DateTime(2026, 7, 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(_headerTop(tester, 'Jun 11'), greaterThan(0));
      expect(_headerTop(tester, 'Jun 16'), greaterThan(520));
    });
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

  testWidgets('bracket team line shows projected qualifier label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BracketTeamLine(
            team: DisplayTeam(
              id: 'mexico',
              name: 'Mexico',
              code: 'MEX',
              qualifierLabel: 'Winnaar groep A',
              isProjected: true,
            ),
            score: null,
            isWinner: false,
          ),
        ),
      ),
    );

    expect(find.text('Mexico'), findsOneWidget);
    expect(find.text('Winnaar groep A'), findsOneWidget);
  });

  testWidgets('bracket team line marks uncertain projections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BracketTeamLine(
            team: DisplayTeam(
              id: 'canada',
              name: 'Canada',
              code: 'CAN',
              qualifierLabel: 'Beste nummer 3 groep A/B/C/D/F',
              isProjected: true,
              projectionUncertain: true,
            ),
            score: null,
            isWinner: false,
          ),
        ),
      ),
    );

    expect(find.text('Canada'), findsOneWidget);
    expect(find.text('Voorlopig'), findsOneWidget);
  });

  testWidgets('final and third place round headers match other rounds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              BracketRoundHeader(stage: '3e plaats'),
              BracketRoundHeader(stage: 'Finale'),
            ],
          ),
        ),
      ),
    );

    for (final stage in ['3e plaats', 'Finale']) {
      final containerFinder = find.descendant(
        of: find.ancestor(
          of: find.text(stage),
          matching: find.byType(BracketRoundHeader),
        ),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      final label = tester.widget<Text>(find.text(stage));

      expect(decoration.color, AppColors.card);
      expect(decoration.borderRadius, BorderRadius.circular(18));
      expect(border.top.color, AppColors.border);
      expect(label.style?.color, AppColors.mutedForeground);
      expect(label.style?.fontWeight, FontWeight.w700);
    }
  });

  testWidgets(
    'completed match status is neutral while score chips look outlined',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                MatchStatusColumn(match: _displayMatch(isCompleted: false)),
                MatchStatusColumn(match: _displayMatch(isCompleted: true)),
                MatchCenterScore(match: _displayMatch(isCompleted: false)),
                MatchCenterScore(match: _displayMatch(isCompleted: true)),
              ],
            ),
          ),
        ),
      );

      final statusDecorations = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(MatchStatusColumn),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration! as BoxDecoration)
          .toList();
      final upcomingStatusBorder = statusDecorations[0].border! as Border;
      final completedStatusBorder = statusDecorations[1].border! as Border;

      expect(statusDecorations[0].color, AppColors.muted);
      expect(statusDecorations[1].color, AppColors.neutral200);
      expect(upcomingStatusBorder.right.color, AppColors.primary);
      expect(completedStatusBorder.right.color, AppColors.neutral300);

      final scoreDecorations = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(MatchCenterScore),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration! as BoxDecoration)
          .toList();
      final upcomingScoreBorder = scoreDecorations[0].border! as Border;
      final completedScoreBorder = scoreDecorations[1].border! as Border;

      expect(scoreDecorations[0].color, AppColors.card);
      expect(scoreDecorations[1].color, AppColors.card);
      expect(upcomingScoreBorder.top.color, AppColors.primary);
      expect(completedScoreBorder.top.color, AppColors.primary);

      final scoreTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(MatchCenterScore),
              matching: find.byType(Text),
            ),
          )
          .toList();

      expect(scoreTexts[0].style?.color, AppColors.primary);
      expect(scoreTexts[1].style?.color, AppColors.primary);
    },
  );
}

DisplayMatch _displayMatch({required bool isCompleted}) {
  const home = DisplayTeam(id: 'mexico', name: 'Mexico', code: 'MEX');
  const away = DisplayTeam(id: 'canada', name: 'Canada', code: 'CAN');
  return DisplayMatch(
    id: isCompleted ? 'completed' : 'upcoming',
    stage: 'Groepsfase',
    isKnockout: false,
    group: 'A',
    localDate: DateTime(2026, 6, 11),
    date: '11 juni',
    dayOfWeek: 'Donderdag',
    time: '21:00',
    home: home,
    away: away,
    isCompleted: isCompleted,
    homeScore: isCompleted ? 2 : null,
    awayScore: isCompleted ? 1 : null,
  );
}

Future<void> _withSmallViewport(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  tester.view.physicalSize = const Size(390, 520);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await body();
}

double _headerTop(WidgetTester tester, String date) {
  return tester.getTopLeft(find.text(date).first).dy;
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

Tournament _manyMatchDaysTournament() {
  return _baselineTournament().copyWith(
    matches: [
      for (final day in [11, 12, 13, 14, 16, 17, 18])
        Match(
          id: 'match-jun-$day',
          stage: TournamentStage.group,
          groupId: 'group-a',
          kickoffUtc: DateTime.utc(2026, 6, day, 12),
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
