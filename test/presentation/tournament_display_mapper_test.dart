import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';
import 'package:world_cup_app/src/presentation/tournament_display_mapper.dart';

void main() {
  group('mapTournamentToDisplay', () {
    test('maps scheduled match teams, kickoff, and group label', () {
      final tournament = _tournament(
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

      final display = mapTournamentToDisplay(tournament);
      final match = display.matches.single;
      final localKickoff = DateTime.utc(2026, 6, 11, 19).toLocal();

      expect(match.id, 'match-001');
      expect(match.stage, 'Groepsfase');
      expect(match.group, 'A');
      expect(match.home.name, 'Mexico');
      expect(match.away.name, 'Zuid-Afrika');
      expect(
        match.localDate,
        DateTime(localKickoff.year, localKickoff.month, localKickoff.day),
      );
      expect(match.date, '${_month(localKickoff.month)} ${localKickoff.day}');
      expect(match.dayOfWeek, _weekday(localKickoff.weekday));
      expect(match.time, _time(localKickoff));
      expect(match.resultText, _time(localKickoff));
      expect(match.isCompleted, isFalse);
    });

    test('maps completed match scores and winner emphasis', () {
      final tournament = _tournament(
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

      final match = mapTournamentToDisplay(tournament).matches.single;

      expect(match.isCompleted, isTrue);
      expect(match.resultText, '2 - 1');
      expect(match.detailResultText, 'Mexico 2 - 1 Zuid-Afrika');
      expect(match.isHomeWinner, isTrue);
      expect(match.isAwayWinner, isFalse);
    });

    test('uses knockout placeholders before TBD for missing teams', () {
      final tournament = _tournament(
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
          ),
        ],
      );

      final display = mapTournamentToDisplay(tournament);

      expect(display.knockoutMatches.first.stage, 'Ronde van 32');
      expect(display.knockoutMatches.first.home.name, 'Winnaar groep A');
      expect(display.knockoutMatches.first.away.name, 'Nummer 2 groep B');
      expect(display.knockoutMatches.last.stage, 'Achtste finales');
      expect(display.knockoutMatches.last.home.name, 'N.t.b.');
      expect(display.knockoutMatches.last.away.name, 'N.t.b.');
    });

    test('projects winner group slot from current standings', () {
      final tournament = _tournament(
        matches: [
          Match(
            id: 'round-32-1',
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 4, 20),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'Winner Group A',
          ),
        ],
        groupStandings: [
          GroupStanding(
            groupId: 'group-a',
            entries: const [
              GroupStandingEntry(
                teamId: 'mexico',
                played: 1,
                won: 1,
                drawn: 0,
                lost: 0,
                goalsFor: 2,
                goalsAgainst: 0,
                goalDifference: 2,
                points: 3,
              ),
              GroupStandingEntry(
                teamId: 'south-africa',
                played: 1,
                won: 0,
                drawn: 0,
                lost: 1,
                goalsFor: 0,
                goalsAgainst: 2,
                goalDifference: -2,
                points: 0,
              ),
            ],
          ),
        ],
      );

      final match = mapTournamentToDisplay(tournament).knockoutMatches.single;

      expect(match.home.name, 'Mexico');
      expect(match.home.qualifierLabel, 'Winnaar groep A');
      expect(match.home.isProjected, isTrue);
      expect(match.home.projectionUncertain, isFalse);
    });

    test('projects runner-up group slot from current standings', () {
      final tournament = _tournament(
        matches: [
          Match(
            id: 'round-32-1',
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 4, 20),
            venueId: 'mexico-city-stadium',
            awayPlaceholder: 'Runner-up Group A',
          ),
        ],
        groupStandings: [
          GroupStanding(
            groupId: 'group-a',
            entries: const [
              GroupStandingEntry(
                teamId: 'mexico',
                played: 1,
                won: 1,
                drawn: 0,
                lost: 0,
                goalsFor: 2,
                goalsAgainst: 0,
                goalDifference: 2,
                points: 3,
              ),
              GroupStandingEntry(
                teamId: 'south-africa',
                played: 1,
                won: 0,
                drawn: 0,
                lost: 1,
                goalsFor: 0,
                goalsAgainst: 2,
                goalDifference: -2,
                points: 0,
              ),
            ],
          ),
        ],
      );

      final match = mapTournamentToDisplay(tournament).knockoutMatches.single;

      expect(match.away.name, 'Zuid-Afrika');
      expect(match.away.qualifierLabel, 'Nummer 2 groep A');
      expect(match.away.isProjected, isTrue);
      expect(match.away.projectionUncertain, isFalse);
    });

    test('projects best third-place slot with uncertainty', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'round-32-2',
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 4, 20),
            venueId: 'mexico-city-stadium',
            awayPlaceholder: 'Best 3rd place Group A/B/C/D/F',
          ),
        ],
      );

      final match = mapTournamentToDisplay(tournament).knockoutMatches.single;

      expect(match.away.name, 'Canada');
      expect(match.away.qualifierLabel, 'Beste nummer 3 groep A/B/C/D/F');
      expect(match.away.isProjected, isTrue);
      expect(match.away.projectionUncertain, isTrue);
    });

    test('uses official round of 32 rules from FIFA match number', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'round-32-01',
            fifaMatchNumber: 73,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 6, 28, 19),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'TBD',
            awayPlaceholder: 'TBD',
          ),
        ],
      );

      final match = mapTournamentToDisplay(tournament).knockoutMatches.single;

      expect(match.home.name, 'Zuid-Afrika');
      expect(match.home.qualifierLabel, 'Nummer 2 groep A');
      expect(match.away.name, 'België');
      expect(match.away.qualifierLabel, 'Nummer 2 groep B');
    });

    test('uses later-round winner source labels before results', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'round-16-01',
            fifaMatchNumber: 89,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 4, 17),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'TBD',
            awayPlaceholder: 'TBD',
          ),
        ],
      );

      final match = mapTournamentToDisplay(tournament).knockoutMatches.single;

      expect(match.home.name, 'Winnaar wedstrijd 73');
      expect(match.home.qualifierLabel, 'Winnaar wedstrijd 73');
      expect(match.away.name, 'Winnaar wedstrijd 75');
      expect(match.away.qualifierLabel, 'Winnaar wedstrijd 75');
    });

    test('resolves later-round winner slots from completed source matches', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'round-32-01',
            fifaMatchNumber: 73,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 6, 28, 19),
            venueId: 'mexico-city-stadium',
            homeTeamId: 'south-africa',
            awayTeamId: 'belgium',
            status: MatchStatus.completed,
            score: const MatchScore(home: 2, away: 1),
            winnerTeamId: 'south-africa',
          ),
          Match(
            id: 'round-16-01',
            fifaMatchNumber: 89,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 4, 17),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'TBD',
            awayPlaceholder: 'TBD',
          ),
        ],
      );

      final roundOf16 = mapTournamentToDisplay(
        tournament,
      ).knockoutMatches.singleWhere((match) => match.fifaMatchNumber == 89);

      expect(roundOf16.home.name, 'Zuid-Afrika');
      expect(roundOf16.home.qualifierLabel, 'Winnaar wedstrijd 73');
      expect(roundOf16.home.isProjected, isTrue);
      expect(roundOf16.home.projectionUncertain, isFalse);
    });

    test('resolves final slots from completed semifinal winners', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'semi-final-01',
            fifaMatchNumber: 101,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 14, 19),
            venueId: 'mexico-city-stadium',
            homeTeamId: 'mexico',
            awayTeamId: 'brazil',
            status: MatchStatus.completed,
            score: const MatchScore(home: 1, away: 0),
            winnerTeamId: 'mexico',
          ),
          Match(
            id: 'final',
            fifaMatchNumber: 104,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 19, 19),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'TBD',
            awayPlaceholder: 'TBD',
          ),
        ],
      );

      final finalMatch = mapTournamentToDisplay(
        tournament,
      ).knockoutMatches.singleWhere((match) => match.fifaMatchNumber == 104);

      expect(finalMatch.home.name, 'Mexico');
      expect(finalMatch.home.qualifierLabel, 'Winnaar wedstrijd 101');
    });

    test('resolves third-place slots from completed semifinal losers', () {
      final tournament = _projectionTournament(
        matches: [
          Match(
            id: 'semi-final-01',
            fifaMatchNumber: 101,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 14, 19),
            venueId: 'mexico-city-stadium',
            homeTeamId: 'mexico',
            awayTeamId: 'brazil',
            status: MatchStatus.completed,
            score: const MatchScore(home: 1, away: 0),
            winnerTeamId: 'mexico',
          ),
          Match(
            id: 'third-place',
            fifaMatchNumber: 103,
            stage: TournamentStage.knockout,
            kickoffUtc: DateTime.utc(2026, 7, 18, 21),
            venueId: 'mexico-city-stadium',
            homePlaceholder: 'TBD',
            awayPlaceholder: 'TBD',
          ),
        ],
      );

      final thirdPlace = mapTournamentToDisplay(
        tournament,
      ).knockoutMatches.singleWhere((match) => match.fifaMatchNumber == 103);

      expect(thirdPlace.home.name, 'Brazilië');
      expect(thirdPlace.home.qualifierLabel, 'Verliezer wedstrijd 101');
    });

    test('creates zeroed group standings when standing data is absent', () {
      final display = mapTournamentToDisplay(_tournament(matches: const []));

      expect(display.groups.single.name, 'Groep A');
      expect(display.groups.single.standings, hasLength(2));
      expect(display.groups.single.standings.first.team.name, 'Mexico');
      expect(display.groups.single.standings.first.played, 0);
      expect(display.groups.single.standings.first.won, 0);
      expect(display.groups.single.standings.first.drawn, 0);
      expect(display.groups.single.standings.first.lost, 0);
      expect(display.groups.single.standings.first.goalDifference, 0);
      expect(display.groups.single.standings.first.points, 0);
    });
  });
}

