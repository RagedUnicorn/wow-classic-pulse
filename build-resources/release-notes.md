## New Features

### Profiles

* Save your current settings as a named profile and switch between them from the new Profiles
  page in the addon options
* Share profiles with other players - export a profile to a chat-safe string and import strings
  from others. Corrupt, truncated or foreign strings are rejected with a clear message instead
  of being applied
* Every install ships with a reserved "Default" profile holding the factory settings - applying
  it is the way back to a clean slate. It cannot be renamed, deleted or overwritten
* Profile names are limited to 30 characters

### Positioning the energy bar

* New "Move Bar" button in the options, and the `/pulse move` command, open a positioning mode:
  the options close, the bar stays visible and draggable, and an on-screen HUD with a Done button
  guides you through it. It works right after login before any energy has been spent, and on a
  locked bar without changing the lock
* New "Snap to Grid" option aligns the bar to an alignment grid when you drop it, with an
  adjustable grid size. The grid is drawn on screen while positioning so you can see what you are
  snapping to
* Snapping is opt-in - existing bar placements stay exactly where they are until the bar is moved
  again

### Other

* The width and height sliders now preview the change on the bar live while you drag them
* Pulse lets you know when a newer version is available, based on version broadcasts from other
  players running the addon
* The addon now shows its icon in the in-game addon list
* Refreshed settings UI
* All new text is available in English, German and Russian
* Updated for WoW Classic Era 1.15.9 (Interface 11509) and TBC Anniversary 2.5.6 (Interface 20506)

## Bug Fixes

* The energy amount is only redrawn when it actually changes, and the bar refreshes at a saner
  interval - the same smooth tick visualization at a fraction of the work per frame
* The energy amount is now always drawn on the first update instead of briefly showing a stale
  value

## Development

* New central event bus replaces the dispatch chain in the addon entry point. Handlers can be
  gated until the login sequence has finished and subscribed per unit, so high-frequency events
  such as `UNIT_POWER_UPDATE` are filtered by the client instead of by the addon
* Configuration defaults are now applied recursively from a single `DEFAULTS` table that serves
  both fresh installs and upgrades, backed by a versioned migration path for future schema changes
* Profile export/import is built on two new dependency-free modules: a length-prefixed serializer
  with a hand-written data-only parser (imported strings are never executed) and a base64 encoder
  with an Adler-32 checksum
* Added a headless test suite running under busted in CI, covering the configuration, profile,
  serializer, encoder, event bus, ticker, filter, command, energy bar, alignment grid and version
  broadcast modules, plus a localization parity check across all three locales
* Added a manual test case catalog under `test/manual/` and documented the procedure in
  `test/TESTING.md` and `RELEASE.md`
* Added a development-only media capture module for recreating the documentation screenshots
* Updated GitHub Actions workflows to Java 21 and normalized them across the project
* Updated the RagedUnicorn Maven plugins, Docker images and Alpine base versions
