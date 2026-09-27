# Support last-hit protection

`FunLib/support_last_hits.lua` reserves enemy lane creeps approaching last-hit
health for a living nearby core during laning. Core reach is measured from the
creep (attack range plus 250, capped at 1000), rather than from the support.
The initial health threshold is 2.2 times the larger hero attack damage plus
20: deliberately earlier than a lethal hit, and subject to live tuning.

Immediate, queued and pushed Lua attack orders respect this reservation.
Team-roam releases a retained reserved creep target. Since Valve's native
orders need not go through those Lua wrappers, roaming can briefly preempt
normal laning at desire 0.89. The support denies an eligible allied creep or
repositions behind the core until the reservation no longer applies. Native
laning itself is not replaced.

Retreat, hero damage, tower aggro, explicit pushing, a dead/absent/unreachable
core, or a stunned/disarmed/channeling/retreating core disable the reservation.
The intervention does not interrupt casts, channels or hero attacks. Neutral
creeps, allied denies and core farming are not reserved. Hero-specific spell
use remains unchanged; incidental spell last hits and already-fired projectiles
are outside this patch's protection.

Automated coverage includes 14 behavior scenarios and actual attack-wrapper
checks, in addition to the existing suite. Engine mode arbitration still needs
a fresh Local Dev Script match: lane as a core, check melee/ranged last hits,
denies, and that the support continues defending you. Then leave the lane and
verify the support can farm. Watch for excessive repositioning or lost harass;
the conservative reservation window may need shortening if either occurs.
