# TC-EB-05 — Snap to grid aligns the dropped bar

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- The energy bar is visible (TC-EB-01) and unlocked (TC-EB-03); `/rgp opt` → Options open

## Steps

1. With "Snap to Grid" unchecked, drag the bar to an arbitrary spot and drop it — placement must stay free
2. Check "Snap to Grid", leave "Grid Size" at its default (10)
3. Drag the bar a few pixels and drop it — repeat from several directions
4. Move the "Grid Size" slider across its range (5–50, steps of 5) and drop the bar again at 5 and at 50
5. `/reload`, make the bar appear, and re-open the options

## Expected

- With snapping off the bar lands exactly where it is dropped (unchanged behaviour)
- With snapping on the bar visibly jumps onto the nearest grid position on drop, its top-left
  corner landing on a grid intersection; dropping it repeatedly within the same cell lands it
  on the same spot
- A larger grid size produces visibly coarser jumps; the bar never leaves the screen
- The checkbox state, the grid size and the snapped position all survive `/reload`
- Toggling snapping does not move an already placed bar — only the next drop realigns it
- No Lua errors
