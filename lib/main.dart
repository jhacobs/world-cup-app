import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Cup 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.card,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.navBackground,
          indicatorColor: AppColors.navSelected,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.accent
                  : AppColors.primaryDark.withValues(alpha: 0.72),
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.accent
                  : AppColors.primaryDark.withValues(alpha: 0.72),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            );
          }),
          height: 70,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.border),
          ),
        ),
      ),
      home: const TournamentHomePage(),
    );
  }
}

class AppColors {
  static const background = Colors.white;
  static const foreground = Color(0xff12311f);
  static const card = Color(0xffffffff);
  static const primary = Color(0xff16a34a);
  static const primaryDark = Color(0xff087f3e);
  static const muted = Color(0xffdcfce7);
  static const mutedForeground = Color(0xff4b6b58);
  static const accent = Color(0xffef233c);
  static const accentSoft = Color(0xffffe3e8);
  static const navBackground = Colors.white;
  static const navSelected = accentSoft;
  static const border = Color(0x3322c55e);
}

enum TournamentTab { matches, groups, knockout }

enum SampleMatchStatus { scheduled, completed }

class SampleTeam {
  const SampleTeam({
    required this.name,
    required this.code,
    required this.flag,
  });

  final String name;
  final String code;
  final String flag;
}

class SampleMatch {
  const SampleMatch({
    required this.id,
    required this.stage,
    this.group,
    required this.date,
    required this.dayOfWeek,
    required this.time,
    required this.venue,
    required this.city,
    required this.home,
    required this.away,
    required this.status,
    this.homeScore,
    this.awayScore,
  });

  final String id;
  final String stage;
  final String? group;
  final String date;
  final String dayOfWeek;
  final String time;
  final String venue;
  final String city;
  final SampleTeam home;
  final SampleTeam away;
  final SampleMatchStatus status;
  final int? homeScore;
  final int? awayScore;

  bool get isCompleted => status == SampleMatchStatus.completed;

  String get title => '${home.name} vs ${away.name}';

  String get resultText {
    if (!isCompleted) {
      return time;
    }
    return '$homeScore - $awayScore';
  }

  String get detailResultText {
    if (!isCompleted) {
      return '${home.name} vs ${away.name}';
    }
    return '${home.name} $homeScore - $awayScore ${away.name}';
  }
}

class SampleStanding {
  const SampleStanding({
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalDifference,
    required this.points,
  });

  final SampleTeam team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;
}

const mexico = SampleTeam(name: 'Mexico', code: 'MEX', flag: 'MEX');
const poland = SampleTeam(name: 'Poland', code: 'POL', flag: 'POL');
const ecuador = SampleTeam(name: 'Ecuador', code: 'ECU', flag: 'ECU');
const saudiArabia = SampleTeam(name: 'Saudi Arabia', code: 'KSA', flag: 'KSA');
const spain = SampleTeam(name: 'Spain', code: 'ESP', flag: 'ESP');
const germany = SampleTeam(name: 'Germany', code: 'GER', flag: 'GER');
const senegal = SampleTeam(name: 'Senegal', code: 'SEN', flag: 'SEN');
const australia = SampleTeam(name: 'Australia', code: 'AUS', flag: 'AUS');
const tbd = SampleTeam(name: 'TBD', code: 'TBD', flag: 'TBD');
const winnerGroupA = SampleTeam(name: 'Winner Group A', code: '1A', flag: '1A');
const runnerUpGroupB = SampleTeam(
  name: 'Runner-up Group B',
  code: '2B',
  flag: '2B',
);

const sampleMatches = [
  SampleMatch(
    id: 'mexico-poland',
    stage: 'Group Stage',
    group: 'A',
    date: 'Jun 11',
    dayOfWeek: 'Thursday',
    time: '17:00',
    venue: 'Estadio Azteca',
    city: 'Mexico City',
    home: mexico,
    away: poland,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'ecuador-saudi-arabia',
    stage: 'Group Stage',
    group: 'A',
    date: 'Jun 11',
    dayOfWeek: 'Thursday',
    time: '20:00',
    venue: 'SoFi Stadium',
    city: 'Los Angeles',
    home: ecuador,
    away: saudiArabia,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'spain-germany',
    stage: 'Group Stage',
    group: 'E',
    date: 'Jun 17',
    dayOfWeek: 'Wednesday',
    time: '16:00',
    venue: 'Mercedes-Benz Stadium',
    city: 'Atlanta',
    home: spain,
    away: germany,
    status: SampleMatchStatus.completed,
    homeScore: 2,
    awayScore: 1,
  ),
  SampleMatch(
    id: 'senegal-australia',
    stage: 'Group Stage',
    group: 'E',
    date: 'Jun 21',
    dayOfWeek: 'Sunday',
    time: '18:00',
    venue: 'Estadio Akron',
    city: 'Guadalajara',
    home: senegal,
    away: australia,
    status: SampleMatchStatus.completed,
    homeScore: 0,
    awayScore: 0,
  ),
];

