## Improvements

* The Profiles page now has a slim scrollbar, so long profile lists stay usable
* Pulse now appears under the RagedUnicorn category in the in-game addon list
* Updated the supported game versions for WoW Classic Era and TBC Anniversary

## Bug Fixes

### Profiles

* The reserved "Default" profile is now refreshed on every login. Previously it was saved once, so
  settings added in later versions were missing from it and applying "Default" kept your
  customized value for them instead of resetting them
* Renaming a profile to its own name no longer deletes it
* Imported profile strings are checked much more strictly: only known profile settings are kept,
  overly long pastes are rejected, a broken profile name is dropped, and every value (bar size,
  grid size, position) must be in range before anything is stored. A crafted string can no longer
  place the bar off screen or freeze the client with a tiny grid size
* Profile strings containing invalid numbers (infinity, NaN, non-decimal notation) are rejected
  instead of causing an error

### Version check

* The update notice only reacts to well-formed version numbers
* The version is broadcast over the instance channel in battleground groups
* The version is announced to the guild only once at login instead of on every group change, and
  a broadcast that hits the cooldown is sent shortly afterwards instead of being dropped

### Other

* Strings that are not yet translated in German or Russian now fall back to English instead of
  showing nothing
* An error during login initialization no longer leaves the energy bar permanently unresponsive

## Development

* Private helpers across all modules are now plain local functions defined above their first
  caller, and the convention is documented in `DEVELOPMENT.md`
* Removed unused colour and profile constants; read-only globals are declared as `read_globals`
  in the luacheck setup
* The release workflows are gated on luacheck, the busted suite and a package contents check
* Added `timeout-minutes` to all GitHub Actions jobs and skip the generate-sources job for fork
  pull requests
* Packaging now uses the addon folder name, and the build tooling is aligned with the other
  RagedUnicorn AddOns
* Documented the log-tag filter as a debugging tool and updated the store links
