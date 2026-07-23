# TC-SV-01 — Fresh install seeds defaults

**Area:** SavedVariables | **Client:** Era | **Mandatory:** yes

## Preconditions

- Client fully logged out
- Backup of the character's current `WTF/.../SavedVariables/Pulse.lua` taken (to restore after the test)

## Steps

1. Delete `Pulse.lua` (and `Pulse.lua.bak`) from the character's `SavedVariables` folder
2. Log in with an energy-class character
3. Observe the screen and chat for errors
4. Spend some energy so the bar appears
5. Open `/rgp opt` and check both the Options and Profiles pages
6. Log out and inspect the SavedVariables file

## Expected

- No Lua errors on login; the welcome message prints
- The bar appears centered on screen (default position) at the default size (width 120, height 30)
- The lock checkbox is unchecked, the sliders show 120/30, the profile list holds exactly one
  entry named "Default" (see TC-PR-06)
- After logout, `PulseConfiguration` contains `lockEnergyBar = false`, `energyBarWidth = 120`,
  `energyBarHeight = 30`, an empty `frames` table, an empty `lastNotifiedVersion`,
  and `addonVersion` stamped with the current version
- `PulseConfiguration.profiles` holds the seeded `Default` profile with `lockEnergyBar = false`,
  `energyBarWidth = 120`, `energyBarHeight = 30` and an empty `frames` table
