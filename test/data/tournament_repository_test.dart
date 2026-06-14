import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_repository.dart';
import 'package:world_cup_app/src/data/tournament_update_client.dart';
import 'package:world_cup_app/src/data/world_cup_data_config.dart';

void main() {
  group('TournamentRepository', () {
    test('loads baseline when update URL absent', () async {
      final repository = TournamentRepository(
        config: const WorldCupDataConfig(assetPath: 'test/baseline.json'),
        loadAssetString: (assetPath) async {
          expect(assetPath, 'test/baseline.json');
          return _baselineTournamentJson();
        },
      );

      final tournament = await repository.loadTournament();

      expect(tournament.info.id, 'world-cup-2026');
      expect(tournament.matches.single.status.name, 'scheduled');
      expect(tournament.matches.single.score, isNull);
    });

    test('loads baseline and applies remote update', () async {
      final updateUri = Uri.parse('https://updates.example.com/world-cup.json');
      final repository = TournamentRepository(
        config: WorldCupDataConfig(
          assetPath: 'test/baseline.json',
          updateUrl: updateUri,
        ),
        loadAssetString: (_) async => _baselineTournamentJson(),
        fetchUpdateString: (uri) async {
          expect(uri, updateUri);
          return _tournamentUpdateJson();
        },
      );

      final tournament = await repository.loadTournament();
      final match = tournament.matches.single;

      expect(match.status.name, 'completed');
      expect(match.score?.home, 2);
      expect(match.score?.away, 1);
      expect(match.winnerTeamId, 'mexico');
    });

    test('keeps baseline when remote update fetch fails', () async {
      final repository = TournamentRepository(
        config: WorldCupDataConfig(
          updateUrl: Uri.parse('https://updates.example.com/world-cup.json'),
        ),
        loadAssetString: (_) async => _baselineTournamentJson(),
        fetchUpdateString: (_) async => throw Exception('network failed'),
      );

      final tournament = await repository.loadTournament();
      final match = tournament.matches.single;

      expect(match.status.name, 'scheduled');
      expect(match.score, isNull);
      expect(match.winnerTeamId, isNull);
    });

    test('keeps baseline when remote update fetch times out', () async {
      final repository = TournamentRepository(
        config: WorldCupDataConfig(
          updateUrl: Uri.parse('https://updates.example.com/world-cup.json'),
        ),
        loadAssetString: (_) async => _baselineTournamentJson(),
        fetchUpdateString: (_) async => throw TimeoutException('timed out'),
      );

      final tournament = await repository.loadTournament();
      final match = tournament.matches.single;

      expect(match.status.name, 'scheduled');
      expect(match.score, isNull);
      expect(match.winnerTeamId, isNull);
    });

    test('does not swallow remote update errors', () async {
      final repository = TournamentRepository(
        config: WorldCupDataConfig(
          updateUrl: Uri.parse('https://updates.example.com/world-cup.json'),
        ),
        loadAssetString: (_) async => _baselineTournamentJson(),
        fetchUpdateString: (_) async => throw StateError('broken state'),
      );

      expect(repository.loadTournament, throwsStateError);
    });

    test('invalid baseline JSON throws FormatException', () async {
      final repository = TournamentRepository(
        config: const WorldCupDataConfig(),
        loadAssetString: (_) async => '{"schemaVersion":1',
      );

      expect(repository.loadTournament, throwsFormatException);
    });
  });

  group('TournamentUpdateClient', () {
    test('times out slow update fetches', () async {
      final client = TournamentUpdateClient(
        timeout: const Duration(milliseconds: 10),
        fetch: (_) => Future<String>.delayed(
          const Duration(seconds: 1),
          _tournamentUpdateJson,
        ),
      );

      await expectLater(
        client.fetch(Uri.parse('https://updates.example.com/world-cup.json')),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}

String _baselineTournamentJson() {
  return jsonEncode({
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
      },
      {
        'id': 'south-africa',
        'name': 'South Africa',
        'shortName': 'RSA',
        'countryCode': 'RSA',
        'groupId': 'group-a',
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
        'stage': 'group',
        'groupId': 'group-a',
        'kickoffUtc': '2026-06-11T19:00:00Z',
        'venueId': 'estadio-azteca',
        'homeTeamId': 'mexico',
        'awayTeamId': 'south-africa',
      },
    ],
  });
}

String _tournamentUpdateJson() {
  return jsonEncode({
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
}
