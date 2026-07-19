# TC-EB-03 — Lock prevents dragging

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- The energy bar is visible (TC-EB-01)

## Steps

1. Open `/rgp opt` → Options and check "Lock EnergyBar"
2. Close the panel and attempt to drag the bar
3. Uncheck the lock again and attempt another drag
4. Re-check the lock, then `/reload` and verify the checkbox state

## Expected

- Locked: dragging has no effect — the bar does not move
- The lock takes effect immediately, no `/reload` needed
- Unlocked: the bar can be dragged again
- The lock state survives `/reload` and the checkbox reflects it
- No Lua errors
