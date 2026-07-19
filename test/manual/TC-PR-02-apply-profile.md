# TC-PR-02 — Apply profile restores configuration

**Area:** Profiles | **Client:** Era | **Mandatory:** yes

## Preconditions

- A saved profile (TC-PR-01)

## Steps

1. Change several settings away from the profile's state (move the bar, change both sliders,
   toggle the lock)
2. Open `/rgp opt` → Profiles, select the profile and click "Apply"
3. Read the confirmation popup, then **decline** it
4. Click "Apply" again and **confirm**
5. Wait for the UI reload
6. With no profile selected, click "Apply"

## Expected

- Applying shows a confirmation popup warning that current settings are overwritten and the
  UI reloads
- Declining changes nothing — the modified settings stay active
- Confirming applies the snapshot and immediately triggers `ReloadUI()`
- After the reload, the configuration matches the profile exactly: lock state, width, height,
  bar position
- "Apply" without a selection prints the "no profile selected" error instead of a popup
- No Lua errors during apply or after the reload
