import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';

void main() {
  group('Tournament models', () {
    test('parses baseline tournament data', () {
      final tournament = Tournament.fromJson(_baselineTournamentJson());

      expect(tournament.schemaVersion, 1);
      expect(tournament.info.id, 'world-cup-2026');
      expect(tournament.teams.first.countryCode, 'MEX');
      final southAfrica = tournament.teams.singleWhere(
        (team) => team.id == 'south-africa',
      );
      expect(southAfrica.name, 'South Africa');
      expect(southAfrica.shortName, 'RSA');
      expect(southAfrica.countryCode, 'RSA');
      expect(tournament.groups.first.name, 'Group A');
      expect(tournament.venues.first.city, 'Mexico City');
      expect(tournament.matches.first.stage, TournamentStage.group);
      expect(tournament.matches.first.status, MatchStatus.scheduled);
      expect(tournament.matches.first.score, isNull);
      expect(tournament.matches.first.providerId, 497000);
    });

    test('rejects unsupported schema version', () {
      final json = _baselineTournamentJson()..['schemaVersion'] = 2;

      expect(() => Tournament.fromJson(json), throwsFormatException);
    });

    test('parses unknown knockout teams using placeholders', () {
      final tournament = Tournament.fromJson(_baselineTournamentJson());
      final match = tournament.matches.singleWhere(
        (match) => match.id == 'match-097',
      );

      expect(match.stage, TournamentStage.knockout);
      expect(match.homeTeamId, isNull);
      expect(match.awayTeamId, isNull);
      expect(match.homePlaceholder, 'Winner Group A');
      expect(match.awayPlaceholder, 'Runner-up Group B');
    });

    test('copyWith can clear nullable result fields', () {
      final match = Match(
        id: 'match-001',
        providerId: 497000,
        stage: TournamentStage.group,
        kickoffUtc: DateTime.utc(2026, 6, 11, 19),
        venueId: 'estadio-azteca',
        status: MatchStatus.completed,
        score: MatchScore(home: 2, away: 1),
        winnerTeamId: 'mexico',
      );

      final updated = match.copyWith(
        providerId: null,
        score: null,
        winnerTeamId: null,
      );

      expect(updated.providerId, isNull);
      expect(updated.score, isNull);
      expect(updated.winnerTeamId, isNull);
      expect(updated.status, MatchStatus.completed);
    });
  });
}

Map<String, Object?> _baselineTournamentJson() {
  return {
    'schemaVersion': 1,
    'info': {
      'id': 'world-cup-2026',
      'name': 'FIFA World Cup 2026',
      'startDate': '2026-06-11',
      'endDate': '2026-07-19',
    },
    'teams': [
      {
        'id': 'mexico',
        'name': 'Mexico',
        'shortName': 'MEX',
        'countryCode': 'MEX',
        'groupId': 'group-a',
        'providerId': 1001,
      },
      {
        'id': 'south-africa',
        'name': 'South Africa',
        'shortName': 'RSA',
        'countryCode': 'RSA',
        'groupId': 'group-a',
        'providerId': 1002,
      },
    ],
    'groups': [
      {
        'id': 'group-a',
        'name': 'Group A',
        'teamIds': ['mexico', 'south-africa'],
      },
    ],
    'venues': [
      {
        'id': 'estadio-azteca',
        'name': 'Estadio Azteca',
        'city': 'Mexico City',
        'country': 'Mexico',
      },
    ],
    'matches': [
      {
        'id': 'match-001',
        'providerId': 497000,
        'stage': 'group',
        'groupId': 'group-a',
        'kickoffUtc': '2026-06-11T19:00:00Z',
        'venueId': 'estadio-azteca',
        'homeTeamId': 'mexico',
        'awayTeamId': 'south-africa',
      },
      {
        'id': 'match-097',
        'stage': 'knockout',
        'kickoffUtc': '2026-07-04T19:00:00Z',
        'venueId': 'estadio-azteca',
        'homePlaceholder': 'Winner Group A',
        'awayPlaceholder': 'Runner-up Group B',
      },
    ],
  };
}
