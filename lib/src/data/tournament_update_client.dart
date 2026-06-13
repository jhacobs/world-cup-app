import 'dart:convert';
import 'dart:io';

typedef FetchUpdateString = Future<String> Function(Uri uri);

class TournamentUpdateClient {
  const TournamentUpdateClient({this.fetch = _defaultFetch});

  final FetchUpdateString fetch;

  static Future<String> _defaultFetch(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Tournament update request failed with HTTP ${response.statusCode}.',
          uri: uri,
        );
      }

      return utf8.decodeStream(response);
    } finally {
      client.close(force: true);
    }
  }
}
