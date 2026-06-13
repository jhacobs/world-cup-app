enum TournamentStage {
  group,
  knockout;

  factory TournamentStage.fromJson(Object? value) {
    return switch (value) {
      'group' => TournamentStage.group,
      'knockout' => TournamentStage.knockout,
      _ => throw FormatException('Unsupported tournament stage: $value'),
    };
  }

  String toJson() {
    return switch (this) {
      TournamentStage.group => 'group',
      TournamentStage.knockout => 'knockout',
    };
  }
}

enum MatchStatus {
  scheduled,
  live,
  completed,
  postponed,
  cancelled;

  factory MatchStatus.fromJson(Object? value) {
    return switch (value) {
      'scheduled' => MatchStatus.scheduled,
      'live' => MatchStatus.live,
      'completed' => MatchStatus.completed,
      'postponed' => MatchStatus.postponed,
      'cancelled' => MatchStatus.cancelled,
      _ => throw FormatException('Unsupported match status: $value'),
    };
  }

  String toJson() {
    return switch (this) {
      MatchStatus.scheduled => 'scheduled',
      MatchStatus.live => 'live',
      MatchStatus.completed => 'completed',
      MatchStatus.postponed => 'postponed',
      MatchStatus.cancelled => 'cancelled',
    };
  }
}

class Tournament {
  const Tournament({
    required this.schemaVersion,
    required this.info,
    required this.teams,
    required this.groups,
    required this.venues,
    required this.matches,
    this.groupStandings = const [],
  });

  factory Tournament.fromJson(Map<String, Object?> json) {
    final schemaVersion = _requiredInt(json, 'schemaVersion');
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported tournament schemaVersion: $schemaVersion',
      );
    }

    return Tournament(
      schemaVersion: schemaVersion,
      info: TournamentInfo.fromJson(_requiredObject(json, 'info')),
      teams: _requiredObjectList(
        json,
        'teams',
      ).map(Team.fromJson).toList(growable: false),
      groups: _requiredObjectList(
        json,
        'groups',
      ).map(TournamentGroup.fromJson).toList(growable: false),
      venues: _requiredObjectList(
        json,
        'venues',
      ).map(Venue.fromJson).toList(growable: false),
      matches: _requiredObjectList(
        json,
        'matches',
      ).map(Match.fromJson).toList(growable: false),
      groupStandings: _optionalObjectList(
        json,
        'groupStandings',
      ).map(GroupStanding.fromJson).toList(growable: false),
    );
  }

  final int schemaVersion;
  final TournamentInfo info;
  final List<Team> teams;
  final List<TournamentGroup> groups;
  final List<Venue> venues;
  final List<Match> matches;
  final List<GroupStanding> groupStandings;

  Tournament copyWith({
    List<Match>? matches,
    List<GroupStanding>? groupStandings,
  }) {
    return Tournament(
      schemaVersion: schemaVersion,
      info: info,
      teams: teams,
      groups: groups,
      venues: venues,
      matches: matches ?? this.matches,
      groupStandings: groupStandings ?? this.groupStandings,
    );
  }
}

class TournamentInfo {
  const TournamentInfo({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory TournamentInfo.fromJson(Map<String, Object?> json) {
    return TournamentInfo(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      startDate: _requiredDateTime(json, 'startDate'),
      endDate: _requiredDateTime(json, 'endDate'),
    );
  }

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
}

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.countryCode,
    this.groupId,
    this.providerId,
  });

  factory Team.fromJson(Map<String, Object?> json) {
    return Team(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      shortName: _requiredString(json, 'shortName'),
      countryCode: _requiredString(json, 'countryCode'),
      groupId: _optionalString(json, 'groupId'),
      providerId: _optionalInt(json, 'providerId'),
    );
  }

  final String id;
  final String name;
  final String shortName;
  final String countryCode;
  final String? groupId;
  final int? providerId;
}

class TournamentGroup {
  const TournamentGroup({
    required this.id,
    required this.name,
    required this.teamIds,
  });

  factory TournamentGroup.fromJson(Map<String, Object?> json) {
    return TournamentGroup(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      teamIds: _requiredStringList(json, 'teamIds'),
    );
  }

  final String id;
  final String name;
  final List<String> teamIds;
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
  });

  factory Venue.fromJson(Map<String, Object?> json) {
    return Venue(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      city: _requiredString(json, 'city'),
      country: _requiredString(json, 'country'),
    );
  }

  final String id;
  final String name;
  final String city;
  final String country;
}

