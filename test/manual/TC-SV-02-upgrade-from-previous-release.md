# TC-SV-02 — Upgrade from previous release migrates cleanly

**Area:** SavedVariables | **Client:** Era | **Mandatory:** yes

## Preconditions

- Client fully logged out
- The version bump for the release under test is already applied — `pom.xml` bumped and
  `mvn generate-resources -D generate.sources.overwrite=true` re-run, so `Pulse.toc` carries
  the **new** `## Version:`. `SetAddonVersion()` stamps whatever the TOC says; without the bump
  the version expectation below can neither pass nor fail
- The previous release's schema fixture: `test/manual/fixtures/TC-SV-02-pulse-v1.2.0.lua`
- Backup of the test character's current `WTF/.../SavedVariables/Pulse.lua` taken (to restore
  after the test)

## Steps

1. Copy the fixture over the character's `SavedVariables/Pulse.lua` and delete `Pulse.lua.bak`
2. Log in with an energy-class character
3. Observe the screen and chat for errors
4. Verify the bar renders exactly as configured in the fixture: locked, width 200, height 45,
   anchored `TOPLEFT` to `UIParent`'s `BOTTOMLEFT` at 620/350
5. Open `/rgp opt` and check both the Options and Profiles pages
6. Log out and inspect the SavedVariables file

## Expected

- No Lua errors on login; the defaults backfill (`ApplyDefaults`) runs silently.
  `me.migrationSteps` is currently empty, so no migration step should run or log
- All v1.2.0 user data survives byte-for-byte: `lockEnergyBar = true`, `energyBarWidth = 200`,
  `energyBarHeight = 45`, and the `P_EnergyBar` entry in `frames` unchanged
- The lock checkbox is checked and the sliders show 200/45
- Fields introduced after v1.2.0 are present at their defaults: `snapEnergyBarToGrid = false`,
  `energyBarGridSize = 10`, `lastNotifiedVersion = ""`
- `PulseConfiguration.profiles` is created and holds **exactly one** entry named `Default`,
  seeded by `EnsureDefaultProfile()` from the shipped `DEFAULTS` — i.e. the factory baseline
  (`lockEnergyBar = false`, `energyBarWidth = 120`, `energyBarHeight = 30`,
  `snapEnergyBarToGrid = false`, `energyBarGridSize = 10`, empty `frames`), **not** a snapshot
  of the imported v1.2.0 values. Rename/Delete are greyed out for it (see TC-PR-06)
- `addonVersion` in the file is bumped to the new release version

## Notes

The v1.1.1 and v1.2.0 schemas are identical — `git show v1.1.1:code/Configuration.lua` versus
`v1.2.0` confirms the same five keys — so the fixture covers both hops.

Profiles did not exist in v1.2.0, which is why this case asserts that `profiles` is *created*
rather than *preserved*. When the next release ships, snapshot a v1.3.0-shaped file (one that
does carry saved profiles) into `test/manual/fixtures/` alongside this one and extend the case
to assert those profiles survive unchanged.
