import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('update_world_cup_data.dart', () {
    test('fixture mode writes normalized update JSON', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'world_cup_updater_cli_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final baselineFile = await _writeJson(
        tempDir,
        'baseline.json',
        _baseline(),
      );
      final matchesFixture = await _writeJson(
        tempDir,
        'matches.json',
        _matchesResponse(),
      );
      final standingsFixture = await _writeJson(
        tempDir,
        'standings.json',
        _standingsResponse(),
      );
      final outputFile = File('${tempDir.path}/nested/updates.json');

      final result = await _runCli([
        '--baseline',
        baselineFile.path,
        '--output',
        outputFile.path,
        '--matches-fixture',
        matchesFixture.path,
        '--standings-fixture',
        standingsFixture.path,
      ]);

      expect(result.exitCode, 0, reason: result.stderr as String);
      final outputText = await outputFile.readAsString();
      expect(outputText, endsWith('\n'));

      final output = jsonDecode(outputText) as Map<String, Object?>;
      expect(output['schemaVersion'], 1);
      expect(output['source'], 'football-data.org');
      expect(output['lastUpdated'], isA<String>());
      expect(output['matches'], [
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
      expect(output['groupStandings'], [
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

    test('missing token without fixtures exits nonzero before fetch', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'world_cup_updater_cli_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final baselineFile = await _writeJson(
        tempDir,
        'baseline.json',
        _baseline(),
      );

      final result = await _runCli(
        [
          '--baseline',
          baselineFile.path,
          '--output',
          '${tempDir.path}/out.json',
        ],
        environment: {'FOOTBALL_DATA_API_TOKEN': ''},
      );

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr as String,
        contains('FOOTBALL_DATA_API_TOKEN is required'),
      );
    });

    test('missing fixture file exits nonzero with file error', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'world_cup_updater_cli_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final baselineFile = await _writeJson(
        tempDir,
        'baseline.json',
        _baseline(),
      );
      final standingsFixture = await _writeJson(
        tempDir,
        'standings.json',
        _standingsResponse(),
      );
      final missingFixture = File('${tempDir.path}/missing_matches.json');

      final result = await _runCli([
        '--baseline',
        baselineFile.path,
        '--output',
        '${tempDir.path}/out.json',
        '--matches-fixture',
        missingFixture.path,
        '--standings-fixture',
        standingsFixture.path,
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr as String,
        anyOf(contains(missingFixture.path), contains('Cannot open file')),
      );
    });

    test('season mismatch writes empty update JSON', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'world_cup_updater_cli_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final baseline = _baseline();
      baseline['matches'] = [
        {
          'id': 'match-001',
          'providerId': 497000,
          'kickoffUtc': '2026-06-11T19:00:00Z',
        },
      ];
      final baselineFile = await _writeJson(tempDir, 'baseline.json', baseline);
      final matchesFixture = await _writeJson(
        tempDir,
        'matches.json',
        _matchesResponse(utcDate: '2022-11-20T16:00:00Z'),
      );
      final standingsFixture = await _writeJson(
        tempDir,
        'standings.json',
        _standingsResponse(),
      );
      final outputFile = File('${tempDir.path}/updates.json');

      final result = await _runCli([
        '--baseline',
        baselineFile.path,
        '--output',
        outputFile.path,
        '--matches-fixture',
        matchesFixture.path,
        '--standings-fixture',
        standingsFixture.path,
      ]);

      expect(result.exitCode, 0, reason: result.stderr as String);
      expect(result.stderr as String, contains('does not appear to have 2026'));

      final output =
          jsonDecode(await outputFile.readAsString()) as Map<String, Object?>;
      expect(output['schemaVersion'], 1);
      expect(output['source'], 'football-data.org');
      expect(output['lastUpdated'], isA<String>());
      expect(output['matches'], isEmpty);
      expect(output['groupStandings'], isEmpty);
    });
  });
}

Future<ProcessResult> _runCli(
  List<String> arguments, {
  Map<String, String>? environment,
}) {
  return Process.run('dart', [
    'run',
    'tool/update_world_cup_data.dart',
    ...arguments,
  ], environment: environment);
}

Future<File> _writeJson(
  Directory directory,
  String name,
  Map<String, Object?> json,
) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  return file;
}

Map<String, Object?> _baseline() {
  return {
    'schemaVersion': 1,
    'teams': [
      {'id': 'mexico', 'providerId': 100},
      {'id': 'south-africa', 'providerId': 200},
    ],
    'groups': [
      {'id': 'group-a'},
    ],
    'matches': [
      {'id': 'match-001', 'providerId': 497000},
    ],
  };
}

Map<String, Object?> _matchesResponse({String? utcDate}) {
  final match = <String, Object?>{
    'id': 497000,
    'status': 'FINISHED',
    'score': {
      'winner': 'HOME_TEAM',
      'fullTime': {'home': 2, 'away': 1},
    },
    'homeTeam': {'id': 100},
    'awayTeam': {'id': 200},
  };
  if (utcDate != null) {
    match['utcDate'] = utcDate;
  }

  return {
    'matches': [match],
  };
}

Map<String, Object?> _standingsResponse() {
  return {
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
  };
}
