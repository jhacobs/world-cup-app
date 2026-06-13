import 'tournament_models.dart';

class TournamentUpdate {
  TournamentUpdate({
    required this.schemaVersion,
    required this.source,
    required this.lastUpdated,
    required List<MatchUpdate> matches,
    List<GroupStanding> groupStandings = const [],
  }) : matches = List.unmodifiable(matches),
       groupStandings = List.unmodifiable(groupStandings);

  factory TournamentUpdate.fromJson(Map<String, Object?> json) {
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported tournament update schemaVersion: $schemaVersion',
      );
    }

    return TournamentUpdate(
      schemaVersion: schemaVersion,
      source: _requiredString(json, 'source'),
      lastUpdated: _requiredDateTimeUtc(json, 'lastUpdated'),
      matches: List.unmodifiable(
        _requiredObjectList(json, 'matches').map(MatchUpdate.fromJson),
      ),
      groupStandings: List.unmodifiable(
        _optionalObjectList(json, 'groupStandings').map(GroupStanding.fromJson),
      ),
    );
  }

  final int schemaVersion;
  final String source;
  final DateTime lastUpdated;
  final List<MatchUpdate> matches;
  final List<GroupStanding> groupStandings;
}

class MatchUpdate {
  const MatchUpdate({
    required this.matchId,
    required this.status,
    this.providerId,
    this.homeScore,
    this.awayScore,
    this.homePenaltyScore,
    this.awayPenaltyScore,
    this.winnerTeamId,
  });

  factory MatchUpdate.fromJson(Map<String, Object?> json) {
    return MatchUpdate(
      matchId: _requiredString(json, 'matchId'),
      status: MatchStatus.fromJson(_requiredString(json, 'status')),
      providerId: _optionalInt(json, 'providerId'),
      homeScore: _optionalInt(json, 'homeScore'),
      awayScore: _optionalInt(json, 'awayScore'),
      homePenaltyScore: _optionalInt(json, 'homePenaltyScore'),
      awayPenaltyScore: _optionalInt(json, 'awayPenaltyScore'),
      winnerTeamId: _optionalString(json, 'winnerTeamId'),
    );
  }

  final String matchId;
  final MatchStatus status;
  final int? providerId;
  final int? homeScore;
  final int? awayScore;
  final int? homePenaltyScore;
  final int? awayPenaltyScore;
  final String? winnerTeamId;
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

DateTime _requiredDateTimeUtc(Map<String, Object?> json, String key) {
  final value = _requiredString(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected "$key" to be a valid date string.');
  }
  if (!parsed.isUtc && !_hasExplicitTimeZone(value)) {
    throw FormatException('Expected "$key" to include a timezone.');
  }

  return parsed.toUtc();
}

bool _hasExplicitTimeZone(String value) {
  return RegExp(r'(?:[zZ]|[+-]\d{2}:?\d{2})$').hasMatch(value);
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

List<Map<String, Object?>> _optionalObjectList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    return const [];
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
