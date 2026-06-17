import 'dart:convert';
import 'dart:io';

import 'src/football_data_mapper.dart';
import 'src/retrying_json_fetcher.dart';

const _defaultBaselinePath = 'assets/data/world_cup_2026.json';
const _defaultOutputPath = '_site/world_cup_2026_updates.json';
const _matchesUri = 'https://api.football-data.org/v4/competitions/WC/matches';
const _standingsUri =
    'https://api.football-data.org/v4/competitions/WC/standings';

Future<void> main(List<String> arguments) async {
  try {
    await _run(arguments);
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

Future<void> _run(List<String> arguments) async {
  final options = _Options.parse(arguments);
  final needsToken =
      options.matchesFixturePath == null ||
      options.standingsFixturePath == null;
  if (needsToken && options.token.isEmpty) {
    throw const FormatException('FOOTBALL_DATA_API_TOKEN is required');
  }

  final baseline = await _readJsonObject(options.baselinePath);
  final mapper = FootballDataMapper.fromBaseline(baseline);
  final client = HttpClient();
  try {
    final matches = await _loadProviderResponse(
      fixturePath: options.matchesFixturePath,
      uri: Uri.parse(_matchesUri),
      token: options.token,
      client: client,
    );
    final standings = await _loadProviderResponse(
      fixturePath: options.standingsFixturePath,
      uri: Uri.parse(_standingsUri),
      token: options.token,
      client: client,
    );

    Map<String, Object?> update;
    try {
      update = mapper.mapMatchesResponse(matches);
      update['groupStandings'] = mapper.mapStandingsResponse(standings);
    } on ProviderSeasonMismatchException catch (error) {
      stderr.writeln(
        'football-data.org does not appear to have 2026 World Cup data yet: '
        '${error.message}',
      );
      update = _emptyUpdate();
    }

    await _writeJsonObject(options.outputPath, update);
  } finally {
    client.close(force: true);
  }
}

Future<Map<String, Object?>> _loadProviderResponse({
  required String? fixturePath,
  required Uri uri,
  required String token,
  required HttpClient client,
}) {
  if (fixturePath != null) {
    return _readJsonObject(fixturePath);
  }

  return fetchJsonObjectWithRetries(uri: uri, token: token, client: client);
}

Future<Map<String, Object?>> _readJsonObject(String path) async {
  final source = await File(path).readAsString();
  return decodeJsonObject(source, path);
}

Map<String, Object?> _emptyUpdate() {
  return {
    'schemaVersion': 1,
    'source': 'football-data.org',
    'lastUpdated': DateTime.now().toUtc().toIso8601String(),
    'matches': <Object?>[],
    'groupStandings': <Object?>[],
  };
}

Future<void> _writeJsonObject(String path, Map<String, Object?> object) async {
  final outputFile = File(path);
  final parent = outputFile.parent;
  if (!await parent.exists()) {
    await parent.create(recursive: true);
  }

  final json = const JsonEncoder.withIndent('  ').convert(object);
  await outputFile.writeAsString('$json\n');
}

class _Options {
  const _Options({
    required this.baselinePath,
    required this.outputPath,
    required this.token,
    required this.matchesFixturePath,
    required this.standingsFixturePath,
  });

  factory _Options.parse(List<String> arguments) {
    var baselinePath = _defaultBaselinePath;
    var outputPath = _defaultOutputPath;
    var token = Platform.environment['FOOTBALL_DATA_API_TOKEN'] ?? '';
    String? matchesFixturePath;
    String? standingsFixturePath;

    for (var index = 0; index < arguments.length; index += 1) {
      final option = arguments[index];
      String value() {
        index += 1;
        if (index >= arguments.length) {
          throw FormatException('Missing value for $option');
        }
        return arguments[index];
      }

      switch (option) {
        case '--baseline':
          baselinePath = value();
        case '--output':
          outputPath = value();
        case '--token':
          token = value();
        case '--matches-fixture':
          matchesFixturePath = value();
        case '--standings-fixture':
          standingsFixturePath = value();
        default:
          throw FormatException('Unknown option $option');
      }
    }

    return _Options(
      baselinePath: baselinePath,
      outputPath: outputPath,
      token: token,
      matchesFixturePath: matchesFixturePath,
      standingsFixturePath: standingsFixturePath,
    );
  }

  final String baselinePath;
  final String outputPath;
  final String token;
  final String? matchesFixturePath;
  final String? standingsFixturePath;
}
