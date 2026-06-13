import 'dart:convert';
import 'dart:io';

import 'src/football_data_mapper.dart';

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

    final mapper = FootballDataMapper.fromBaseline(baseline);
    final update = mapper.mapMatchesResponse(matches);
    update['groupStandings'] = mapper.mapStandingsResponse(standings);

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

  return _fetchJsonObject(uri: uri, token: token, client: client);
}

Future<Map<String, Object?>> _fetchJsonObject({
  required Uri uri,
  required String token,
  required HttpClient client,
}) async {
  final request = await client.getUrl(uri);
  request.headers.set('X-Auth-Token', token);

  final response = await request.close();
  final body = await utf8.decodeStream(response);
  if (response.statusCode < 200 || response.statusCode > 299) {
    throw HttpException(
      'football-data.org returned ${response.statusCode}: $body',
      uri: uri,
    );
  }

  return _decodeJsonObject(body, uri.toString());
}

Future<Map<String, Object?>> _readJsonObject(String path) async {
  final source = await File(path).readAsString();
  return _decodeJsonObject(source, path);
}

Map<String, Object?> _decodeJsonObject(String source, String description) {
  final decoded = jsonDecode(source);
  final normalized = _normalizeJson(decoded, description);
  if (normalized is Map<String, Object?>) {
    return normalized;
  }

  throw FormatException('Expected $description to contain a JSON object.');
}

Object? _normalizeJson(Object? value, String description) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return [for (final item in value) _normalizeJson(item, description)];
  }
  if (value is Map) {
    final object = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException(
          'Expected $description to contain only string object keys.',
        );
      }
      object[key] = _normalizeJson(entry.value, description);
    }
    return object;
  }

  throw FormatException(
    'Expected $description to contain JSON-compatible values.',
  );
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
