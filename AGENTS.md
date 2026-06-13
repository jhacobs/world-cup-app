# Repository Guidelines

## Project Structure & Module Organization

This repository contains a Flutter mobile app in `world_cup_app/`.

- `world_cup_app/lib/` contains Dart application code. The app entry point is `lib/main.dart`.
- `world_cup_app/test/` contains Flutter widget and unit tests.
- `world_cup_app/docs/` contains product and project documentation, including `docs/requirements.md`.
- `world_cup_app/android/` and `world_cup_app/ios/` contain platform-specific Flutter project files.
- Generated folders such as `.dart_tool/` and `build/` should not be edited manually.

## Build, Test, and Development Commands

Run commands from `world_cup_app/`:

- `flutter pub get` installs Dart and Flutter dependencies.
- `flutter run` starts the app on an available emulator, simulator, or device.
- `flutter test` runs the test suite in `test/`.
- `flutter analyze` runs Dart static analysis using `analysis_options.yaml`.
- `flutter build apk` builds an Android APK for release testing.

## Coding Style & Naming Conventions

Follow standard Dart and Flutter style with 2-space indentation. Use `dart format .` before submitting code. Keep widget classes in `PascalCase`, methods and variables in `camelCase`, and private members prefixed with `_`.

Prefer small, focused widgets over large build methods. Keep app code under `lib/`, tests under `test/`, and documentation under `docs/`.

## Testing Guidelines

Use `flutter_test` for widget and unit tests. Name test files with the `_test.dart` suffix, for example `match_card_test.dart`. Add or update tests when changing user-visible behavior, navigation, state handling, or data formatting.

Run both `flutter test` and `flutter analyze` before opening a pull request.

## Design & Figma Guidelines

Use the Figma project named `World Cup 2026 Game Tracker` for design references, mockups, and UI handoff work. Keep Flutter UI changes aligned with that project when implementing screens, components, and visual updates.

## Commit & Pull Request Guidelines

Use Conventional Commits for commit messages. Keep the subject concise and imperative, for example `feat: add match schedule view`, `fix: correct knockout result display`, or `docs: update requirements`.

Pull requests should include a short description, testing notes, and screenshots or recordings for UI changes. Link related issues when available, and keep each PR focused on one logical change.

## Security & Configuration Tips

Do not commit secrets, signing keys, or local machine paths. Keep environment-specific configuration out of source control unless it is a safe template.
