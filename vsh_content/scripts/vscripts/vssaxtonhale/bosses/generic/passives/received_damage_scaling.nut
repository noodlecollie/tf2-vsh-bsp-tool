//=========================================================================
//Copyright LizardOfOz.
//
//Credits:
//  LizardOfOz - Programming, game design, promotional material and overall development. The original VSH Plugin from 2010.
//  Maxxy - Saxton Hale's model imitating Jungle Inferno SFM; Custom animations and promotional material.
//  Velly - VFX, animations scripting, technical assistance.
//  JPRAS - Saxton model development assistance and feedback.
//  MegapiemanPHD - Saxton Hale and Gray Mann voice acting.
//  James McGuinn - Mercenaries voice acting for custom lines.
//  Yakibomb - give_tf_weapon script bundle (used for Hale's first-person hands model).
//=========================================================================

class ReceivedDamageScalingTrait extends BossTrait
{
    accumulatorHP = 0;

    function OnTickAlive(timeDelta)
    {
        local accDelta = accumulatorHP - boss.GetHealth();
        accumulatorHP -= accDelta * timeDelta / 2;
        if (accumulatorHP < boss.GetHealth())
            accumulatorHP = boss.GetHealth();
    }

    function OnDamageTaken(attacker, params)
    {
        local mercMultiplier = clampFloor(1, 1.85 - (GetAliveMercCount() * 1.0) / startMercCount);

        local accDelta = accumulatorHP - boss.GetHealth();
        local resistance = 0.5 + clampFloor(0, 0.5 - (accDelta / 4000.0));

        local totalMultiplier = mercMultiplier * resistance;
        if (totalMultiplier <= 0.9 || totalMultiplier >= 1.1)
            params.damage *= totalMultiplier;
    }
};