Tournament _tournament({
  required List<Match> matches,
  List<GroupStanding> groupStandings = const [],
}) {
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
    matches: matches,
    groupStandings: groupStandings,
  );
}

Tournament _projectionTournament({required List<Match> matches}) {
  final groups = [
    _group('group-a', ['mexico', 'south-africa', 'czechia']),
    _group('group-b', ['brazil', 'belgium', 'argentina']),
    _group('group-c', ['canada-group-winner', 'canada-runner-up', 'canada']),
    _group('group-f', ['france', 'spain', 'germany']),
  ];

  return Tournament(
    schemaVersion: 1,
    info: TournamentInfo(
      id: 'world-cup-2026',
      name: 'FIFA World Cup 2026',
      startDate: DateTime(2026, 6, 11),
      endDate: DateTime(2026, 7, 19),
    ),
    teams: const [
      Team(id: 'mexico', name: 'Mexico', shortName: 'MEX', countryCode: 'MEX'),
      Team(
        id: 'south-africa',
        name: 'South Africa',
        shortName: 'RSA',
        countryCode: 'RSA',
      ),
      Team(
        id: 'czechia',
        name: 'Czechia',
        shortName: 'CZE',
        countryCode: 'CZE',
      ),
      Team(id: 'brazil', name: 'Brazil', shortName: 'BRA', countryCode: 'BRA'),
      Team(
        id: 'belgium',
        name: 'Belgium',
        shortName: 'BEL',
        countryCode: 'BEL',
      ),
      Team(
        id: 'argentina',
        name: 'Argentina',
        shortName: 'ARG',
        countryCode: 'ARG',
      ),
      Team(
        id: 'canada-group-winner',
        name: 'Canada Group Winner',
        shortName: 'CGW',
        countryCode: 'CAN',
      ),
      Team(
        id: 'canada-runner-up',
        name: 'Canada Runner-up',
        shortName: 'CRU',
        countryCode: 'CAN',
      ),
      Team(id: 'canada', name: 'Canada', shortName: 'CAN', countryCode: 'CAN'),
      Team(id: 'france', name: 'France', shortName: 'FRA', countryCode: 'FRA'),
      Team(id: 'spain', name: 'Spain', shortName: 'ESP', countryCode: 'ESP'),
      Team(
        id: 'germany',
        name: 'Germany',
        shortName: 'GER',
        countryCode: 'GER',
      ),
    ],
    groups: groups,
    venues: const [
      Venue(
        id: 'mexico-city-stadium',
        name: 'Mexico City Stadium',
        city: 'Mexico City',
        country: 'Mexico',
      ),
    ],
    matches: matches,
    groupStandings: [
      GroupStanding(
        groupId: 'group-a',
        entries: const [
          GroupStandingEntry(
            teamId: 'mexico',
            played: 1,
            won: 1,
            drawn: 0,
            lost: 0,
            goalsFor: 2,
            goalsAgainst: 0,
            goalDifference: 2,
            points: 3,
          ),
          GroupStandingEntry(
            teamId: 'south-africa',
            played: 1,
            won: 0,
            drawn: 1,
            lost: 0,
            goalsFor: 1,
            goalsAgainst: 1,
            goalDifference: 0,
            points: 1,
          ),
          GroupStandingEntry(
            teamId: 'czechia',
            played: 1,
            won: 0,
            drawn: 0,
            lost: 1,
            goalsFor: 0,
            goalsAgainst: 2,
            goalDifference: -2,
            points: 0,
          ),
        ],
      ),
      GroupStanding(
        groupId: 'group-c',
        entries: const [
          GroupStandingEntry(
            teamId: 'canada-group-winner',
            played: 1,
            won: 1,
            drawn: 0,
            lost: 0,
            goalsFor: 3,
            goalsAgainst: 0,
            goalDifference: 3,
            points: 3,
          ),
          GroupStandingEntry(
            teamId: 'canada-runner-up',
            played: 1,
            won: 0,
            drawn: 1,
            lost: 0,
            goalsFor: 1,
            goalsAgainst: 1,
            goalDifference: 0,
            points: 1,
          ),
          GroupStandingEntry(
            teamId: 'canada',
            played: 1,
            won: 0,
            drawn: 1,
            lost: 0,
            goalsFor: 2,
            goalsAgainst: 2,
            goalDifference: 0,
            points: 1,
          ),
        ],
      ),
      GroupStanding(
        groupId: 'group-b',
        entries: const [
          GroupStandingEntry(
            teamId: 'brazil',
            played: 1,
            won: 1,
            drawn: 0,
            lost: 0,
            goalsFor: 2,
            goalsAgainst: 0,
            goalDifference: 2,
            points: 3,
          ),
          GroupStandingEntry(
            teamId: 'belgium',
            played: 1,
            won: 0,
            drawn: 1,
            lost: 0,
            goalsFor: 1,
            goalsAgainst: 1,
            goalDifference: 0,
            points: 1,
          ),
          GroupStandingEntry(
            teamId: 'argentina',
            played: 1,
            won: 0,
            drawn: 0,
            lost: 1,
            goalsFor: 0,
            goalsAgainst: 2,
            goalDifference: -2,
            points: 0,
          ),
        ],
      ),
      GroupStanding(
        groupId: 'group-f',
        entries: const [
          GroupStandingEntry(
            teamId: 'france',
            played: 1,
            won: 1,
            drawn: 0,
            lost: 0,
            goalsFor: 1,
            goalsAgainst: 0,
            goalDifference: 1,
            points: 3,
          ),
          GroupStandingEntry(
            teamId: 'spain',
            played: 1,
            won: 0,
            drawn: 1,
            lost: 0,
            goalsFor: 1,
            goalsAgainst: 1,
            goalDifference: 0,
            points: 1,
          ),
          GroupStandingEntry(
            teamId: 'germany',
            played: 1,
            won: 0,
            drawn: 0,
            lost: 1,
            goalsFor: 0,
            goalsAgainst: 1,
            goalDifference: -1,
            points: 0,
          ),
        ],
      ),
    ],
  );
}

TournamentGroup _group(String id, List<String> teamIds) {
  final groupLetter = id.substring(id.length - 1).toUpperCase();
  return TournamentGroup(id: id, name: 'Group $groupLetter', teamIds: teamIds);
}

String _month(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

String _weekday(int weekday) {
  return const [
    'Maandag',
    'Dinsdag',
    'Woensdag',
    'Donderdag',
    'Vrijdag',
    'Zaterdag',
    'Zondag',
  ][weekday - 1];
}

String _time(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
