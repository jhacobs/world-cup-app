import 'dart:async';
import 'dart:convert';
import 'dart:io';

const defaultMaxAttempts = 3;
const defaultRetryDelay = Duration(seconds: 2);

Future<Map<String, Object?>> fetchJsonObjectWithRetries({
  required Uri uri,
  required String token,
  required HttpClient client,
  int maxAttempts = defaultMaxAttempts,
  Duration retryDelay = defaultRetryDelay,
}) async {
  if (maxAttempts < 1) {
    throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be at least 1');
  }

  for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      return await _fetchJsonObject(uri: uri, token: token, client: client);
    } on _FootballDataStatusException {
      rethrow;
    } on IOException catch (error) {
      if (attempt == maxAttempts) {
        throw HttpException(
          'football-data.org request failed after $maxAttempts attempts: '
          '$error',
          uri: uri,
        );
      }
      await Future<void>.delayed(retryDelay);
    }
  }

  throw StateError('unreachable');
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
    throw _FootballDataStatusException(
      'football-data.org returned ${response.statusCode}: $body',
      uri: uri,
    );
  }

  return decodeJsonObject(body, uri.toString());
}

Map<String, Object?> decodeJsonObject(String source, String description) {
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

final class _FootballDataStatusException extends HttpException {
  _FootballDataStatusException(super.message, {super.uri});
}
