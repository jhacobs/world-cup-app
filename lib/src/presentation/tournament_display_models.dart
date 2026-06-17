class DisplayTournament {
  const DisplayTournament({
    required this.title,
    required this.subtitle,
    required this.matches,
    required this.groups,
    required this.stageFilters,
  });

  final String title;
  final String subtitle;
  final List<DisplayMatch> matches;
  final List<DisplayGroup> groups;
  final List<String> stageFilters;

  List<DisplayMatch> get knockoutMatches {
    return matches.where((match) => match.isKnockout).toList(growable: false);
  }
}

class DisplayTeam {
  const DisplayTeam({
    required this.id,
    required this.name,
    required this.code,
    this.qualifierLabel,
    this.isProjected = false,
    this.projectionUncertain = false,
  });

  final String id;
  final String name;
  final String code;
  final String? qualifierLabel;
  final bool isProjected;
  final bool projectionUncertain;
}

class DisplayMatch {
  const DisplayMatch({
    required this.id,
    this.fifaMatchNumber,
    required this.stage,
    required this.isKnockout,
    this.group,
    required this.localDate,
    required this.date,
    required this.dayOfWeek,
    required this.time,
    required this.home,
    required this.away,
    required this.isCompleted,
    this.homeScore,
    this.awayScore,
    this.winnerTeamId,
  });

  final String id;
  final int? fifaMatchNumber;
  final String stage;
  final bool isKnockout;
  final String? group;
  final DateTime localDate;
  final String date;
  final String dayOfWeek;
  final String time;
  final DisplayTeam home;
  final DisplayTeam away;
  final bool isCompleted;
  final int? homeScore;
  final int? awayScore;
  final String? winnerTeamId;

  String get resultText {
    if (!isCompleted || homeScore == null || awayScore == null) {
      return time;
    }
    return '$homeScore - $awayScore';
  }

  String get detailResultText {
    if (!isCompleted || homeScore == null || awayScore == null) {
      return '${home.name} tegen ${away.name}';
    }
    return '${home.name} $homeScore - $awayScore ${away.name}';
  }

  bool get isHomeWinner {
    if (winnerTeamId != null) {
      return winnerTeamId == home.id;
    }
    return isCompleted &&
        homeScore != null &&
        awayScore != null &&
        homeScore! > awayScore!;
  }

  bool get isAwayWinner {
    if (winnerTeamId != null) {
      return winnerTeamId == away.id;
    }
    return isCompleted &&
        homeScore != null &&
        awayScore != null &&
        awayScore! > homeScore!;
  }
}

class DisplayGroup {
  const DisplayGroup({
    required this.id,
    required this.name,
    required this.standings,
  });

  final String id;
  final String name;
  final List<DisplayStanding> standings;
}

class DisplayStanding {
  const DisplayStanding({
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalDifference,
    required this.points,
  });

  final DisplayTeam team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;
}