const knockoutMatches = [
  SampleMatch(
    id: 'round-32-1',
    stage: 'Round of 32',
    date: 'Jul 4',
    dayOfWeek: 'Saturday',
    time: 'TBD',
    venue: 'MetLife Stadium',
    city: 'New York',
    home: winnerGroupA,
    away: runnerUpGroupB,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'round-32-2',
    stage: 'Round of 32',
    date: 'Jul 5',
    dayOfWeek: 'Sunday',
    time: 'TBD',
    venue: 'Lumen Field',
    city: 'Seattle',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'round-16-1',
    stage: 'Round of 16',
    date: 'Jul 8',
    dayOfWeek: 'Wednesday',
    time: 'TBD',
    venue: 'AT&T Stadium',
    city: 'Dallas',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'quarter-final-1',
    stage: 'Quarter-finals',
    date: 'Jul 14',
    dayOfWeek: 'Tuesday',
    time: 'TBD',
    venue: 'Hard Rock Stadium',
    city: 'Miami',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'semi-final-1',
    stage: 'Semi-finals',
    date: 'Jul 18',
    dayOfWeek: 'Saturday',
    time: 'TBD',
    venue: 'MetLife Stadium',
    city: 'New York',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'third-place',
    stage: '3rd Place',
    date: 'Jul 18',
    dayOfWeek: 'Saturday',
    time: '18:00',
    venue: 'Hard Rock Stadium',
    city: 'Miami',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
  SampleMatch(
    id: 'final',
    stage: 'Final',
    date: 'Jul 19',
    dayOfWeek: 'Sunday',
    time: '18:00',
    venue: 'MetLife Stadium',
    city: 'New York',
    home: tbd,
    away: tbd,
    status: SampleMatchStatus.scheduled,
  ),
];

const stageFilters = [
  'All',
  'Group Stage',
  'Round of 32',
  'Round of 16',
  'Quarter-finals',
  'Semi-finals',
  '3rd Place',
  'Final',
];

const knockoutStageFilters = [
  'All',
  'Round of 32',
  'Round of 16',
  'Quarter-finals',
  'Semi-finals',
  '3rd Place',
  'Final',
];

const allPreviewMatches = [...sampleMatches, ...knockoutMatches];

const groupStandings = {
  'Group A': [
    SampleStanding(
      team: mexico,
      played: 1,
      won: 1,
      drawn: 0,
      lost: 0,
      goalDifference: 2,
      points: 3,
    ),
    SampleStanding(
      team: poland,
      played: 1,
      won: 0,
      drawn: 0,
      lost: 1,
      goalDifference: -2,
      points: 0,
    ),
    SampleStanding(
      team: ecuador,
      played: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      goalDifference: 0,
      points: 0,
    ),
    SampleStanding(
      team: saudiArabia,
      played: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      goalDifference: 0,
      points: 0,
    ),
  ],
  'Group E': [
    SampleStanding(
      team: spain,
      played: 1,
      won: 1,
      drawn: 0,
      lost: 0,
      goalDifference: 1,
      points: 3,
    ),
    SampleStanding(
      team: australia,
      played: 1,
      won: 0,
      drawn: 1,
      lost: 0,
      goalDifference: 0,
      points: 1,
    ),
    SampleStanding(
      team: senegal,
      played: 1,
      won: 0,
      drawn: 1,
      lost: 0,
      goalDifference: 0,
      points: 1,
    ),
    SampleStanding(
      team: germany,
      played: 1,
      won: 0,
      drawn: 0,
      lost: 1,
      goalDifference: -1,
      points: 0,
    ),
  ],
};

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  @override
  State<TournamentHomePage> createState() => _TournamentHomePageState();
}

