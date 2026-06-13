class FootballDataMapper {
  FootballDataMapper._({
    required Map<int, String> matchIdsByProviderId,
    required Map<int, String> teamIdsByProviderId,
  }) : _matchIdsByProviderId = Map.unmodifiable(matchIdsByProviderId),
       _teamIdsByProviderId = Map.unmodifiable(teamIdsByProviderId);

  factory FootballDataMapper.fromBaseline(Map<String, Object?> baseline) {
    return FootballDataMapper._(
      matchIdsByProviderId: _providerIdsByAppId(baseline, 'matches'),
      teamIdsByProviderId: _providerIdsByAppId(baseline, 'teams'),
    );
  }

  final Map<int, String> _matchIdsByProviderId;
  final Map<int, String> _teamIdsByProviderId;

  Map<String, Object?> mapMatchesResponse(Map<String, Object?> response) {
    return {
      'schemaVersion': 1,
      'source': 'football-data.org',
      'lastUpdated': DateTime.now().toUtc().toIso8601String(),
      'matches': _requiredObjectList(
        response,
        'matches',
      ).map(_mapMatch).toList(growable: false),
      'groupStandings': <Object?>[],
    };
  }

  Map<String, Object?> _mapMatch(Map<String, Object?> match) {
    final providerMatchId = _requiredInt(match, 'id');
    final matchId = _matchIdsByProviderId[providerMatchId];
    if (matchId == null) {
      throw FormatException(
        'No baseline match found for provider match id $providerMatchId.',
      );
    }

    final score = _requiredObject(match, 'score');
    final fullTime = _requiredObject(score, 'fullTime');
    final penalties = _optionalObject(score, 'penalties');
    final homeProviderTeamId = _requiredInt(
      _requiredObject(match, 'homeTeam'),
      'id',
    );
    final awayProviderTeamId = _requiredInt(
      _requiredObject(match, 'awayTeam'),
      'id',
    );
    final homeTeamId = _teamIdFor(homeProviderTeamId);
    final awayTeamId = _teamIdFor(awayProviderTeamId);

    return {
      'matchId': matchId,
      'providerId': providerMatchId,
      'status': _mapStatus(_requiredString(match, 'status')),
      'homeScore': _optionalInt(fullTime, 'home'),
      'awayScore': _optionalInt(fullTime, 'away'),
      'homePenaltyScore': penalties == null
          ? null
          : _optionalInt(penalties, 'home'),
      'awayPenaltyScore': penalties == null
          ? null
          : _optionalInt(penalties, 'away'),
      'winnerTeamId': _mapWinner(
        _optionalString(score, 'winner'),
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      ),
    };
  }

  String _teamIdFor(int providerTeamId) {
    final teamId = _teamIdsByProviderId[providerTeamId];
    if (teamId == null) {
      throw FormatException(
        'No baseline team found for provider team id $providerTeamId.',
      );
    }

    return teamId;
  }
}

Map<int, String> _providerIdsByAppId(
  Map<String, Object?> baseline,
  String key,
) {
  final mappings = <int, String>{};
  for (final item in _requiredObjectList(baseline, key)) {
    final appId = _requiredString(item, 'id');
    final providerId = _optionalInt(item, 'providerId');
    if (providerId != null) {
      final existingAppId = mappings[providerId];
      if (existingAppId != null) {
        throw FormatException(
          'Duplicate baseline providerId in $key: providerId $providerId '
          'already maps to $existingAppId, duplicate maps to $appId.',
        );
      }
      mappings[providerId] = appId;
    }
  }

  return mappings;
}

String _mapStatus(String status) {
  return switch (status) {
    'SCHEDULED' || 'TIMED' => 'scheduled',
    'IN_PLAY' || 'PAUSED' => 'live',
    'FINISHED' => 'completed',
    'POSTPONED' => 'postponed',
    'CANCELLED' || 'SUSPENDED' => 'cancelled',
    _ => throw FormatException('Unknown football-data status "$status".'),
  };
}

String? _mapWinner(
  String? winner, {
  required String homeTeamId,
  required String awayTeamId,
}) {
  return switch (winner) {
    'HOME_TEAM' => homeTeamId,
    'AWAY_TEAM' => awayTeamId,
    'DRAW' || null => null,
    _ => throw FormatException('Unknown football-data winner "$winner".'),
  };
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Expected "$key" to be a string.');
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }

  throw FormatException('Expected "$key" to be a string.');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }

  throw FormatException('Expected "$key" to be an int.');
}

int? _optionalInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }

  throw FormatException('Expected "$key" to be an int.');
}

Map<String, Object?> _requiredObject(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }

  throw FormatException('Expected "$key" to be an object.');
}

Map<String, Object?>? _optionalObject(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, Object?>) {
    return value;
  }

  throw FormatException('Expected "$key" to be an object.');
}

List<Map<String, Object?>> _requiredObjectList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is List) {
    return [
      for (final item in value)
        if (item is Map<String, Object?>)
          item
        else
          throw FormatException('Expected "$key" to contain objects.'),
    ];
  }

  throw FormatException('Expected "$key" to be a list.');
}
