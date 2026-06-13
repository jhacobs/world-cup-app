import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled World Cup 2026 asset parses as tournament data', () async {
    final assetJson = await rootBundle.loadString(
      'assets/data/world_cup_2026.json',
    );
    final decoded = jsonDecode(assetJson) as Map<String, Object?>;
    final tournament = Tournament.fromJson(decoded);

    expect(tournament.info.id, 'world-cup-2026');
    expect(tournament.teams.length, greaterThanOrEqualTo(2));
    expect(tournament.groups.length, greaterThanOrEqualTo(1));
    expect(tournament.venues.length, greaterThanOrEqualTo(1));
    expect(tournament.matches.length, greaterThanOrEqualTo(1));

    final venueIds = tournament.venues.map((venue) => venue.id).toSet();
    final teamIds = tournament.teams.map((team) => team.id).toSet();
    final groupIds = tournament.groups.map((group) => group.id).toSet();
    final teamsById = {for (final team in tournament.teams) team.id: team};
    final groupsById = {for (final group in tournament.groups) group.id: group};

    for (final team in tournament.teams) {
      _expectOptionalGroupIdExists(groupIds, team.groupId);
      final groupId = team.groupId;
      if (groupId != null) {
        expect(groupsById[groupId]!.teamIds, contains(team.id));
      }
    }

    for (final match in tournament.matches) {
      expect(venueIds, contains(match.venueId));
      _expectOptionalGroupIdExists(groupIds, match.groupId);
      _expectOptionalTeamIdExists(teamIds, match.homeTeamId);
      _expectOptionalTeamIdExists(teamIds, match.awayTeamId);
    }

    for (final group in tournament.groups) {
      for (final teamId in group.teamIds) {
        expect(teamIds, contains(teamId));
        expect(teamsById[teamId]?.groupId, group.id);
      }
    }
  });
}

void _expectOptionalTeamIdExists(Set<String> teamIds, String? teamId) {
  if (teamId == null) {
    return;
  }

  expect(teamIds, contains(teamId));
}

void _expectOptionalGroupIdExists(Set<String> groupIds, String? groupId) {
  if (groupId == null) {
    return;
  }

  expect(groupIds, contains(groupId));
}
