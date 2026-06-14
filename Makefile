.DEFAULT_GOAL := help

.PHONY: help run run-offline build-apk build-apk-offline build-appbundle build-ios require-update-url

UPDATE_FILE := world_cup_2026_updates.json
PAGES_URL = $(shell gh api "repos/$$(gh repo view --json nameWithOwner -q .nameWithOwner)/pages" --jq .html_url 2>/dev/null)
WORLD_CUP_UPDATES_URL ?= $(if $(PAGES_URL),$(patsubst %/,%,$(PAGES_URL))/$(UPDATE_FILE),)
DART_DEFINE = --dart-define=WORLD_CUP_UPDATES_URL=$(WORLD_CUP_UPDATES_URL)
ARGS ?=

help:
	@printf '%s\n' 'World Cup app targets:'
	@printf '%s\n' '  make run                         Run app with WORLD_CUP_UPDATES_URL'
	@printf '%s\n' '  make run-offline                 Run app from bundled baseline only'
	@printf '%s\n' '  make build-apk                   Build APK with WORLD_CUP_UPDATES_URL'
	@printf '%s\n' '  make build-apk-offline           Build APK from bundled baseline only'
	@printf '%s\n' '  make build-appbundle             Build app bundle with WORLD_CUP_UPDATES_URL'
	@printf '%s\n' '  make build-ios                   Build iOS release with WORLD_CUP_UPDATES_URL'
	@printf '%s\n' ''
	@printf '%s\n' 'Optional: pass ARGS="..." to forward extra Flutter flags.'
	@printf '%s\n' 'Optional: set WORLD_CUP_UPDATES_URL=... to override GitHub Pages lookup.'

require-update-url:
	@if [ -z "$(WORLD_CUP_UPDATES_URL)" ]; then \
		printf '%s\n' 'WORLD_CUP_UPDATES_URL is empty.'; \
		printf '%s\n' 'Set it manually or configure GitHub Pages so gh can resolve it:'; \
		printf '%s\n' '  make run WORLD_CUP_UPDATES_URL=https://example.com/world_cup_2026_updates.json'; \
		exit 1; \
	fi

run: require-update-url
	flutter run "$(DART_DEFINE)" $(ARGS)

run-offline:
	flutter run $(ARGS)

build-apk: require-update-url
	flutter build apk "$(DART_DEFINE)" $(ARGS)

build-apk-offline:
	flutter build apk $(ARGS)

build-appbundle: require-update-url
	flutter build appbundle "$(DART_DEFINE)" $(ARGS)

build-ios: require-update-url
	flutter build ios "$(DART_DEFINE)" $(ARGS)