class _TournamentHomePageState extends State<TournamentHomePage> {
  var _selectedTab = TournamentTab.matches;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TournamentHeader(),
            Expanded(child: _buildCurrentTab()),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab.index,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = TournamentTab.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Knockout',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    return switch (_selectedTab) {
      TournamentTab.matches => const MatchesTab(),
      TournamentTab.groups => const GroupsTab(),
      TournamentTab.knockout => const KnockoutTab(),
    };
  }
}

class TournamentHeader extends StatelessWidget {
  const TournamentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'World Cup 2026',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jun 11 - Jul 19 · USA, Canada & Mexico',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: SizedBox(height: 6),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: SizedBox(height: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  var _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _filterMatches(allPreviewMatches, _selectedFilter);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterChips(
            labels: stageFilters,
            selectedLabel: _selectedFilter,
            onSelected: (label) => setState(() => _selectedFilter = label),
          ),
          const SizedBox(height: 12),
          for (final group in _groupByDate(filteredMatches))
            DateMatchGroup(matches: group),
        ],
      ),
    );
  }

  List<SampleMatch> _filterMatches(List<SampleMatch> matches, String filter) {
    if (filter == 'All') {
      return matches;
    }
    return matches.where((match) => match.stage == filter).toList();
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.labels,
    required this.selectedLabel,
    required this.onSelected,
  });

  final List<String> labels;
  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, label) in labels.indexed) ...[
            ChoiceChip(
              label: Text(label),
              selected: selectedLabel == label,
              onSelected: (_) => onSelected(label),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selectedLabel == label
                    ? Colors.white
                    : AppColors.mutedForeground,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              showCheckmark: false,
            ),
            if (index != labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

List<List<SampleMatch>> _groupByDate(List<SampleMatch> matches) {
  final groups = <String, List<SampleMatch>>{};
  for (final match in matches) {
    final key = '${match.dayOfWeek}|${match.date}';
    groups.putIfAbsent(key, () => []).add(match);
  }
  return groups.values.toList();
}

class DateMatchGroup extends StatelessWidget {
  const DateMatchGroup({super.key, required this.matches});

  final List<SampleMatch> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    final first = matches.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateGroupHeader(
            dayOfWeek: first.dayOfWeek,
            date: first.date,
            count: matches.length,
          ),
          const SizedBox(height: 8),
          for (final match in matches) ...[
            MatchCard(match: match),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class DateGroupHeader extends StatelessWidget {
  const DateGroupHeader({
    super.key,
    required this.dayOfWeek,
    required this.date,
    required this.count,
  });

  final String dayOfWeek;
  final String date;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayOfWeek,
              style: const TextStyle(
                color: AppColors.foreground,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.border)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count ${count == 1 ? 'match' : 'matches'}',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('match-card-${match.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MatchDetailPage(match: match),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MatchStatusColumn(match: match),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MatchMetaRow(match: match),
                      const SizedBox(height: 10),
                      MatchupRow(
                        match: match,
                        isHomeWinner: _isHomeWinner(),
                        isAwayWinner: _isAwayWinner(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isHomeWinner() {
    return match.isCompleted && (match.homeScore ?? 0) > (match.awayScore ?? 0);
  }

  bool _isAwayWinner() {
    return match.isCompleted && (match.awayScore ?? 0) > (match.homeScore ?? 0);
  }
}

class MatchStatusColumn extends StatelessWidget {
  const MatchStatusColumn({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: match.isCompleted ? AppColors.accentSoft : AppColors.muted,
        border: Border(
          right: BorderSide(
            color: match.isCompleted ? AppColors.accent : AppColors.primary,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            match.isCompleted ? 'FT' : 'KO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: match.isCompleted
                  ? AppColors.accent
                  : AppColors.foreground,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.isCompleted ? 'Final' : 'Kickoff',
            style: TextStyle(
              color: match.isCompleted
                  ? AppColors.accent
                  : AppColors.mutedForeground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchMetaRow extends StatelessWidget {
  const MatchMetaRow({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    final groupLabel = match.group == null
        ? _shortStageLabel(match.stage)
        : 'Group ${match.group}';
    return Row(
      children: [
        StageBadge(label: groupLabel),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${match.venue}, ${match.city}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _shortStageLabel(String stage) {
    return switch (stage) {
      'Round of 32' => 'R32',
      'Round of 16' => 'R16',
      'Quarter-finals' => 'QF',
      'Semi-finals' => 'SF',
      _ => stage,
    };
  }
}

class StageBadge extends StatelessWidget {
  const StageBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class MatchupRow extends StatelessWidget {
  const MatchupRow({
    super.key,
    required this.match,
    required this.isHomeWinner,
    required this.isAwayWinner,
  });

  final SampleMatch match;
  final bool isHomeWinner;
  final bool isAwayWinner;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey('matchup-row-${match.id}'),
      children: [
        Expanded(
          child: MatchupTeamName(
            team: match.home,
            isWinner: isHomeWinner,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
        MatchCenterScore(match: match),
        const SizedBox(width: 10),
        Expanded(
          child: MatchupTeamName(
            team: match.away,
            isWinner: isAwayWinner,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class MatchCenterScore extends StatelessWidget {
  const MatchCenterScore({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: match.isCompleted ? AppColors.accentSoft : AppColors.muted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: match.isCompleted ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Text(
        match.resultText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: match.isCompleted ? AppColors.accent : AppColors.primaryDark,
          fontSize: match.isCompleted ? 18 : 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class MatchupTeamName extends StatelessWidget {
  const MatchupTeamName({
    super.key,
    required this.team,
    required this.isWinner,
    required this.textAlign,
  });

  final SampleTeam team;
  final bool isWinner;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: textAlign == TextAlign.right
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (textAlign == TextAlign.right && isWinner) ...[
          const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            team.name,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 15,
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        if (textAlign != TextAlign.right && isWinner) ...[
          const SizedBox(width: 6),
          const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
        ],
      ],
    );
  }
}

class TeamCodeBadge extends StatelessWidget {
  const TeamCodeBadge({super.key, required this.team});

  final SampleTeam team;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        team.flag,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        children: [
          for (final entry in groupStandings.entries) ...[
            GroupTable(groupName: entry.key, standings: entry.value),
            const SizedBox(height: 14),
          ],
          const QualificationNote(),
        ],
      ),
    );
  }
}

class GroupTable extends StatelessWidget {
  const GroupTable({
    super.key,
    required this.groupName,
    required this.standings,
  });

  final String groupName;
  final List<SampleStanding> standings;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.muted,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                StageBadge(label: groupName),
                const SizedBox(width: 8),
                const Text(
                  'Standings',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const _StandingHeader(),
          for (final (index, standing) in standings.indexed)
            StandingRow(standing: standing, rank: index + 1),
        ],
      ),
    );
  }
}

class _StandingHeader extends StatelessWidget {
  const _StandingHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Team',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          StandingCell(label: 'P', isHeader: true),
          StandingCell(label: 'W', isHeader: true),
          StandingCell(label: 'D', isHeader: true),
          StandingCell(label: 'L', isHeader: true),
          StandingCell(label: 'GD', isHeader: true),
          StandingCell(label: 'Pts', isHeader: true),
        ],
      ),
    );
  }
}

class StandingRow extends StatelessWidget {
  const StandingRow({super.key, required this.standing, required this.rank});

  final SampleStanding standing;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('standing-row-$rank-${standing.team.name}'),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TeamCodeBadge(team: standing.team),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    standing.team.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StandingCell(label: '${standing.played}'),
          StandingCell(label: '${standing.won}'),
          StandingCell(label: '${standing.drawn}'),
          StandingCell(label: '${standing.lost}'),
          StandingCell(label: '${standing.goalDifference}'),
          StandingCell(label: '${standing.points}'),
        ],
      ),
    );
  }
}

class StandingCell extends StatelessWidget {
  const StandingCell({
    super.key,
    required this.label,
    this.isHeader = false,
    this.highlight = false,
  });

  final String label;
  final bool isHeader;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: highlight ? AppColors.primary : AppColors.mutedForeground,
          fontWeight: isHeader || highlight ? FontWeight.w900 : FontWeight.w600,
          fontSize: isHeader ? 12 : 13,
        ),
      ),
    );
  }
}

class QualificationNote extends StatelessWidget {
  const QualificationNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accent, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Top 2 per group qualify. Best third-place teams advance.',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KnockoutTab extends StatelessWidget {
  const KnockoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Knockout bracket',
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Swipe sideways to follow each round.',
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            key: const ValueKey('knockout-bracket'),
            scrollDirection: Axis.horizontal,
            child: BracketTree(matches: knockoutMatches),
          ),
        ],
      ),
    );
  }
}

class BracketSlot {
  const BracketSlot({
    required this.match,
    required this.stage,
    required this.left,
    required this.top,
  });

  final SampleMatch match;
  final String stage;
  final double left;
  final double top;
}

class BracketTree extends StatelessWidget {
  const BracketTree({super.key, required this.matches});

  static const _columnWidth = 178.0;
  static const _columnGap = 52.0;
  static const _headerHeight = 34.0;
  static const _headerGap = 18.0;
  static const _cardHeight = 132.0;
  static const _canvasHeight = 560.0;

  final List<SampleMatch> matches;

  @override
  Widget build(BuildContext context) {
    final stages = knockoutStageFilters
        .where((stage) => stage != 'All')
        .toList(growable: false);
    final slots = _buildSlots();
    final width =
        stages.length * _columnWidth + (stages.length - 1) * _columnGap;

    return SizedBox(
      key: const ValueKey('knockout-tree'),
      width: width,
      height: _canvasHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const ValueKey('bracket-connector-tree'),
              painter: BracketTreePainter(
                slots: slots,
                columnWidth: _columnWidth,
                cardHeight: _cardHeight,
              ),
            ),
          ),
          for (final (index, stage) in stages.indexed)
            Positioned(
              key: ValueKey('bracket-round-$stage'),
              left: _xForColumn(index),
              top: 0,
              width: _columnWidth,
              child: BracketRoundHeader(stage: stage),
            ),
          for (final slot in slots)
            Positioned(
              key: ValueKey('bracket-slot-${slot.match.id}'),
              left: slot.left,
              top: slot.top,
              width: _columnWidth,
              height: _cardHeight,
              child: BracketMatchCard(match: slot.match),
            ),
        ],
      ),
    );
  }

  List<BracketSlot> _buildSlots() {
    return [
      _slot('Round of 32', 0, 0, 'round-32-1'),
      _slot('Round of 32', 0, 1, 'round-32-2'),
      _slot('Round of 16', 1, 0.5, 'round-16-1'),
      _slot('Quarter-finals', 2, 1, 'quarter-final-1'),
      _slot('Semi-finals', 3, 1.5, 'semi-final-1'),
      _slot('Final', 5, 2, 'final'),
      _slot('3rd Place', 4, 3.25, 'third-place'),
    ];
  }

  BracketSlot _slot(String stage, int column, double row, String matchId) {
    return BracketSlot(
      match: matches.firstWhere((match) => match.id == matchId),
      stage: stage,
      left: _xForColumn(column),
      top: _headerHeight + _headerGap + row * 112,
    );
  }

  static double _xForColumn(int column) {
    return column * (_columnWidth + _columnGap);
  }
}

