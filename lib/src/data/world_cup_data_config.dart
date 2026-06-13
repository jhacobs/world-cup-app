class WorldCupDataConfig {
  const WorldCupDataConfig({
    this.assetPath = 'assets/data/world_cup_2026.json',
    this.updateUrl,
  });

  static WorldCupDataConfig fromEnvironment() {
    const updateUrl = String.fromEnvironment('WORLD_CUP_UPDATES_URL');

    return WorldCupDataConfig(
      updateUrl: updateUrl.isEmpty ? null : Uri.parse(updateUrl),
    );
  }

  final String assetPath;
  final Uri? updateUrl;
}
