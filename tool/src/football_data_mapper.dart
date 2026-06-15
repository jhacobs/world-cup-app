class FootballDataMapper {
  FootballDataMapper._({
    required Map<int, String> matchIdsByProviderId,
    required Map<int, String> teamIdsByProviderId,
    required Map<String, String> groupIdsByProviderName,
    required Set<String> baselineGroupIds,
  }) : _matchIdsByProviderId = Map.unmodifiable(matchIdsByProviderId),
       _teamIdsByProviderId = Map.unmodifiable(teamIdsByProviderId),
       _groupIdsByProviderName = Map.unmodifiable(groupIdsByProviderName),
       _baselineGroupIds = Set.unmodifiable(baselineGroupIds);

  factory FootballDataMapper.fromBaseline(Map<String, Object?> baseline) {
    final groupIdsByProviderName = _providerGroupNamesByAppId(baseline);
    final matchIdsByProviderId = _providerIdsByAppId(baseline, 'matches');
    final teamIdsByProviderId = _providerIdsByAppId(baseline, 'teams');
    _requireProviderMappings(matchIdsByProviderId, 'matches');
    _requireProviderMappings(teamIdsByProviderId, 'teams');

    return FootballDataMapper._(
      matchIdsByProviderId: matchIdsByProviderId,
      teamIdsByProviderId: teamIdsByProviderId,
      groupIdsByProviderName: groupIdsByProviderName,
      baselineGroupIds: groupIdsByProviderName.values.toSet(),
    );
  }

  final Map<int, String> _matchIdsByProviderId;
  final Map<int, String> _teamIdsByProviderId;
  final Map<String, String> _groupIdsByProviderName;
  final Set<String> _baselineGroupIds;

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

  List<Map<String, Object?>> mapStandingsResponse(
    Map<String, Object?> response,
  ) {
    final standings = _optionalObjectList(response, 'standings');
    if (standings == null) {
      return const [];
    }

    final mappedStandings = <Map<String, Object?>>[];
    final seenGroupIds = <String>{};
    for (final standing in standings) {
      final providerGroupName = _requiredString(standing, 'group');
      final mappedStanding = _mapStanding(standing);
      final groupId = _requiredString(mappedStanding, 'groupId');
      if (!seenGroupIds.add(groupId)) {
        throw FormatException(
          'Duplicate standings group $groupId from provider group '
          '$providerGroupName.',
        );
      }
      mappedStandings.add(mappedStanding);
    }

    if (mappedStandings.isNotEmpty) {
      final missingGroupIds = _baselineGroupIds.difference(seenGroupIds);
      final extraGroupIds = seenGroupIds.difference(_baselineGroupIds);
      if (missingGroupIds.isNotEmpty) {
        throw FormatException(
          'Missing standings groups: ${_sortedStrings(missingGroupIds).join(', ')}.',
        );
      }
      if (extraGroupIds.isNotEmpty) {
        throw FormatException(
          'Unexpected standings groups: ${_sortedStrings(extraGroupIds).join(', ')}.',
        );
      }
    }

    return List.unmodifiable(mappedStandings);
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
    final homeProviderTeamId = _optionalInt(
      _requiredObject(match, 'homeTeam'),
      'id',
    );
    final awayProviderTeamId = _optionalInt(
      _requiredObject(match, 'awayTeam'),
      'id',
    );
    final homeTeamId = homeProviderTeamId == null
        ? null
        : _teamIdFor(homeProviderTeamId);
    final awayTeamId = awayProviderTeamId == null
        ? null
        : _teamIdFor(awayProviderTeamId);

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

  Map<String, Object?> _mapStanding(Map<String, Object?> standing) {
    final providerGroupName = _requiredString(standing, 'group');
    final groupId =
        _groupIdsByProviderName[_normalizeProviderGroupName(providerGroupName)];
    if (groupId == null) {
      throw FormatException(
        'No baseline group found for provider group $providerGroupName.',
      );
    }

    return {
      'groupId': groupId,
      'entries': _requiredObjectList(
        standing,
        'table',
      ).map(_mapStandingEntry).toList(growable: false),
    };
  }

  Map<String, Object?> _mapStandingEntry(Map<String, Object?> entry) {
    final providerTeamId = _requiredInt(_requiredObject(entry, 'team'), 'id');

    return {
      'teamId': _teamIdFor(providerTeamId),
      'played': _requiredInt(entry, 'playedGames'),
      'won': _requiredInt(entry, 'won'),
      'drawn': _requiredInt(entry, 'draw'),
      'lost': _requiredInt(entry, 'lost'),
      'goalsFor': _requiredInt(entry, 'goalsFor'),
      'goalsAgainst': _requiredInt(entry, 'goalsAgainst'),
      'goalDifference': _requiredInt(entry, 'goalDifference'),
      'points': _requiredInt(entry, 'points'),
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

void _requireProviderMappings(Map<int, String> mappings, String key) {
  if (mappings.isNotEmpty) {
    return;
  }

  throw FormatException(
    'Baseline $key must include football-data.org providerId values before '
    'live updates can be generated.',
  );
}

Map<String, String> _providerGroupNamesByAppId(Map<String, Object?> baseline) {
  final mappings = <String, String>{};
  for (final item in _requiredObjectList(baseline, 'groups')) {
    final appId = _requiredString(item, 'id');
    final providerName = _providerGroupNameFor(appId);
    final existingAppId = mappings[providerName];
    if (existingAppId != null) {
      throw FormatException(
        'Duplicate baseline group provider name $providerName: '
        'already maps to $existingAppId, duplicate maps to $appId.',
      );
    }
    mappings[providerName] = appId;
  }

  return mappings;
}

String _providerGroupNameFor(String appGroupId) {
  const prefix = 'group-';
  if (!appGroupId.startsWith(prefix)) {
    throw FormatException(
      'Expected group id "$appGroupId" to start with group-.',
    );
  }

  final suffix = appGroupId.substring(prefix.length);
  if (suffix.isEmpty) {
    throw FormatException('Expected group id "$appGroupId" to have a suffix.');
  }

  return 'GROUP_${suffix.toUpperCase()}';
}

String _normalizeProviderGroupName(String providerGroupName) {
  final normalized = providerGroupName.trim().toUpperCase().replaceAll(
    ' ',
    '_',
  );
  if (!normalized.startsWith('GROUP_')) {
    return providerGroupName;
  }

  return normalized;
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
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
  required String? homeTeamId,
  required String? awayTeamId,
}) {
  return switch (winner) {
    'HOME_TEAM' => homeTeamId ?? _missingWinnerTeamId('home'),
    'AWAY_TEAM' => awayTeamId ?? _missingWinnerTeamId('away'),
    'DRAW' || null => null,
    _ => throw FormatException('Unknown football-data winner "$winner".'),
  };
}

Never _missingWinnerTeamId(String side) {
  throw FormatException('Cannot map $side winner before team is known.');
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

List<Map<String, Object?>>? _optionalObjectList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return null;
  }
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
