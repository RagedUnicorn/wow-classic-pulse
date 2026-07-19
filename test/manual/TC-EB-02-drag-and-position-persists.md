# TC-EB-02 — Drag repositions the bar and persists

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- The energy bar is visible (TC-EB-01); the lock checkbox in `/rgp opt` is **unchecked**

## Steps

1. Drag the bar to a clearly different screen position
2. `/reload` and make the bar appear again (spend energy)
3. Check the bar's position
4. Log out to character select and back in; check again

## Expected

- The bar follows the cursor while dragging and stays where dropped
- The position survives `/reload` and a full relog (persisted per frame in
  `PulseConfiguration.frames`)
- The bar cannot be dragged off-screen (frame is clamped to the screen)
- No Lua errors
