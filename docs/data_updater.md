# World Cup Data Updater

The app ships with a baseline tournament asset at
`assets/data/world_cup_2026.json`. That file is the offline source of truth for
the tournament structure, teams, venues, scheduled matches, and any known static
data.

Generated score updates are separate. The updater writes a small JSON file,
`world_cup_2026_updates.json`, that contains provider match statuses, scores,
winners, and group standings mapped onto the baseline IDs. At runtime the app can
merge that generated update file over the bundled baseline. If no update URL is
configured, the app uses the bundled baseline only.

## Provider

The live updater reads from the football-data.org API v4:

- Competition code: `WC`
- Matches endpoint: `/v4/competitions/WC/matches`
- Standings endpoint: `/v4/competitions/WC/standings`

football-data.org free-plan scores are delayed. Treat the generated data as
near-current rather than live.

## GitHub Pages Setup

1. Create a football-data.org account and generate an API token.
2. In GitHub, open the repository settings and add an Actions secret named
   `FOOTBALL_DATA_API_TOKEN` with that token as the value.
3. In GitHub Pages settings, set the source to GitHub Actions.
4. Open the Actions tab, choose `Update World Cup Data`, and run the workflow
   manually. The workflow also runs hourly at minute 17.
5. Verify the published JSON URL after the first deploy:

```sh
owner_repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
pages_url="$(gh api "repos/$owner_repo/pages" --jq .html_url)"
printf '%s\n' "${pages_url%/}/world_cup_2026_updates.json"
curl -fsS "${pages_url%/}/world_cup_2026_updates.json" | head
```

## App Configuration

Pass the published JSON URL as a Dart define when building or running the app:

```sh
updates_url="$(gh api "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pages" --jq .html_url)"
flutter run --dart-define=WORLD_CUP_UPDATES_URL="${updates_url%/}/world_cup_2026_updates.json"
```

For a release build, use the same define with the appropriate Flutter build
command:

```sh
updates_url="$(gh api "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pages" --jq .html_url)"
flutter build apk --dart-define=WORLD_CUP_UPDATES_URL="${updates_url%/}/world_cup_2026_updates.json"
```

If `WORLD_CUP_UPDATES_URL` is omitted or empty, the app runs from the bundled
baseline asset only.

## Local Live Run

Export the API token before running the updater against football-data.org:

```sh
export FOOTBALL_DATA_API_TOKEN='user-replaced football-data.org token'
dart run tool/update_world_cup_data.dart --output _site/world_cup_2026_updates.json
```

## Local Fixture Run

Use fixtures to test mapping changes without calling the provider:

```sh
matches_fixture='user-replaced path to football-data.org matches fixture JSON'
standings_fixture='user-replaced path to football-data.org standings fixture JSON'

dart run tool/update_world_cup_data.dart \
  --baseline assets/data/world_cup_2026.json \
  --matches-fixture "$matches_fixture" \
  --standings-fixture "$standings_fixture" \
  --output _site/world_cup_2026_updates.json
```

Set the fixture variables to local JSON files that match the football-data.org
response shapes you want to test.
