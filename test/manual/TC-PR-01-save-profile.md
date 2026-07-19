# TC-PR-01 — Save current configuration as profile

**Area:** Profiles | **Client:** Era | **Mandatory:** yes

## Preconditions

- A recognizable configuration (bar moved to a distinct position, non-default width/height,
  lock state set deliberately)

## Steps

1. Open `/rgp opt` → Profiles
2. Click "Save current as..." and enter a new profile name
3. Change one setting (e.g. the width slider), then save again under the **same** name

## Expected

- The profile appears in the saved-profiles list
- Saving under an existing name overwrites that profile (no duplicate entry)
- The profile captures the full setup: lock state, bar width and height, and the bar position
- Profiles persist across `/reload` (stored per character in `PulseConfiguration.profiles`)
- No Lua errors