class Match {
  const Match({
    required this.id,
    this.providerId,
    required this.stage,
    this.groupId,
    required this.kickoffUtc,
    required this.venueId,
    this.homeTeamId,
    this.awayTeamId,
    this.homePlaceholder,
    this.awayPlaceholder,
    this.status = MatchStatus.scheduled,
    this.score,
    this.winnerTeamId,
  });

  factory Match.fromJson(Map<String, Object?> json) {
    return Match(
      id: _requiredString(json, 'id'),
      providerId: _optionalInt(json, 'providerId'),
      stage: TournamentStage.fromJson(_requiredString(json, 'stage')),
      groupId: _optionalString(json, 'groupId'),
      kickoffUtc: _requiredDateTimeUtc(json, 'kickoffUtc'),
      venueId: _requiredString(json, 'venueId'),
      homeTeamId: _optionalString(json, 'homeTeamId'),
      awayTeamId: _optionalString(json, 'awayTeamId'),
      homePlaceholder: _optionalString(json, 'homePlaceholder'),
      awayPlaceholder: _optionalString(json, 'awayPlaceholder'),
      status: MatchStatus.scheduled,
      score: null,
      winnerTeamId: null,
    );
  }

  final String id;
  final int? providerId;
  final TournamentStage stage;
  final String? groupId;
  final DateTime kickoffUtc;
  final String venueId;
  final String? homeTeamId;
  final String? awayTeamId;
  final String? homePlaceholder;
  final String? awayPlaceholder;
  final MatchStatus status;
  final MatchScore? score;
  final String? winnerTeamId;

  Match copyWith({
    int? providerId,
    MatchStatus? status,
    MatchScore? score,
    String? winnerTeamId,
  }) {
    return Match(
      id: id,
      providerId: providerId ?? this.providerId,
      stage: stage,
      groupId: groupId,
      kickoffUtc: kickoffUtc,
      venueId: venueId,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homePlaceholder: homePlaceholder,
      awayPlaceholder: awayPlaceholder,
      status: status ?? this.status,
      score: score ?? this.score,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
    );
  }
}

class MatchScore {
  const MatchScore({
    required this.home,
    required this.away,
    this.homePenalty,
    this.awayPenalty,
  });

  factory MatchScore.fromJson(Map<String, Object?> json) {
    return MatchScore(
      home: _requiredInt(json, 'home'),
      away: _requiredInt(json, 'away'),
      homePenalty: _optionalInt(json, 'homePenalty'),
      awayPenalty: _optionalInt(json, 'awayPenalty'),
    );
  }

  final int home;
  final int away;
  final int? homePenalty;
  final int? awayPenalty;
}

class GroupStanding {
  const GroupStanding({required this.groupId, required this.entries});

  factory GroupStanding.fromJson(Map<String, Object?> json) {
    return GroupStanding(
      groupId: _requiredString(json, 'groupId'),
      entries: _requiredObjectList(
        json,
        'entries',
      ).map(GroupStandingEntry.fromJson).toList(growable: false),
    );
  }

  final String groupId;
  final List<GroupStandingEntry> entries;
}

class GroupStandingEntry {
  const GroupStandingEntry({
    required this.teamId,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });

  factory GroupStandingEntry.fromJson(Map<String, Object?> json) {
    return GroupStandingEntry(
      teamId: _requiredString(json, 'teamId'),
      played: _requiredInt(json, 'played'),
      won: _requiredInt(json, 'won'),
      drawn: _requiredInt(json, 'drawn'),
      lost: _requiredInt(json, 'lost'),
      goalsFor: _requiredInt(json, 'goalsFor'),
      goalsAgainst: _requiredInt(json, 'goalsAgainst'),
      goalDifference: _requiredInt(json, 'goalDifference'),
      points: _requiredInt(json, 'points'),
    );
  }

  final String teamId;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
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

DateTime _requiredDateTime(Map<String, Object?> json, String key) {
  final value = _requiredString(json, key);
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw FormatException('Expected "$key" to be a valid date string.');
  }
}

DateTime _requiredDateTimeUtc(Map<String, Object?> json, String key) {
  return _requiredDateTime(json, key).toUtc();
}

Map<String, Object?> _requiredObject(Map<String, Object?> json, String key) {
  final value = json[key];
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

List<String> _requiredStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List) {
    return [
      for (final item in value)
        if (item is String)
          item
        else
          throw FormatException('Expected "$key" to contain strings.'),
    ];
  }

  throw FormatException('Expected "$key" to be a list.');
}
