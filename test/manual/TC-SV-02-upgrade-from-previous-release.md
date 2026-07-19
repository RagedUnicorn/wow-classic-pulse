# TC-SV-02 — Upgrade from previous release migrates cleanly

**Area:** SavedVariables | **Client:** Era | **Mandatory:** yes

## Preconditions

- Client fully logged out
- A `Pulse.lua` SavedVariables file produced by the **previous release** is available
  (ideally with a moved bar position, non-default sizes and at least one saved profile in it)

## Steps

1. Place the previous release's `Pulse.lua` into the character's `SavedVariables` folder
2. Log in with the character
3. Observe the screen and chat for errors
4. Verify the bar renders exactly as configured in the old file (position, width, height, lock state)
5. Open `/rgp opt` and check the saved profiles are still present
6. Log out and inspect the SavedVariables file

## Expected

- No Lua errors on login; `MigrationPath()` / defaults backfill runs silently
- All user data (bar position, sizes, lock state, profiles) survives unchanged
- Newly introduced configuration fields are present with their default values
- `addonVersion` in the file is bumped to the new release version
