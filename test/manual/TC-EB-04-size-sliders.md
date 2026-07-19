# TC-EB-04 — Width and height sliders resize live

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- The energy bar is visible (TC-EB-01); `/rgp opt` → Options open

## Steps

1. Move the "Energy Bar Width" slider across its range (50–300, steps of 5)
2. Move the "Energy Bar Height" slider across its range (15–60, steps of 5)
3. Set both sliders to clearly non-default values
4. `/reload`, make the bar appear, and re-open the options

## Expected

- The bar resizes live while dragging each slider — no `/reload` needed
- The sweep texture and the energy number stay properly positioned at every size
  (no overflow, no clipped text at the extremes)
- The chosen values survive `/reload`; the sliders show the persisted values
- No Lua errors
