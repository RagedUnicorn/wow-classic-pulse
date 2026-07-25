# TC-EB-06 — Positioning mode and the grid overlay

**Area:** EnergyBar | **Client:** Era | **Mandatory:** yes

## Preconditions

- Addon loaded on an energy class

## Steps

1. Log in and, **before spending any energy**, type `/rgp opt` → Options and click "Move Bar"
2. Drag the bar around, then click "Done"
3. Open the options again, click "Move Bar", and this time leave the mode by pressing Escape
4. Enter with `/pulse move` (no options window open) and leave it with "Done"
5. Enter with `/pulse move` again, then leave it by typing `/pulse move` a second time
6. Check "Lock EnergyBar", then enter the mode and try to drag the bar
7. With "Snap to Grid" unchecked, enter the mode; then leave, check "Snap to Grid", and enter again
8. While in the mode with snapping on, drop the bar on a grid intersection
9. Enter the mode while in combat (or with the options window open in combat)

## Expected

- Clicking "Move Bar" closes the options window and leaves the bar visible and draggable —
  including on a fresh login where no energy has been spent yet
- The HUD appears with its instruction line and a Done button; it never moves with the bar and
  stays reachable no matter where the bar is dragged
- The instruction mentions the top-left corner snapping to the grid **only** when "Snap to Grid"
  is enabled, and reverts to the plain wording when it is not — check this in deDE and ruRU too,
  where the text wraps to two lines and must stay inside the HUD
- Clicking "Done" after entering from the options panel leaves the mode **and reopens the options
  on the General panel**, with its controls in the state they were left in
- Escape and a second `/pulse move` also leave the mode, but do **not** reopen the options
- Clicking "Done" after entering with `/pulse move` (no options window open) simply leaves the
  mode — it must not conjure up an options window the user never opened
- Leaving the mode restores the bar's previous visibility: a bar that was hidden before is hidden
  again, a bar that was already on screen stays on screen
- A **locked** bar can still be dragged inside the mode, and is still locked afterwards — the
  checkbox state is never changed
- The grid appears only while the mode is active **and** snapping is enabled; it is never visible
  during normal play, and the game menu and any confirmation popup still render above the HUD
- The dropped bar's top-left corner lands exactly on a visible line intersection
- In combat the mode still works; at worst the options window stays open (closing it is a
  protected action) — no Lua error and no blocked-action spam
- No Lua errors
