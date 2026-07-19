# TC-PR-03 — Rename and delete a profile

**Area:** Profiles | **Client:** Era | **Mandatory:** yes

## Preconditions

- At least two saved profiles

## Steps

1. Open `/rgp opt` → Profiles and select a profile
2. Click "Rename"; try an empty name, then the name of the **other** existing profile,
   then a genuinely new name
3. Select the renamed profile and click "Delete", confirm the popup
4. `/reload` and check the list

## Expected

- The rename popup is pre-filled with the current name
- An empty name and a name that already exists are both rejected with a user-visible error
- Renaming to a new name updates the list entry; the profile's content is unchanged
  (spot-check by exporting or applying it)
- Delete asks for confirmation; the profile disappears and does not return after `/reload`
- Neither rename nor delete changes the live configuration
- No Lua errors
