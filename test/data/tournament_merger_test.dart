import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_merger.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';
import 'package:world_cup_app/src/data/tournament_update_models.dart';

void main() {
  group('TournamentMerger', () {
    test('applies completed score update for Mexico win', () {
      final baseline = _baselineTournament();
      final update = TournamentUpdate.fromJson({
        'schemaVersion': 1,
        'source': 'test-provider',
        'lastUpdated': '2026-06-11T22:00:00Z',
        'matches': [
          {
            'matchId': 'match-001',
            'status': 'completed',
            'homeScore': 2,
            'awayScore': 1,
            'winnerTeamId': 'mexico',
          },
        ],
      });

      final tournament = TournamentMerger.merge(baseline, update);
      final match = tournament.matches.singleWhere(
        (match) => match.id == 'match-001',
      );

      expect(match.status, MatchStatus.completed);
      expect(match.score?.home, 2);
      expect(match.score?.away, 1);
      expect(match.winnerTeamId, 'mexico');
    });

    test(
      'ignores unknown match update and keeps scheduled match scoreless',
      () {
        final baseline = _baselineTournament();
        final update = TournamentUpdate.fromJson({
          'schemaVersion': 1,
          'source': 'test-provider',
          'lastUpdated': '2026-06-11T22:00:00Z',
          'matches': [
            {
              'matchId': 'unknown-match',
              'status': 'completed',
              'homeScore': 2,
              'awayScore': 1,
              'winnerTeamId': 'mexico',
            },
          ],
        });

        final tournament = TournamentMerger.merge(baseline, update);
        final match = tournament.matches.singleWhere(
          (match) => match.id == 'match-001',
        );

        expect(tournament.matches, hasLength(1));
        expect(match.status, MatchStatus.scheduled);
        expect(match.score, isNull);
        expect(match.winnerTeamId, isNull);
      },
    );

    test('applies group standings update with Mexico on three points', () {
      final baseline = _baselineTournament();
      final update = TournamentUpdate.fromJson({
        'schemaVersion': 1,
        'source': 'test-provider',
        'lastUpdated': '2026-06-11T22:00:00Z',
        'matches': <Object?>[],
        'groupStandings': [
          {
            'groupId': 'group-a',
            'entries': [
              {
                'teamId': 'mexico',
                'played': 1,
                'won': 1,
                'drawn': 0,
                'lost': 0,
                'goalsFor': 2,
                'goalsAgainst': 1,
                'goalDifference': 1,
                'points': 3,
              },
            ],
          },
        ],
      });

      final tournament = TournamentMerger.merge(baseline, update);
      final standing = tournament.groupStandings.single;
      final entry = standing.entries.single;

      expect(standing.groupId, 'group-a');
      expect(entry.teamId, 'mexico');
      expect(entry.points, 3);
    });

    test('scheduled update clears existing score and winner', () {
      final baseline = _baselineTournament(
        match: _baselineMatch().copyWith(
          status: MatchStatus.completed,
          score: const MatchScore(home: 2, away: 1),
          winnerTeamId: 'mexico',
        ),
      );
      final update = TournamentUpdate.fromJson({
        'schemaVersion': 1,
        'source': 'test-provider',
        'lastUpdated': '2026-06-11T22:00:00Z',
        'matches': [
          {'matchId': 'match-001', 'status': 'scheduled'},
        ],
      });

      final tournament = TournamentMerger.merge(baseline, update);
      final match = tournament.matches.single;

      expect(match.status, MatchStatus.scheduled);
      expect(match.score, isNull);
      expect(match.winnerTeamId, isNull);
    });
  });
}

Tournament _baselineTournament({Match? match}) {
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
        id: 'estadio-azteca',
        name: 'Estadio Azteca',
        city: 'Mexico City',
        country: 'Mexico',
      ),
    ],
    matches: [match ?? _baselineMatch()],
  );
}

Match _baselineMatch() {
  return Match(
    id: 'match-001',
    providerId: 497000,
    stage: TournamentStage.group,
    groupId: 'group-a',
    kickoffUtc: DateTime.utc(2026, 6, 11, 19),
    venueId: 'estadio-azteca',
    homeTeamId: 'mexico',
    awayTeamId: 'south-africa',
  );
}
