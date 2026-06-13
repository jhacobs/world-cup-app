import 'tournament_models.dart';
import 'tournament_update_models.dart';

class TournamentMerger {
  const TournamentMerger._();

  static Tournament merge(Tournament baseline, TournamentUpdate update) {
    final updatesByMatchId = {
      for (final matchUpdate in update.matches)
        matchUpdate.matchId: matchUpdate,
    };
    final matches = [
      for (final match in baseline.matches)
        if (updatesByMatchId[match.id] case final matchUpdate?)
          _mergeMatch(match, matchUpdate)
        else
          match,
    ];

    return baseline.copyWith(
      matches: matches,
      groupStandings: update.groupStandings.isEmpty
          ? baseline.groupStandings
          : update.groupStandings,
    );
  }

  static Match _mergeMatch(Match baseline, MatchUpdate update) {
    return baseline.copyWith(
      providerId: update.providerId ?? baseline.providerId,
      status: update.status,
      score: _scoreFor(update),
      winnerTeamId: update.winnerTeamId,
    );
  }

  static MatchScore? _scoreFor(MatchUpdate update) {
    if (update.status != MatchStatus.live &&
        update.status != MatchStatus.completed) {
      return null;
    }

    final homeScore = update.homeScore;
    final awayScore = update.awayScore;
    if (homeScore == null || awayScore == null) {
      return null;
    }

    return MatchScore(
      home: homeScore,
      away: awayScore,
      homePenalty: update.homePenaltyScore,
      awayPenalty: update.awayPenaltyScore,
    );
  }
}
