# TC-EB-01 — Bar appears and the tick sweep runs

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- An energy-class character (Rogue, or Druid in Cat Form), freshly logged in or after `/reload`

## Steps

1. Note that no energy bar is visible right after login
2. Spend energy (use any ability) and observe the screen
3. Watch the bar while energy regenerates back to full
4. Stay at full energy for a while and keep watching the bar
5. Optional: log in with a non-energy class (e.g. Warrior) and repeat steps 1–2 with rage

## Expected

- The bar appears on the first energy change and then stays visible
- The status bar sweeps from empty to full over the 2-second tick window and resets on each
  energy tick (when energy increases, the sweep restarts)
- The energy number matches the character's actual energy amount and updates on every change
- At full energy the bar keeps sweeping — this is **by design** (it visualizes the ongoing
  regen tick), not a failure
- On a non-energy class the bar never appears
- No Lua errors
