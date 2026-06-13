import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/football_data_mapper.dart';

void main() {
  group('FootballDataMapper', () {
    test('maps finished Mexico win', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      final update = mapper.mapMatchesResponse({
        'matches': [
          {
            'id': 497000,
            'status': 'FINISHED',
            'score': {
              'winner': 'HOME_TEAM',
              'fullTime': {'home': 2, 'away': 1},
            },
            'homeTeam': {'id': 100},
            'awayTeam': {'id': 200},
          },
        ],
      });

      expect(update['schemaVersion'], 1);
      expect(update['source'], 'football-data.org');
      expect(update['lastUpdated'], isA<String>());
      expect(update['groupStandings'], isEmpty);
      expect(update['matches'], [
        {
          'matchId': 'match-001',
          'providerId': 497000,
          'status': 'completed',
          'homeScore': 2,
          'awayScore': 1,
          'homePenaltyScore': null,
          'awayPenaltyScore': null,
          'winnerTeamId': 'mexico',
        },
      ]);
    });

    test('maps timed match with null scores', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      final update = mapper.mapMatchesResponse({
        'matches': [
          {
            'id': 497000,
            'status': 'TIMED',
            'score': {
              'winner': null,
              'fullTime': {'home': null, 'away': null},
            },
            'homeTeam': {'id': 100},
            'awayTeam': {'id': 200},
          },
        ],
      });
      final match =
          (update['matches'] as List<Object?>).single as Map<String, Object?>;

      expect(match['status'], 'scheduled');
      expect(match['homeScore'], isNull);
      expect(match['awayScore'], isNull);
      expect(match['winnerTeamId'], isNull);
    });

    test('throws when provider match is not in baseline', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      expect(
        () => mapper.mapMatchesResponse({
          'matches': [
            {
              'id': 497999,
              'status': 'FINISHED',
              'score': {
                'winner': 'HOME_TEAM',
                'fullTime': {'home': 2, 'away': 1},
              },
              'homeTeam': {'id': 100},
              'awayTeam': {'id': 200},
            },
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('No baseline match found for provider match id 497999'),
          ),
        ),
      );
    });

    test('throws for unknown football-data status', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      expect(
        () => mapper.mapMatchesResponse({
          'matches': [
            {
              'id': 497000,
              'status': 'DELAYED',
              'score': {
                'winner': null,
                'fullTime': {'home': null, 'away': null},
              },
              'homeTeam': {'id': 100},
              'awayTeam': {'id': 200},
            },
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Unknown football-data status "DELAYED"'),
          ),
        ),
      );
    });

    test('throws when baseline match providerId is duplicated', () {
      final baseline = _baseline();
      baseline['matches'] = [
        {'id': 'match-001', 'providerId': 497000},
        {'id': 'match-duplicate', 'providerId': 497000},
      ];

      expect(
        () => FootballDataMapper.fromBaseline(baseline),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('matches'),
              contains('497000'),
              contains('match-001'),
              contains('match-duplicate'),
            ),
          ),
        ),
      );
    });

    test('throws when baseline team providerId is duplicated', () {
      final baseline = _baseline();
      baseline['teams'] = [
        {'id': 'mexico', 'providerId': 100},
        {'id': 'duplicate-mexico', 'providerId': 100},
        {'id': 'south-africa', 'providerId': 200},
      ];

      expect(
        () => FootballDataMapper.fromBaseline(baseline),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('teams'),
              contains('100'),
              contains('mexico'),
              contains('duplicate-mexico'),
            ),
          ),
        ),
      );
    });

    test('maps standings response for group A', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      final standings = mapper.mapStandingsResponse({
        'standings': [
          {
            'group': 'GROUP_A',
            'table': [
              {
                'team': {'id': 100},
                'playedGames': 1,
                'won': 1,
                'draw': 0,
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

      expect(standings, [
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
      ]);
    });

    test('throws when standings group is unknown', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      expect(
        () => mapper.mapStandingsResponse({
          'standings': [
            {'group': 'GROUP_Z', 'table': <Object?>[]},
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('GROUP_Z'),
          ),
        ),
      );
    });

    test('throws when standings team provider id is unknown', () {
      final mapper = FootballDataMapper.fromBaseline(_baseline());

      expect(
        () => mapper.mapStandingsResponse({
          'standings': [
            {
              'group': 'GROUP_A',
              'table': [
                {
                  'team': {'id': 999},
                  'playedGames': 1,
                  'won': 1,
                  'draw': 0,
                  'lost': 0,
                  'goalsFor': 2,
                  'goalsAgainst': 1,
                  'goalDifference': 1,
                  'points': 3,
                },
              ],
            },
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('999'),
          ),
        ),
      );
    });
  });
}

Map<String, Object?> _baseline() {
  return {
    'teams': [
      {'id': 'mexico', 'providerId': 100},
      {'id': 'south-africa', 'providerId': 200},
    ],
    'matches': [
      {'id': 'match-001', 'providerId': 497000},
    ],
    'groups': [
      {'id': 'group-a'},
    ],
  };
}
