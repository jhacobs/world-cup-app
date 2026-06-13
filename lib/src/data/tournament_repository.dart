import 'dart:convert';

import 'tournament_merger.dart';
import 'tournament_models.dart';
import 'tournament_update_client.dart';
import 'tournament_update_models.dart';
import 'world_cup_data_config.dart';

typedef LoadAssetString = Future<String> Function(String assetPath);

class TournamentRepository {
  const TournamentRepository({
    required this.config,
    required this.loadAssetString,
    this.fetchUpdateString,
  });

  final WorldCupDataConfig config;
  final LoadAssetString loadAssetString;
  final FetchUpdateString? fetchUpdateString;

  Future<Tournament> loadTournament() async {
    final baselineJson = await loadAssetString(config.assetPath);
    final baseline = Tournament.fromJson(_decodeJsonObject(baselineJson));
    final updateUrl = config.updateUrl;
    if (updateUrl == null) {
      return baseline;
    }

    try {
      final updateJson =
          await (fetchUpdateString ?? const TournamentUpdateClient().fetch)
              .call(updateUrl);
      final update = TournamentUpdate.fromJson(_decodeJsonObject(updateJson));
      return TournamentMerger.merge(baseline, update);
    } on Exception {
      return baseline;
    }
  }

  static Map<String, Object?> _decodeJsonObject(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }

    throw const FormatException('Expected JSON object.');
  }
}
