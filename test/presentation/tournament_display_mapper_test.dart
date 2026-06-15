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
      expect(match.stage, 'Group Stage');
      expect(match.group, 'A');
      expect(match.home.name, 'Mexico');
      expect(match.away.name, 'South Africa');
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
      expect(match.detailResultText, 'Mexico 2 - 1 South Africa');
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

      expect(display.knockoutMatches.first.stage, 'Round of 32');
      expect(display.knockoutMatches.first.home.name, 'Winner Group A');
      expect(display.knockoutMatches.first.away.name, 'Runner-up Group B');
      expect(display.knockoutMatches.last.stage, 'Round of 16');
      expect(display.knockoutMatches.last.home.name, 'TBD');
      expect(display.knockoutMatches.last.away.name, 'TBD');
    });

    test('creates zeroed group standings when standing data is absent', () {
      final display = mapTournamentToDisplay(_tournament(matches: const []));

      expect(display.groups.single.name, 'Group A');
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

Tournament _tournament({required List<Match> matches}) {
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
  );
}

String _month(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
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
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

String _time(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
