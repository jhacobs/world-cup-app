import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/data/tournament_asset_data_source.dart';
import 'src/data/tournament_models.dart';
import 'src/data/tournament_repository.dart';
import 'src/data/world_cup_data_config.dart';
import 'src/presentation/tournament_display_mapper.dart';
import 'src/presentation/tournament_display_models.dart';

typedef TournamentLoader = Future<Tournament> Function();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.tournamentLoader});

  final TournamentLoader? tournamentLoader;

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
      home: TournamentLoaderPage(
        tournamentLoader: tournamentLoader ?? _defaultTournamentLoader,
      ),
    );
  }

  static Future<Tournament> _defaultTournamentLoader() {
    final repository = TournamentRepository(
      config: WorldCupDataConfig.fromEnvironment(),
      loadAssetString: TournamentAssetDataSource(rootBundle).load,
    );
    return repository.loadTournament();
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

class TournamentLoaderPage extends StatefulWidget {
  const TournamentLoaderPage({super.key, required this.tournamentLoader});

  final TournamentLoader tournamentLoader;

  @override
  State<TournamentLoaderPage> createState() => _TournamentLoaderPageState();
}

class _TournamentLoaderPageState extends State<TournamentLoaderPage> {
  late final Future<DisplayTournament> _tournamentFuture;

  @override
  void initState() {
    super.initState();
    _tournamentFuture = widget.tournamentLoader().then(mapTournamentToDisplay);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DisplayTournament>(
      future: _tournamentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingTournamentPage();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const TournamentErrorPage();
        }
        return TournamentHomePage(tournament: snapshot.requireData);
      },
    );
  }
}

class LoadingTournamentPage extends StatelessWidget {
  const LoadingTournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

class TournamentErrorPage extends StatelessWidget {
  const TournamentErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.accent, size: 34),
                SizedBox(height: 12),
                Text(
                  'Kan toernooigegevens niet laden',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Controleer de meegeleverde WK-gegevens en probeer opnieuw.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key, required this.tournament});

  final DisplayTournament tournament;

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
            TournamentHeader(tournament: widget.tournament),
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
            label: 'Wedstrijden',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Groepen',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Knock-out',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    return switch (_selectedTab) {
      TournamentTab.matches => MatchesTab(tournament: widget.tournament),
      TournamentTab.groups => GroupsTab(groups: widget.tournament.groups),
      TournamentTab.knockout => KnockoutTab(
        matches: widget.tournament.knockoutMatches,
      ),
    };
  }
}

class TournamentHeader extends StatelessWidget {
  const TournamentHeader({super.key, required this.tournament});

  final DisplayTournament tournament;

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
            tournament.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tournament.subtitle,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
            ),
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
  const MatchesTab({super.key, required this.tournament});

  final DisplayTournament tournament;

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  var _selectedFilter = 'Alles';

  @override
  Widget build(BuildContext context) {
    final filters = widget.tournament.stageFilters;
    if (!filters.contains(_selectedFilter)) {
      _selectedFilter = 'Alles';
    }
    final filteredMatches = _filterMatches(
      widget.tournament.matches,
      _selectedFilter,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterChips(
            labels: filters,
            selectedLabel: _selectedFilter,
            onSelected: (label) => setState(() => _selectedFilter = label),
          ),
          const SizedBox(height: 12),
          if (filteredMatches.isEmpty)
            const EmptyState(
              icon: Icons.sports_soccer_outlined,
              message: 'Geen wedstrijden beschikbaar',
            )
          else
            for (final group in _groupByDate(filteredMatches))
              DateMatchGroup(matches: group),
        ],
      ),
    );
  }

  List<DisplayMatch> _filterMatches(List<DisplayMatch> matches, String filter) {
    if (filter == 'Alles') {
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

List<List<DisplayMatch>> _groupByDate(List<DisplayMatch> matches) {
  final groups = <String, List<DisplayMatch>>{};
  for (final match in matches) {
    final key = '${match.dayOfWeek}|${match.date}';
    groups.putIfAbsent(key, () => []).add(match);
  }
  return groups.values.toList();
}

class DateMatchGroup extends StatelessWidget {
  const DateMatchGroup({super.key, required this.matches});

  final List<DisplayMatch> matches;

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
            '$count ${count == 1 ? 'wedstrijd' : 'wedstrijden'}',
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

  final DisplayMatch match;

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
                        isHomeWinner: match.isHomeWinner,
                        isAwayWinner: match.isAwayWinner,
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
}

class MatchStatusColumn extends StatelessWidget {
  const MatchStatusColumn({super.key, required this.match});

  final DisplayMatch match;

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
            match.isCompleted ? 'Einde' : 'Aftrap',
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

  final DisplayMatch match;

  @override
  Widget build(BuildContext context) {
    final groupLabel = match.group == null
        ? _shortStageLabel(match.stage)
        : 'Groep ${match.group}';
    return Row(children: [StageBadge(label: groupLabel)]);
  }

  String _shortStageLabel(String stage) {
    return switch (stage) {
      'Ronde van 32' => 'R32',
      'Achtste finales' => 'R16',
      'Kwartfinales' => 'QF',
      'Halve finales' => 'SF',
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

  final DisplayMatch match;
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

  final DisplayMatch match;

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

  final DisplayTeam team;
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

  final DisplayTeam team;

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
        team.code,
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
  const GroupsTab({super.key, required this.groups});

  final List<DisplayGroup> groups;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        children: [
          if (groups.isEmpty)
            const EmptyState(
              icon: Icons.table_chart_outlined,
              message: 'Geen groepen beschikbaar',
            )
          else
            for (final group in groups) ...[
              GroupTable(group: group),
              const SizedBox(height: 14),
            ],
          if (groups.isNotEmpty) const QualificationNote(),
        ],
      ),
    );
  }
}

class GroupTable extends StatelessWidget {
  const GroupTable({super.key, required this.group});

  final DisplayGroup group;

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
                StageBadge(label: group.name),
                const SizedBox(width: 8),
                const Text(
                  'Stand',
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
          for (final (index, standing) in group.standings.indexed)
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
          StandingCell(label: 'GS', isHeader: true),
          StandingCell(label: 'W', isHeader: true),
          StandingCell(label: 'G', isHeader: true),
          StandingCell(label: 'V', isHeader: true),
          StandingCell(label: 'DS', isHeader: true),
          StandingCell(label: 'Ptn', isHeader: true),
        ],
      ),
    );
  }
}

