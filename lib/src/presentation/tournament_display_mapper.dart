import '../data/tournament_models.dart';
import 'tournament_display_models.dart';

DisplayTournament mapTournamentToDisplay(Tournament tournament) {
  final teamsById = {for (final team in tournament.teams) team.id: team};
  final groupsById = {for (final group in tournament.groups) group.id: group};
  final standingsByGroupId = {
    for (final standing in tournament.groupStandings)
      standing.groupId: standing,
  };

  final matches = [
    for (final match in tournament.matches)
      _mapMatch(match, teamsById, groupsById),
  ];

  matches.sort((a, b) {
    final aSource = tournament.matches.firstWhere((match) => match.id == a.id);
    final bSource = tournament.matches.firstWhere((match) => match.id == b.id);
    return aSource.kickoffUtc.compareTo(bSource.kickoffUtc);
  });

  return DisplayTournament(
    title: tournament.info.name.replaceFirst('FIFA ', ''),
    subtitle:
        '${_dateRange(tournament.info.startDate, tournament.info.endDate)} · USA, Canada & Mexico',
    matches: List.unmodifiable(matches),
    groups: [
      for (final group in tournament.groups)
        _mapGroup(group, teamsById, standingsByGroupId[group.id]),
    ],
    stageFilters: _stageFilters(matches),
  );
}

DisplayMatch _mapMatch(
  Match match,
  Map<String, Team> teamsById,
  Map<String, TournamentGroup> groupsById,
) {
  final localKickoff = match.kickoffUtc.toLocal();
  final group = match.groupId == null ? null : groupsById[match.groupId];

  return DisplayMatch(
    id: match.id,
    stage: _stageLabel(match),
    isKnockout: match.stage == TournamentStage.knockout,
    group: _groupShortName(group?.name),
    date: _monthDay(localKickoff),
    dayOfWeek: _weekday(localKickoff.weekday),
    time: _time(localKickoff),
    home: _mapMatchTeam(
      teamId: match.homeTeamId,
      placeholder: match.homePlaceholder,
      teamsById: teamsById,
    ),
    away: _mapMatchTeam(
      teamId: match.awayTeamId,
      placeholder: match.awayPlaceholder,
      teamsById: teamsById,
    ),
    isCompleted: match.status == MatchStatus.completed,
    homeScore: match.score?.home,
    awayScore: match.score?.away,
    winnerTeamId: match.winnerTeamId,
  );
}

DisplayGroup _mapGroup(
  TournamentGroup group,
  Map<String, Team> teamsById,
  GroupStanding? standing,
) {
  final entriesByTeamId = {
    for (final entry in standing?.entries ?? const <GroupStandingEntry>[])
      entry.teamId: entry,
  };

  return DisplayGroup(
    id: group.id,
    name: group.name,
    standings: [
      for (final teamId in group.teamIds)
        _mapStanding(teamsById[teamId], entriesByTeamId[teamId]),
    ],
  );
}

DisplayStanding _mapStanding(Team? team, GroupStandingEntry? entry) {
  return DisplayStanding(
    team: _mapTeam(team),
    played: entry?.played ?? 0,
    won: entry?.won ?? 0,
    drawn: entry?.drawn ?? 0,
    lost: entry?.lost ?? 0,
    goalDifference: entry?.goalDifference ?? 0,
    points: entry?.points ?? 0,
  );
}

DisplayTeam _mapMatchTeam({
  required String? teamId,
  required String? placeholder,
  required Map<String, Team> teamsById,
}) {
  final team = teamId == null ? null : teamsById[teamId];
  if (team != null) {
    return _mapTeam(team);
  }

  final name = placeholder ?? 'TBD';
  return DisplayTeam(id: name, name: name, code: name);
}

DisplayTeam _mapTeam(Team? team) {
  if (team == null) {
    return const DisplayTeam(id: 'TBD', name: 'TBD', code: 'TBD');
  }

  return DisplayTeam(id: team.id, name: team.name, code: team.shortName);
}

String _stageLabel(Match match) {
  if (match.stage == TournamentStage.group) {
    return 'Group Stage';
  }

  final id = match.id.toLowerCase();
  if (id.contains('round-32')) {
    return 'Round of 32';
  }
  if (id.contains('round-16')) {
    return 'Round of 16';
  }
  if (id.contains('quarter')) {
    return 'Quarter-finals';
  }
  if (id.contains('semi')) {
    return 'Semi-finals';
  }
  if (id.contains('third') || id.contains('3rd')) {
    return '3rd Place';
  }
  if (id.contains('final')) {
    return 'Final';
  }
  return 'Knockout';
}

List<String> _stageFilters(List<DisplayMatch> matches) {
  final stages = <String>{};
  for (final match in matches) {
    stages.add(match.stage);
  }
  return ['All', ...stages];
}

String? _groupShortName(String? groupName) {
  if (groupName == null) {
    return null;
  }
  return groupName.replaceFirst('Group ', '');
}

String _dateRange(DateTime start, DateTime end) {
  return '${_monthDay(start)} - ${_monthDay(end)}';
}

String _monthDay(DateTime dateTime) {
  return '${_month(dateTime.month)} ${dateTime.day}';
}

String _month(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

String _weekday(int weekday) {
  return const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

String _time(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
