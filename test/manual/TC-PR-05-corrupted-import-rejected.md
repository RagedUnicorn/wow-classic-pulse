# TC-PR-05 — Corrupted import string rejected

**Area:** Profiles | **Client:** Era | **Mandatory:** yes

## Preconditions

- A valid exported profile string to mutate (TC-PR-04)

## Steps

1. Paste the valid string into the *Profile String* box, but change a few characters in
   the middle (breaks the Adler-32 checksum), then click "Import"
2. Repeat with clearly invalid input: an empty box, random text (`hello world`), a string
   with the prefix stripped, and an export string from another addon if available
   (e.g. a GearMenu profile string)

## Expected

- Every invalid string is **rejected with a user-visible error message**
- No profile is created; the existing profile list and the live configuration are untouched
- No Lua errors — rejection is a handled failure (checksum/parse validation in
  `code/Encoder.lua` / `code/Serializer.lua` / `code/Profile.lua`), never a crash
