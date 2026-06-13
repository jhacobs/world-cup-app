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
        throwsFormatException,
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
        throwsFormatException,
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
  };
}
