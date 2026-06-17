import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/src/retrying_json_fetcher.dart';

void main() {
  test('retries transport failures before decoding JSON response', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
    });

    var requests = 0;
    server.listen((request) async {
      requests += 1;
      if (requests == 1) {
        final socket = await request.response.detachSocket();
        socket.destroy();
        return;
      }

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'ok': true}));
      await request.response.close();
    });

    final client = HttpClient();
    addTearDown(() {
      client.close(force: true);
    });

    final response = await fetchJsonObjectWithRetries(
      uri: Uri.http('${server.address.host}:${server.port}', '/matches'),
      token: 'token',
      client: client,
      retryDelay: Duration.zero,
    );

    expect(response, {'ok': true});
    expect(requests, 2);
  });
}
