import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_app/src/data/tournament_models.dart';

void main() {
  group('Tournament models', () {
    test('parses baseline tournament data', () {
      final tournament = Tournament.fromJson(_baselineTournamentJson());

      expect(tournament.schemaVersion, 1);
      expect(tournament.info.id, 'world-cup-2026');
      expect(tournament.teams.first.countryCode, 'MEX');
      final southAfrica = tournament.teams.singleWhere(
        (team) => team.id == 'south-africa',
      );
      expect(southAfrica.name, 'South Africa');
      expect(southAfrica.shortName, 'RSA');
      expect(southAfrica.countryCode, 'RSA');
      expect(tournament.groups.first.name, 'Group A');
      expect(tournament.venues.first.city, 'Mexico City');
      expect(tournament.matches.first.stage, TournamentStage.group);
      expect(tournament.matches.first.status, MatchStatus.scheduled);
      expect(tournament.matches.first.score, isNull);
      expect(tournament.matches.first.providerId, 497000);
    });

    test('rejects unsupported schema version', () {
      final json = _baselineTournamentJson()..['schemaVersion'] = 2;

      expect(() => Tournament.fromJson(json), throwsFormatException);
    });

    test('rejects timezone-less kickoffUtc strings', () {
      final json = _baselineTournamentJson();
      final matches = json['matches']! as List<Object?>;
      final match = matches.first! as Map<String, Object?>;
      match['kickoffUtc'] = '2026-06-11T19:00:00';

      expect(() => Tournament.fromJson(json), throwsFormatException);
    });

    test('parses unknown knockout teams using placeholders', () {
      final tournament = Tournament.fromJson(_baselineTournamentJson());
      final match = tournament.matches.singleWhere(
        (match) => match.id == 'match-097',
      );

      expect(match.stage, TournamentStage.knockout);
      expect(match.homeTeamId, isNull);
      expect(match.awayTeamId, isNull);
      expect(match.homePlaceholder, 'Winner Group A');
      expect(match.awayPlaceholder, 'Runner-up Group B');
    });

    test('parses optional baseline match result fields', () {
      final json = _baselineTournamentJson();
      final matches = json['matches']! as List<Object?>;
      final match = matches.first! as Map<String, Object?>;
      match['status'] = 'completed';
      match['score'] = {
        'home': 2,
        'away': 1,
        'homePenalty': null,
        'awayPenalty': null,
      };
      match['winnerTeamId'] = 'mexico';

      final tournament = Tournament.fromJson(json);
      final parsedMatch = tournament.matches.first;

      expect(parsedMatch.status, MatchStatus.completed);
      expect(parsedMatch.score!.home, 2);
      expect(parsedMatch.score!.away, 1);
      expect(parsedMatch.winnerTeamId, 'mexico');
    });

    test('copyWith can clear nullable result fields', () {
      final match = Match(
        id: 'match-001',
        providerId: 497000,
        stage: TournamentStage.group,
        kickoffUtc: DateTime.utc(2026, 6, 11, 19),
        venueId: 'estadio-azteca',
        status: MatchStatus.completed,
        score: MatchScore(home: 2, away: 1),
        winnerTeamId: 'mexico',
      );

      final updated = match.copyWith(
        providerId: null,
        score: null,
        winnerTeamId: null,
      );

      expect(updated.providerId, isNull);
      expect(updated.score, isNull);
      expect(updated.winnerTeamId, isNull);
      expect(updated.status, MatchStatus.completed);
    });

    test('defensively copies list inputs', () {
      final teams = [
        const Team(
          id: 'mexico',
          name: 'Mexico',
          shortName: 'MEX',
          countryCode: 'MEX',
        ),
      ];
      final groups = [
        TournamentGroup(id: 'group-a', name: 'Group A', teamIds: ['mexico']),
      ];
      final venues = [
        const Venue(
          id: 'estadio-azteca',
          name: 'Estadio Azteca',
          city: 'Mexico City',
          country: 'Mexico',
        ),
      ];
      final matches = [
        Match(
          id: 'match-001',
          stage: TournamentStage.group,
          kickoffUtc: DateTime.utc(2026, 6, 11, 19),
          venueId: 'estadio-azteca',
        ),
      ];
      final groupStandings = [
        GroupStanding(
          groupId: 'group-a',
          entries: [
            const GroupStandingEntry(
              teamId: 'mexico',
              played: 0,
              won: 0,
              drawn: 0,
              lost: 0,
              goalsFor: 0,
              goalsAgainst: 0,
              goalDifference: 0,
              points: 0,
            ),
          ],
        ),
      ];
      final tournamentGroupTeamIds = ['mexico'];
      final groupStandingEntries = [
        const GroupStandingEntry(
          teamId: 'mexico',
          played: 0,
          won: 0,
          drawn: 0,
          lost: 0,
          goalsFor: 0,
          goalsAgainst: 0,
          goalDifference: 0,
          points: 0,
        ),
      ];

      final tournament = Tournament(
        schemaVersion: 1,
        info: TournamentInfo(
          id: 'world-cup-2026',
          name: 'FIFA World Cup 2026',
          startDate: DateTime(2026, 6, 11),
          endDate: DateTime(2026, 7, 19),
        ),
        teams: teams,
        groups: groups,
        venues: venues,
        matches: matches,
        groupStandings: groupStandings,
      );
      final tournamentGroup = TournamentGroup(
        id: 'group-a',
        name: 'Group A',
        teamIds: tournamentGroupTeamIds,
      );
      final groupStanding = GroupStanding(
        groupId: 'group-a',
        entries: groupStandingEntries,
      );

      teams.clear();
      groups.clear();
      venues.clear();
      matches.clear();
      groupStandings.clear();
      tournamentGroupTeamIds.clear();
      groupStandingEntries.clear();

      expect(tournament.teams, hasLength(1));
      expect(tournament.groups, hasLength(1));
      expect(tournament.venues, hasLength(1));
      expect(tournament.matches, hasLength(1));
      expect(tournament.groupStandings, hasLength(1));
      expect(tournamentGroup.teamIds, ['mexico']);
      expect(groupStanding.entries, hasLength(1));

      expect(
        () => tournament.teams.add(
          const Team(
            id: 'canada',
            name: 'Canada',
            shortName: 'CAN',
            countryCode: 'CAN',
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => tournament.groups.add(
          TournamentGroup(id: 'group-b', name: 'Group B', teamIds: ['canada']),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => tournament.venues.add(
          const Venue(
            id: 'bc-place',
            name: 'BC Place',
            city: 'Vancouver',
            country: 'Canada',
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => tournament.matches.add(
          Match(
            id: 'match-002',
            stage: TournamentStage.group,
            kickoffUtc: DateTime.utc(2026, 6, 12, 19),
            venueId: 'estadio-azteca',
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => tournament.groupStandings.add(
          GroupStanding(
            groupId: 'group-b',
            entries: [
              const GroupStandingEntry(
                teamId: 'canada',
                played: 0,
                won: 0,
                drawn: 0,
                lost: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                goalDifference: 0,
                points: 0,
              ),
            ],
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => tournamentGroup.teamIds.add('canada'),
        throwsUnsupportedError,
      );
      expect(
        () => groupStanding.entries.add(
          const GroupStandingEntry(
            teamId: 'canada',
            played: 0,
            won: 0,
            drawn: 0,
            lost: 0,
            goalsFor: 0,
            goalsAgainst: 0,
            goalDifference: 0,
            points: 0,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}

Map<String, Object?> _baselineTournamentJson() {
  return {
    'schemaVersion': 1,
    'info': {
      'id': 'world-cup-2026',
      'name': 'FIFA World Cup 2026',
      'startDate': '2026-06-11',
      'endDate': '2026-07-19',
    },
    'teams': [
      {
        'id': 'mexico',
        'name': 'Mexico',
        'shortName': 'MEX',
        'countryCode': 'MEX',
        'groupId': 'group-a',
        'providerId': 1001,
      },
      {
        'id': 'south-africa',
        'name': 'South Africa',
        'shortName': 'RSA',
        'countryCode': 'RSA',
        'groupId': 'group-a',
        'providerId': 1002,
      },
    ],
    'groups': [
      {
        'id': 'group-a',
        'name': 'Group A',
        'teamIds': ['mexico', 'south-africa'],
      },
    ],
    'venues': [
      {
        'id': 'estadio-azteca',
        'name': 'Estadio Azteca',
        'city': 'Mexico City',
        'country': 'Mexico',
      },
    ],
    'matches': [
      {
        'id': 'match-001',
        'providerId': 497000,
        'stage': 'group',
        'groupId': 'group-a',
        'kickoffUtc': '2026-06-11T19:00:00Z',
        'venueId': 'estadio-azteca',
        'homeTeamId': 'mexico',
        'awayTeamId': 'south-africa',
      },
      {
        'id': 'match-097',
        'stage': 'knockout',
        'kickoffUtc': '2026-07-04T19:00:00Z',
        'venueId': 'estadio-azteca',
        'homePlaceholder': 'Winner Group A',
        'awayPlaceholder': 'Runner-up Group B',
      },
    ],
  };
}
