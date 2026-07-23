# Release Testing

> This document describes the test procedure that must pass before a new Pulse release is created.
> Deployment steps live in [RELEASE.md](../RELEASE.md); this document is the testing gate referenced there.

A release passes when:

* All automated gates are green
* All mandatory manual test cases in [test/manual/](manual/) pass on Classic Era
* The smoke checklist passes on TBC Anniversary
* Zero Lua errors occurred during the whole run

Before starting the in-game runs, enable script errors so nothing is swallowed:

```
/console scriptErrors 1
```

## 1. Automated gates

Run locally (Docker required):

```bash
# lua linting
docker compose run --rm luacheck

# busted unit tests (test/headless/spec/)
docker compose run --rm busted
```

Additionally verify that CI is green on `master` for the latest commit:

* `lint.yaml` - luacheck
* `test.yaml` - busted

Both must pass with zero failures before any in-game testing starts.

## 2. In-game test matrix

The dev checkout in `Interface/AddOns/Pulse` is what gets tested - no packaged build required.
All in-game cases require an **energy class** (Rogue, or Druid in Cat Form) — the energy bar
only ever reacts to player energy.

| Client          | Interface | Coverage                                      |
|-----------------|-----------|-----------------------------------------------|
| Classic Era     | 11508     | Full manual catalog ([test/manual/](manual/)) |
| TBC Anniversary | 20506     | Smoke checklist (below)                       |

The `TC-VB-01` version broadcast case is **conditional**: run it only if a second
account/client (or a cooperative guild/party member) is available.

## 3. Smoke checklist (TBC Anniversary)

A short pass to confirm the addon behaves on the non-primary client:

- [ ] Addon loads without errors on login; the welcome message prints
- [ ] The energy bar appears after the first energy change and the 2-second sweep runs
- [ ] The energy number tracks the actual energy amount
- [ ] Dragging the unlocked bar works; the lock checkbox prevents dragging
- [ ] `/rgp opt` opens the options panel; width/height sliders resize the bar live
- [ ] Quick profile round trip: save, export, import under a new name, apply
- [ ] `/reload` produces no Lua errors

## 4. Manual test case catalog (Classic Era)

One file per test case under [test/manual/](manual/). Case IDs follow `TC-<AREA>-<NN>`.

### SavedVariables lifecycle (mandatory every release)

| ID                                                           | Case                                           |
|--------------------------------------------------------------|------------------------------------------------|
| [TC-SV-01](manual/TC-SV-01-fresh-install.md)                 | Fresh install seeds defaults                   |
| [TC-SV-02](manual/TC-SV-02-upgrade-from-previous-release.md) | Upgrade from previous release migrates cleanly |

### EnergyBar

| ID                                                        | Case                                  |
|-----------------------------------------------------------|---------------------------------------|
| [TC-EB-01](manual/TC-EB-01-bar-appears-and-ticks.md)      | Bar appears and the tick sweep runs   |
| [TC-EB-02](manual/TC-EB-02-drag-and-position-persists.md) | Drag repositions the bar and persists |
| [TC-EB-03](manual/TC-EB-03-lock-prevents-drag.md)         | Lock prevents dragging                |
| [TC-EB-04](manual/TC-EB-04-size-sliders.md)               | Width and height sliders resize live  |

### Slash commands

| ID                                              | Case                 |
|-------------------------------------------------|----------------------|
| [TC-CMD-01](manual/TC-CMD-01-slash-commands.md) | /rgp command surface |

### Profiles

| ID                                                       | Case                                  |
|----------------------------------------------------------|---------------------------------------|
| [TC-PR-01](manual/TC-PR-01-save-profile.md)              | Save current configuration as profile |
| [TC-PR-02](manual/TC-PR-02-apply-profile.md)             | Apply profile restores configuration  |
| [TC-PR-03](manual/TC-PR-03-rename-and-delete-profile.md) | Rename and delete a profile           |
| [TC-PR-04](manual/TC-PR-04-export-import-round-trip.md)  | Export / import round-trip            |
| [TC-PR-05](manual/TC-PR-05-corrupted-import-rejected.md) | Corrupted import string rejected      |
| [TC-PR-06](manual/TC-PR-06-default-profile.md)           | Default profile seeded and immutable  |

### Version broadcast (conditional)

| ID                                               | Case                                      |
|--------------------------------------------------|-------------------------------------------|
| [TC-VB-01](manual/TC-VB-01-version-broadcast.md) | Version broadcast and update notification |

## 5. Notes

* Localization is covered by the busted spec `LocalizationParitySpec` (key parity of `deDE`
  and `ruRU` against `enUS`) - no manual locale pass is required.
* The bar staying visible and sweeping at full energy is **by design** — it visualizes the
  ongoing 2-second regen tick. Do not report it as a failure.
* Keep a copy of the previous release's `Pulse.lua` SavedVariables file around - it is the
  input for [TC-SV-02](manual/TC-SV-02-upgrade-from-previous-release.md).
* SavedVariables live at
  `WTF/Account/<ACCOUNT>/<Server>/<Character>/SavedVariables/Pulse.lua`.
  Only touch this file while the client is fully logged out.
