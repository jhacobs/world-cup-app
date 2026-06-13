import 'package:flutter/services.dart';

class TournamentAssetDataSource {
  const TournamentAssetDataSource(this.bundle);

  final AssetBundle bundle;

  Future<String> load(String assetPath) {
    return bundle.loadString(assetPath);
  }
}
