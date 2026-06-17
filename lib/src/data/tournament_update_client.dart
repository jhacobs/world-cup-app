import 'dart:convert';
import 'dart:io';

typedef FetchUpdateString = Future<String> Function(Uri uri);

class TournamentUpdateClient {
  // ignore: prefer_initializing_formals, public API keeps `fetch` distinct from
  // the timeout-wrapped `fetch` method.
  const TournamentUpdateClient({
    FetchUpdateString? fetch,
    this.timeout = const Duration(seconds: 5),
    this.maxAttempts = 3,
    this.retryDelay = const Duration(milliseconds: 300),
  }) : fetchUpdateString = fetch;

  final FetchUpdateString? fetchUpdateString;
  final Duration timeout;
  final int maxAttempts;
  final Duration retryDelay;

  Future<String> fetch(Uri uri) {
    final fetch = fetchUpdateString;
    if (fetch != null) {
      return fetch(uri).timeout(timeout);
    }

    return _defaultFetch(
      uri,
      timeout: timeout,
      maxAttempts: maxAttempts,
      retryDelay: retryDelay,
    );
  }

  static Future<String> _defaultFetch(
    Uri uri, {
    required Duration timeout,
    required int maxAttempts,
    required Duration retryDelay,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        return await _fetchOnce(uri, timeout);
      } on _TournamentUpdateStatusException {
        rethrow;
      } on IOException catch (error) {
        if (attempt == maxAttempts) {
          throw HttpException(
            'Tournament update request failed after $maxAttempts attempts: '
            '$error',
            uri: uri,
          );
        }
        await Future<void>.delayed(retryDelay);
      }
    }

    throw StateError('unreachable');
  }

  static Future<String> _fetchOnce(Uri uri, Duration timeout) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      try {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw _TournamentUpdateStatusException(
            'Tournament update request failed with HTTP ${response.statusCode}.',
            uri: uri,
          );
        }

        return await utf8.decodeStream(response).timeout(timeout);
      } on _TournamentUpdateStatusException {
        rethrow;
      }
    } finally {
      client.close();
    }
  }
}

final class _TournamentUpdateStatusException extends HttpException {
  _TournamentUpdateStatusException(super.message, {super.uri});
}
