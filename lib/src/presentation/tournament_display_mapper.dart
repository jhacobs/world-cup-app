import '../data/tournament_models.dart';
import 'tournament_display_models.dart';

DisplayTournament mapTournamentToDisplay(Tournament tournament) {
  final teamsById = {for (final team in tournament.teams) team.id: team};
  final groupsById = {for (final group in tournament.groups) group.id: group};
  final standingsByGroupId = {
    for (final standing in tournament.groupStandings)
      standing.groupId: standing,
  };
  final matchesByFifaNumber = {
    for (final match in tournament.matches)
      if (match.fifaMatchNumber != null) match.fifaMatchNumber!: match,
  };

  final matches = [
    for (final match in tournament.matches)
      _mapMatch(
        match,
        teamsById,
        groupsById,
        standingsByGroupId,
        matchesByFifaNumber,
      ),
  ];

  matches.sort((a, b) {
    final aSource = tournament.matches.firstWhere((match) => match.id == a.id);
    final bSource = tournament.matches.firstWhere((match) => match.id == b.id);
    return aSource.kickoffUtc.compareTo(bSource.kickoffUtc);
  });

  return DisplayTournament(
    title: tournament.info.name.replaceFirst('FIFA ', ''),
    subtitle:
        '${_dateRange(tournament.info.startDate, tournament.info.endDate)} · VS, Canada en Mexico',
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
  Map<String, GroupStanding> standingsByGroupId,
  Map<int, Match> matchesByFifaNumber,
) {
  final localKickoff = match.kickoffUtc.toLocal();
  final group = match.groupId == null ? null : groupsById[match.groupId];
  final slotRules = _knockoutSlotRules[match.fifaMatchNumber];

  return DisplayMatch(
    id: match.id,
    fifaMatchNumber: match.fifaMatchNumber,
    stage: _stageLabel(match),
    isKnockout: match.stage == TournamentStage.knockout,
    group: _groupShortName(group?.name),
    localDate: _dateOnly(localKickoff),
    date: _monthDay(localKickoff),
    dayOfWeek: _weekday(localKickoff.weekday),
    time: _time(localKickoff),
    home: _mapMatchTeam(
      teamId: match.homeTeamId,
      placeholder: _effectivePlaceholder(
        match.homePlaceholder,
        slotRules?.homePlaceholder,
      ),
      teamsById: teamsById,
      standingsByGroupId: standingsByGroupId,
      matchesByFifaNumber: matchesByFifaNumber,
    ),
    away: _mapMatchTeam(
      teamId: match.awayTeamId,
      placeholder: _effectivePlaceholder(
        match.awayPlaceholder,
        slotRules?.awayPlaceholder,
      ),
      teamsById: teamsById,
      standingsByGroupId: standingsByGroupId,
      matchesByFifaNumber: matchesByFifaNumber,
    ),
    isCompleted: match.status == MatchStatus.completed,
    homeScore: match.score?.home,
    awayScore: match.score?.away,
    winnerTeamId: match.winnerTeamId,
  );
}

String? _effectivePlaceholder(String? placeholder, String? fallback) {
  if (placeholder == null || placeholder == 'TBD') {
    return fallback ?? placeholder;
  }
  return placeholder;
}

DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
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
    name: _groupName(group.name),
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
  required Map<String, GroupStanding> standingsByGroupId,
  required Map<int, Match> matchesByFifaNumber,
}) {
  final team = teamId == null ? null : teamsById[teamId];
  if (team != null) {
    return _mapTeam(team);
  }

  final name = _placeholderName(placeholder);
  final projection = _projectedTeam(
    placeholder,
    standingsByGroupId,
    teamsById,
    matchesByFifaNumber,
  );
  if (projection != null) {
    return DisplayTeam(
      id: projection.team.id,
      name: _teamDisplayName(projection.team),
      code: projection.team.shortName,
      qualifierLabel: name,
      isProjected: true,
      projectionUncertain: projection.isUncertain,
    );
  }

  return DisplayTeam(id: name, name: name, code: name, qualifierLabel: name);
}

DisplayTeam _mapTeam(Team? team) {
  if (team == null) {
    return const DisplayTeam(id: 'N.t.b.', name: 'N.t.b.', code: 'N.t.b.');
  }

  return DisplayTeam(
    id: team.id,
    name: _teamDisplayName(team),
    code: team.shortName,
  );
}

String _teamDisplayName(Team team) {
  return _dutchTeamNames[team.id] ?? team.name;
}

