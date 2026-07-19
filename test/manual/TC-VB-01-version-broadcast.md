# TC-VB-01 — Version broadcast and update notification

**Area:** Version broadcast | **Client:** Era | **Mandatory:** conditional

> Run only if a second account/client (or a cooperative guild/party member) is available.
> The version difference can be faked by bumping `## Version` in the `.toc` of a second
> checkout — the broadcast sends the running toc version.

## Preconditions

- Two clients in the same guild or party, one running a **newer** Pulse version than the other
- On the older client: a clean session (fresh login) and an empty/older
  `lastNotifiedVersion` in its SavedVariables

## Steps

1. Log both characters in and group them (or rely on the shared guild)
2. Watch the older client's chat frame
3. After the notification appeared, trigger another broadcast (leave and re-join the group)
4. `/reload` the older client and trigger a broadcast again
5. Swap roles: watch the **newer** client while grouped with the older one

## Expected

- The older client prints the update notice ("New version ... is available") shortly after
  login or the roster change
- The notice appears **once per session** — repeated broadcasts do not re-print it
- After `/reload`/relog the notice does not reappear for the same version
  (`lastNotifiedVersion` is persisted)
- The newer client never shows a notice for an equal or older version
- No Lua errors on either client