class BracketRoundColumn extends StatelessWidget {
  const BracketRoundColumn({
    super.key,
    required this.stage,
    required this.matches,
  });

  final String stage;
  final List<SampleMatch> matches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('bracket-round-$stage'),
      width: 178,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BracketRoundHeader(stage: stage),
          const SizedBox(height: 10),
          for (final (index, match) in matches.indexed) ...[
            BracketMatchCard(match: match),
            if (index != matches.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class BracketRoundHeader extends StatelessWidget {
  const BracketRoundHeader({super.key, required this.stage});

  final String stage;

  @override
  Widget build(BuildContext context) {
    final isFinal = stage == 'Final';
    final isPlacement = stage == '3rd Place';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isFinal
            ? AppColors.accent
            : isPlacement
            ? AppColors.accentSoft
            : AppColors.card,
        borderRadius: BorderRadius.circular(isFinal || isPlacement ? 8 : 18),
        border: Border.all(
          color: isFinal || isPlacement ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Text(
        stage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isFinal
              ? Colors.white
              : isPlacement
              ? AppColors.accent
              : AppColors.mutedForeground,
          fontSize: 12,
          fontWeight: isFinal || isPlacement
              ? FontWeight.w900
              : FontWeight.w700,
        ),
      ),
    );
  }
}

class BracketMatchCard extends StatelessWidget {
  const BracketMatchCard({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('bracket-match-${match.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MatchDetailPage(match: match),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: match.stage == 'Final'
                      ? AppColors.accent
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    match.date,
                    style: TextStyle(
                      color: match.stage == 'Final'
                          ? AppColors.accent
                          : AppColors.mutedForeground,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    match.isCompleted ? 'FT' : match.time,
                    style: TextStyle(
                      color: match.isCompleted
                          ? AppColors.accent
                          : AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BracketTeamLine(
                team: match.home,
                score: match.homeScore,
                isWinner:
                    match.isCompleted &&
                    (match.homeScore ?? 0) > (match.awayScore ?? 0),
              ),
              const SizedBox(height: 6),
              BracketTeamLine(
                team: match.away,
                score: match.awayScore,
                isWinner:
                    match.isCompleted &&
                    (match.awayScore ?? 0) > (match.homeScore ?? 0),
              ),
              const SizedBox(height: 8),
              Text(
                match.venue,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BracketTeamLine extends StatelessWidget {
  const BracketTeamLine({
    super.key,
    required this.team,
    required this.score,
    required this.isWinner,
  });

  final SampleTeam team;
  final int? score;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 12,
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        if (score != null) ...[
          const SizedBox(width: 8),
          Text(
            '$score',
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}

class BracketConnectorGutter extends StatelessWidget {
  const BracketConnectorGutter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 116,
      child: CustomPaint(painter: BracketConnectorPainter()),
    );
  }
}

class BracketConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final y = size.height * 0.55;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    canvas.drawLine(
      Offset(size.width / 2, y - 18),
      Offset(size.width / 2, y + 18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BracketTreePainter extends CustomPainter {
  BracketTreePainter({
    required this.slots,
    required this.columnWidth,
    required this.cardHeight,
  });

  final List<BracketSlot> slots;
  final double columnWidth;
  final double cardHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _connect(canvas, paint, 'round-32-1', 'round-16-1');
    _connect(canvas, paint, 'round-32-2', 'round-16-1');
    _connect(canvas, paint, 'round-16-1', 'quarter-final-1');
    _connect(canvas, paint, 'quarter-final-1', 'semi-final-1');
    _connect(canvas, paint, 'semi-final-1', 'final');
    _connect(canvas, paint, 'semi-final-1', 'third-place');
  }

  void _connect(Canvas canvas, Paint paint, String fromId, String toId) {
    final from = slots.firstWhere((slot) => slot.match.id == fromId);
    final to = slots.firstWhere((slot) => slot.match.id == toId);
    final start = Offset(from.left + columnWidth, from.top + cardHeight / 2);
    final end = Offset(to.left, to.top + cardHeight / 2);
    final midX = start.dx + (end.dx - start.dx) / 2;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(midX, start.dy)
      ..lineTo(midX, end.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BracketTreePainter oldDelegate) {
    return oldDelegate.slots != slots ||
        oldDelegate.columnWidth != columnWidth ||
        oldDelegate.cardHeight != cardHeight;
  }
}

class StageSection extends StatelessWidget {
  const StageSection({
    super.key,
    required this.title,
    required this.matches,
    this.isFinal = false,
  });

  final String title;
  final List<SampleMatch> matches;
  final bool isFinal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('stage-section-$title'),
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isFinal ? AppColors.primary : AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isFinal ? Colors.white : AppColors.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 12),
          for (final match in matches) ...[
            MatchCard(match: match),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({super.key, required this.match});

  final SampleMatch match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match detail'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StageBadge(
                      label: match.group == null
                          ? match.stage
                          : 'Group ${match.group}',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      match.detailResultText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.isCompleted ? 'Final score' : 'Scheduled kickoff',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DetailRow(
              icon: Icons.calendar_today,
              label: '${match.dayOfWeek}, ${match.date}',
            ),
            DetailRow(icon: Icons.schedule, label: match.time),
            DetailRow(icon: Icons.stadium, label: match.venue),
            DetailRow(icon: Icons.location_on_outlined, label: match.city),
            DetailRow(icon: Icons.emoji_events_outlined, label: match.stage),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
