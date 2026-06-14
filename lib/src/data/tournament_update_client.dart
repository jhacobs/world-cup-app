import 'dart:convert';
import 'dart:io';

typedef FetchUpdateString = Future<String> Function(Uri uri);

class TournamentUpdateClient {
  // ignore: prefer_initializing_formals, public API keeps `fetch` distinct from
  // the timeout-wrapped `fetch` method.
  const TournamentUpdateClient({
    FetchUpdateString? fetch,
    this.timeout = const Duration(seconds: 5),
  }) : fetchUpdateString = fetch;

  final FetchUpdateString? fetchUpdateString;
  final Duration timeout;

  Future<String> fetch(Uri uri) {
    final fetch = fetchUpdateString;
    if (fetch != null) {
      return fetch(uri).timeout(timeout);
    }

    return _defaultFetch(uri, timeout);
  }

  static Future<String> _defaultFetch(Uri uri, Duration timeout) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Tournament update request failed with HTTP ${response.statusCode}.',
          uri: uri,
        );
      }

      return utf8.decodeStream(response).timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }
}
