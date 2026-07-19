# Release

> This document explains how a new release is created for Pulse

## Pre-release testing

Complete the test procedure in [test/TESTING.md](test/TESTING.md) before creating any deployment:

* Automated gates - luacheck and busted must be green (locally and in CI)
* Full manual test case catalog ([test/manual/](test/manual/)) on Classic Era
* Smoke checklist on TBC Anniversary
* `TC-VB-01` (version broadcast) if a second account/client is available

## Deployment

* Push all commits before proceeding
* Make sure `build-resources/release-notes.md` are up-to-date
* Make sure Metadata https://github.com/RagedUnicorn/wow-pulse-meta is up-to-date
* Create a GitHub deployment
  * Invoke GitHub action
    * https://github.com/RagedUnicorn/wow-classic-pulse/actions/workflows/release_github.yaml
* Create a CurseForge deployment
  * Invoke CurseForge action
    * https://github.com/RagedUnicorn/wow-classic-pulse/actions/workflows/release_curseforge.yaml
* Create a Wago.io deployment
  * Invoke GitHub action
    * https://github.com/RagedUnicorn/wow-classic-pulse/actions/workflows/release_wago.yaml
