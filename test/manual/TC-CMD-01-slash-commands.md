# TC-CMD-01 — /rgp command surface

**Area:** Slash commands | **Client:** Era | **Mandatory:** yes

## Preconditions

- Addon loaded

## Steps

1. Type `/rgp`
2. Type `/rgp help`
3. Type `/rgp opt`
4. Type `/rgp move`, then `/rgp move` again
5. Type `/rgp foo`
6. Type `/rgp rl` (expect a UI reload)
7. Type `/pulse opt` (alias)
8. Type `/rgp reload` (expect a UI reload)

## Expected

- Bare `/rgp` and `/rgp help` print the info/help text listing the available commands,
  including the `move` line
- `/rgp opt` opens the Pulse options panel
- `/rgp move` enters the positioning mode and a second `/rgp move` leaves it again (TC-EB-06)
- An unknown argument (`foo`) prints the invalid-argument error
- `/rgp rl` and `/rgp reload` both reload the UI
- `/pulse` works identically to `/rgp`