class StandingRow extends StatelessWidget {
  const StandingRow({super.key, required this.standing, required this.rank});

  final DisplayStanding standing;
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
              'De top 2 per groep plaatst zich. De beste nummers drie gaan door.',
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
  const KnockoutTab({super.key, required this.matches});

  final List<DisplayMatch> matches;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Knock-outschema',
            style: TextStyle(
              color: AppColors.foreground,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Veeg opzij om elke ronde te volgen.',
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (matches.isEmpty)
            const EmptyState(
              icon: Icons.emoji_events_outlined,
              message: 'Geen knock-outwedstrijden beschikbaar',
            )
          else
            SingleChildScrollView(
              key: const ValueKey('knockout-bracket'),
              scrollDirection: Axis.horizontal,
              child: BracketTree(matches: matches),
            ),
        ],
      ),
    );
  }
}

class BracketTree extends StatelessWidget {
  const BracketTree({super.key, required this.matches});

  final List<DisplayMatch> matches;

  @override
  Widget build(BuildContext context) {
    final stages = [
      for (final stage in _knockoutStages)
        if (matches.any((match) => match.stage == stage)) stage,
    ];

    return Row(
      key: const ValueKey('knockout-tree'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, stage) in stages.indexed) ...[
          BracketRoundColumn(
            stage: stage,
            matches: matches
                .where((match) => match.stage == stage)
                .toList(growable: false),
          ),
          if (index != stages.length - 1)
            SizedBox(
              key: ValueKey('bracket-connector-tree-$index'),
              width: 26,
              height: 132,
              child: const CustomPaint(painter: BracketConnectorPainter()),
            ),
        ],
      ],
    );
  }
}

const _knockoutStages = [
  'Ronde van 32',
  'Achtste finales',
  'Kwartfinales',
  'Halve finales',
  '3e plaats',
  'Finale',
  'Knock-out',
];

class BracketRoundColumn extends StatelessWidget {
  const BracketRoundColumn({
    super.key,
    required this.stage,
    required this.matches,
  });

  final String stage;
  final List<DisplayMatch> matches;

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
    final isFinal = stage == 'Finale';
    final isPlacement = stage == '3e plaats';
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

  final DisplayMatch match;

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
                  color: match.stage == 'Finale'
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
                      color: match.stage == 'Finale'
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
                isWinner: match.isHomeWinner,
              ),
              const SizedBox(height: 6),
              BracketTeamLine(
                team: match.away,
                score: match.awayScore,
                isWinner: match.isAwayWinner,
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

  final DisplayTeam team;
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

class BracketConnectorPainter extends CustomPainter {
  const BracketConnectorPainter();

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

class MatchDetailPage extends StatelessWidget {
  const MatchDetailPage({super.key, required this.match});

  final DisplayMatch match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedstrijddetail'),
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
                          : 'Groep ${match.group}',
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
                      match.isCompleted ? 'Eindstand' : 'Geplande aftrap',
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

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
