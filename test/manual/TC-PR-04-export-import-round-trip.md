# TC-PR-04 — Export / import round-trip

**Area:** Profiles | **Client:** Era | **Mandatory:** yes

## Preconditions

- A saved profile with recognizable settings (TC-PR-01)

## Steps

1. Open `/rgp opt` → Profiles, select the profile and click "Export"
2. Copy the string from the *Profile String* box (Ctrl+C)
3. Delete the source profile (or switch to a second character — profiles are stored per
   character, and cross-character transfer is the point of export/import)
4. Paste the string into the *Profile String* box and click "Import"
5. Accept or adjust the name in the import popup
6. Apply the imported profile (TC-PR-02)

## Expected

- Export fills the box with a copy-pasteable string starting with `Pulse1:`; the full string
  is selected and focused for copying
- Import validates the string and prompts for a name, pre-filled with the exported profile's
  name; an empty name or a name that already exists is rejected
- Importing creates the profile in the list but does **not** change the live configuration
- After applying, the configuration matches the originally exported setup exactly
- The string box is cleared after a successful import
- No Lua errors
