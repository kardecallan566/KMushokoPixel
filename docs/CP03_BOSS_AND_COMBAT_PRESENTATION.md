# CP03: readable pixel-art battles and Lobo Alfa phase two

## Scope

Improve on-screen clarity without changing the pixel grid established by CP02B or adding new equipment systems. All feedback is original *runtime-drawn* pixel art using integer coordinates and a 2x/3x nearest-neighbor root scale. No stock/ripped or AI concept-sheet assets are imported into the game.

### Visual feedback
- Rudeus: flying earthy stones with dust pixel trails and physical impact.
- Roxy: water drops and icy shards, clearly different from Rudeus's stones.
- Sylphie: green cross for healing; protective outlined rectangle for shields.
- Eris: close-range slash with red-orange impact.
- Enemies: visible claw streaks or expanding area-warning effect.
- Telegraph: striped amber-red indicator near the team's ground position, shown before attack. Separate warning text for charge/howl in expanded; compact short warning.
- Draw ordering: `world` z -20, hero/enemy z 3, foreground 8, CombatFx 12, HUD 20. Pixel VFX cannot cover the HUD.
- Existing bitmap sprites remain unchanged while we await side-by-side approval against the Reel.

### Boss logic
- At or below **55% HP**, Lobo Alfa enters phase two **once** and summons two standard wolves. They participate normally in combat and rewards.
- The boss alternates between a telegraphed **charge** (focused impact) and **shadow howl** (AoE). Time to react is extended for AoE.
- Freezing the boss during windup cancels the current attack and resets its attack clock, allowing Roxy a unique tactical role.
- Sylphie's shields absorb damage before HP loss, protecting against AoE; Eris maintains frontline priority; Rudeus remains a boss damage dealer and armor breaker.
- Stats, progress, and loot remain inside the window-independent `GameSession`; `CombatFx` is presentation-only.

## Controls
Same as CP02B: Tab compact/expanded; Space pause; H HUD; U upgrade; F farm; T always-on-top; S save; Esc exit compact.

## Acceptance checks
- CI parses all GDScript and runs 180 frames headless, CP02 10-stage progression, CP03 boss patterns and FX instantiation.
- Both UI modes have readable telegraphs and projectiles.
- Swapping viewport discards only temporary VFX, not battle state or loot.
- No new renderer filters, scaled fractional character sprites or enemy art modifications.
- The artwork still requires approval on a physical Windows display; headless tests do not certify visual fidelity to the Reel.

## Next checkpoint
Once gameplay and artistic readability are accepted, move to CP04 richer player abilities and then CP05 equipment/inventory. Avoid multiplying biomes before animation/style approval.