const _dutchTeamNames = {
  'algeria': 'Algerije',
  'argentina': 'Argentinië',
  'australia': 'Australië',
  'austria': 'Oostenrijk',
  'belgium': 'België',
  'bosnia-herzegovina': 'Bosnië en Herzegovina',
  'brazil': 'Brazilië',
  'cape-verde-islands': 'Kaapverdië',
  'colombia': 'Colombia',
  'congo-dr': 'DR Congo',
  'croatia': 'Kroatië',
  'czechia': 'Tsjechië',
  'egypt': 'Egypte',
  'england': 'Engeland',
  'france': 'Frankrijk',
  'germany': 'Duitsland',
  'ghana': 'Ghana',
  'haiti': 'Haïti',
  'iran': 'Iran',
  'iraq': 'Irak',
  'ivory-coast': 'Ivoorkust',
  'japan': 'Japan',
  'jordan': 'Jordanië',
  'mexico': 'Mexico',
  'morocco': 'Marokko',
  'netherlands': 'Nederland',
  'new-zealand': 'Nieuw-Zeeland',
  'norway': 'Noorwegen',
  'panama': 'Panama',
  'paraguay': 'Paraguay',
  'portugal': 'Portugal',
  'qatar': 'Qatar',
  'saudi-arabia': 'Saoedi-Arabië',
  'scotland': 'Schotland',
  'senegal': 'Senegal',
  'south-africa': 'Zuid-Afrika',
  'south-korea': 'Zuid-Korea',
  'spain': 'Spanje',
  'sweden': 'Zweden',
  'switzerland': 'Zwitserland',
  'tunisia': 'Tunesië',
  'turkey': 'Turkije',
  'united-states': 'Verenigde Staten',
  'uruguay': 'Uruguay',
  'uzbekistan': 'Oezbekistan',
};

String _stageLabel(Match match) {
  if (match.stage == TournamentStage.group) {
    return 'Groepsfase';
  }

  final id = match.id.toLowerCase();
  if (id.contains('round-32')) {
    return 'Ronde van 32';
  }
  if (id.contains('round-16')) {
    return 'Achtste finales';
  }
  if (id.contains('quarter')) {
    return 'Kwartfinales';
  }
  if (id.contains('semi')) {
    return 'Halve finales';
  }
  if (id.contains('third') || id.contains('3rd')) {
    return '3e plaats';
  }
  if (id.contains('final')) {
    return 'Finale';
  }
  return 'Knock-out';
}

List<String> _stageFilters(List<DisplayMatch> matches) {
  final stages = <String>{};
  for (final match in matches) {
    stages.add(match.stage);
  }
  return ['Alles', ...stages];
}

String? _groupShortName(String? groupName) {
  if (groupName == null) {
    return null;
  }
  return groupName.replaceFirst('Group ', '');
}

String _groupName(String groupName) {
  return groupName.replaceFirst('Group ', 'Groep ');
}

String _placeholderName(String? placeholder) {
  if (placeholder == null || placeholder == 'TBD') {
    return 'N.t.b.';
  }

  final winnerMatch = RegExp(r'^Winner Group ([A-Z])$').firstMatch(placeholder);
  if (winnerMatch != null) {
    return 'Winnaar groep ${winnerMatch.group(1)}';
  }

  final runnerUpMatch = RegExp(
    r'^Runner-up Group ([A-Z])$',
  ).firstMatch(placeholder);
  if (runnerUpMatch != null) {
    return 'Nummer 2 groep ${runnerUpMatch.group(1)}';
  }

  final bestThirdMatch = RegExp(
    r'^Best 3rd place Group ([A-Z](?:/[A-Z])*)$',
  ).firstMatch(placeholder);
  if (bestThirdMatch != null) {
    return 'Beste nummer 3 groep ${bestThirdMatch.group(1)}';
  }

  final winnerSourceMatch = RegExp(
    r'^Winner Match (\d+)$',
  ).firstMatch(placeholder);
  if (winnerSourceMatch != null) {
    return 'Winnaar wedstrijd ${winnerSourceMatch.group(1)}';
  }

  final loserSourceMatch = RegExp(
    r'^Loser Match (\d+)$',
  ).firstMatch(placeholder);
  if (loserSourceMatch != null) {
    return 'Verliezer wedstrijd ${loserSourceMatch.group(1)}';
  }

  return placeholder;
}

