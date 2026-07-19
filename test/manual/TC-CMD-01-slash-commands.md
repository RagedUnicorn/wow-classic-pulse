# TC-CMD-01 — /rgp command surface

**Area:** Slash commands | **Client:** Era | **Mandatory:** yes

## Preconditions

- Addon loaded

## Steps

1. Type `/rgp`
2. Type `/rgp help`
3. Type `/rgp opt`
4. Type `/rgp foo`
5. Type `/rgp rl` (expect a UI reload)
6. Type `/pulse opt` (alias)
7. Type `/rgp reload` (expect a UI reload)

## Expected

- Bare `/rgp` and `/rgp help` print the info/help text listing the available commands
- `/rgp opt` opens the Pulse options panel
- An unknown argument (`foo`) prints the invalid-argument error
- `/rgp rl` and `/rgp reload` both reload the UI
- `/pulse` works identically to `/rgp`