_ProjectedTeam? _projectedTeam(
  String? placeholder,
  Map<String, GroupStanding> standingsByGroupId,
  Map<String, Team> teamsById,
  Map<int, Match> matchesByFifaNumber,
) {
  if (placeholder == null) {
    return null;
  }

  final winnerMatch = RegExp(r'^Winner Group ([A-Z])$').firstMatch(placeholder);
  if (winnerMatch != null) {
    final team = _projectedGroupTeam(
      winnerMatch.group(1)!,
      0,
      standingsByGroupId,
      teamsById,
    );
    return team == null ? null : _ProjectedTeam(team: team);
  }

  final runnerUpMatch = RegExp(
    r'^Runner-up Group ([A-Z])$',
  ).firstMatch(placeholder);
  if (runnerUpMatch != null) {
    final team = _projectedGroupTeam(
      runnerUpMatch.group(1)!,
      1,
      standingsByGroupId,
      teamsById,
    );
    return team == null ? null : _ProjectedTeam(team: team);
  }

  final bestThirdMatch = RegExp(
    r'^Best 3rd place Group ([A-Z](?:/[A-Z])*)$',
  ).firstMatch(placeholder);
  if (bestThirdMatch != null) {
    final team = _projectedBestThirdTeam(
      bestThirdMatch.group(1)!.split('/'),
      standingsByGroupId,
      teamsById,
    );
    return team == null ? null : _ProjectedTeam(team: team, isUncertain: true);
  }

  final winnerSourceMatch = RegExp(
    r'^Winner Match (\d+)$',
  ).firstMatch(placeholder);
  if (winnerSourceMatch != null) {
    final team = _sourceMatchTeam(
      int.parse(winnerSourceMatch.group(1)!),
      _SourceMatchOutcome.winner,
      matchesByFifaNumber,
      teamsById,
    );
    return team == null ? null : _ProjectedTeam(team: team);
  }

  final loserSourceMatch = RegExp(
    r'^Loser Match (\d+)$',
  ).firstMatch(placeholder);
  if (loserSourceMatch != null) {
    final team = _sourceMatchTeam(
      int.parse(loserSourceMatch.group(1)!),
      _SourceMatchOutcome.loser,
      matchesByFifaNumber,
      teamsById,
    );
    return team == null ? null : _ProjectedTeam(team: team);
  }

  return null;
}

Team? _projectedGroupTeam(
  String groupLetter,
  int index,
  Map<String, GroupStanding> standingsByGroupId,
  Map<String, Team> teamsById,
) {
  final standing = standingsByGroupId['group-${groupLetter.toLowerCase()}'];
  if (standing == null || standing.entries.length <= index) {
    return null;
  }
  return teamsById[standing.entries[index].teamId];
}

Team? _sourceMatchTeam(
  int fifaMatchNumber,
  _SourceMatchOutcome outcome,
  Map<int, Match> matchesByFifaNumber,
  Map<String, Team> teamsById,
) {
  final sourceMatch = matchesByFifaNumber[fifaMatchNumber];
  if (sourceMatch == null || sourceMatch.status != MatchStatus.completed) {
    return null;
  }

  final winnerTeamId = _winnerTeamId(sourceMatch);
  if (winnerTeamId == null) {
    return null;
  }
  if (outcome == _SourceMatchOutcome.winner) {
    return teamsById[winnerTeamId];
  }

  final homeTeamId = sourceMatch.homeTeamId;
  final awayTeamId = sourceMatch.awayTeamId;
  if (homeTeamId == null || awayTeamId == null) {
    return null;
  }
  return teamsById[winnerTeamId == homeTeamId ? awayTeamId : homeTeamId];
}

String? _winnerTeamId(Match match) {
  if (match.winnerTeamId != null) {
    return match.winnerTeamId;
  }

  final score = match.score;
  if (score == null) {
    return null;
  }
  if (score.home > score.away) {
    return match.homeTeamId;
  }
  if (score.away > score.home) {
    return match.awayTeamId;
  }
  final homePenalty = score.homePenalty;
  final awayPenalty = score.awayPenalty;
  if (homePenalty != null && awayPenalty != null) {
    if (homePenalty > awayPenalty) {
      return match.homeTeamId;
    }
    if (awayPenalty > homePenalty) {
      return match.awayTeamId;
    }
  }
  return null;
}

Team? _projectedBestThirdTeam(
  List<String> eligibleGroupLetters,
  Map<String, GroupStanding> standingsByGroupId,
  Map<String, Team> teamsById,
) {
  final eligibleGroupIds = {
    for (final letter in eligibleGroupLetters) 'group-${letter.toLowerCase()}',
  };
  final thirdPlaceEntries = [
    for (final standing in standingsByGroupId.values)
      if (standing.entries.length > 2)
        _ThirdPlaceProjection(
          groupId: standing.groupId,
          entry: standing.entries[2],
        ),
  ]..sort(_compareThirdPlaceProjections);

  final advancingThirdPlaceEntries = thirdPlaceEntries.take(8);
  for (final projection in advancingThirdPlaceEntries) {
    if (eligibleGroupIds.contains(projection.groupId)) {
      return teamsById[projection.entry.teamId];
    }
  }
  return null;
}

int _compareThirdPlaceProjections(
  _ThirdPlaceProjection a,
  _ThirdPlaceProjection b,
) {
  final points = b.entry.points.compareTo(a.entry.points);
  if (points != 0) return points;

  final goalDifference = b.entry.goalDifference.compareTo(
    a.entry.goalDifference,
  );
  if (goalDifference != 0) return goalDifference;

  final goalsFor = b.entry.goalsFor.compareTo(a.entry.goalsFor);
  if (goalsFor != 0) return goalsFor;

  return a.groupId.compareTo(b.groupId);
}

class _ProjectedTeam {
  const _ProjectedTeam({required this.team, this.isUncertain = false});

  final Team team;
  final bool isUncertain;
}

class _ThirdPlaceProjection {
  const _ThirdPlaceProjection({required this.groupId, required this.entry});

  final String groupId;
  final GroupStandingEntry entry;
}

enum _SourceMatchOutcome { winner, loser }

class _KnockoutSlotRules {
  const _KnockoutSlotRules({
    required this.homePlaceholder,
    required this.awayPlaceholder,
  });

  final String homePlaceholder;
  final String awayPlaceholder;
}

const _knockoutSlotRules = {
  73: _KnockoutSlotRules(
    homePlaceholder: 'Runner-up Group A',
    awayPlaceholder: 'Runner-up Group B',
  ),
  74: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group E',
    awayPlaceholder: 'Best 3rd place Group A/B/C/D/F',
  ),
  75: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group F',
    awayPlaceholder: 'Runner-up Group C',
  ),
  76: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group C',
    awayPlaceholder: 'Runner-up Group F',
  ),
  77: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group I',
    awayPlaceholder: 'Best 3rd place Group C/D/F/G/H',
  ),
  78: _KnockoutSlotRules(
    homePlaceholder: 'Runner-up Group E',
    awayPlaceholder: 'Runner-up Group I',
  ),
  79: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group A',
    awayPlaceholder: 'Best 3rd place Group C/E/F/H/I',
  ),
  80: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group L',
    awayPlaceholder: 'Best 3rd place Group E/H/I/J/K',
  ),
  81: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group D',
    awayPlaceholder: 'Best 3rd place Group B/E/F/I/J',
  ),
  82: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group G',
    awayPlaceholder: 'Best 3rd place Group A/E/H/I/J',
  ),
  83: _KnockoutSlotRules(
    homePlaceholder: 'Runner-up Group K',
    awayPlaceholder: 'Runner-up Group L',
  ),
  84: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group H',
    awayPlaceholder: 'Runner-up Group J',
  ),
  85: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group B',
    awayPlaceholder: 'Best 3rd place Group E/F/G/I/J',
  ),
  86: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group J',
    awayPlaceholder: 'Runner-up Group H',
  ),
  87: _KnockoutSlotRules(
    homePlaceholder: 'Winner Group K',
    awayPlaceholder: 'Best 3rd place Group D/E/I/J/L',
  ),
  88: _KnockoutSlotRules(
    homePlaceholder: 'Runner-up Group D',
    awayPlaceholder: 'Runner-up Group G',
  ),
  89: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 73',
    awayPlaceholder: 'Winner Match 75',
  ),
  90: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 74',
    awayPlaceholder: 'Winner Match 77',
  ),
  91: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 76',
    awayPlaceholder: 'Winner Match 78',
  ),
  92: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 79',
    awayPlaceholder: 'Winner Match 80',
  ),
  93: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 83',
    awayPlaceholder: 'Winner Match 84',
  ),
  94: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 81',
    awayPlaceholder: 'Winner Match 82',
  ),
  95: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 86',
    awayPlaceholder: 'Winner Match 88',
  ),
  96: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 85',
    awayPlaceholder: 'Winner Match 87',
  ),
  97: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 89',
    awayPlaceholder: 'Winner Match 90',
  ),
  98: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 93',
    awayPlaceholder: 'Winner Match 94',
  ),
  99: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 91',
    awayPlaceholder: 'Winner Match 92',
  ),
  100: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 95',
    awayPlaceholder: 'Winner Match 96',
  ),
  101: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 97',
    awayPlaceholder: 'Winner Match 98',
  ),
  102: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 99',
    awayPlaceholder: 'Winner Match 100',
  ),
  103: _KnockoutSlotRules(
    homePlaceholder: 'Loser Match 101',
    awayPlaceholder: 'Loser Match 102',
  ),
  104: _KnockoutSlotRules(
    homePlaceholder: 'Winner Match 101',
    awayPlaceholder: 'Winner Match 102',
  ),
};

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
    'Mei',
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
    'Maandag',
    'Dinsdag',
    'Woensdag',
    'Donderdag',
    'Vrijdag',
    'Zaterdag',
    'Zondag',
  ][weekday - 1];
}

String _time(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
