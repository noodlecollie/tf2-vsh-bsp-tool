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

class ScreenShakeTrait extends BossTrait
{
    function OnTickAlive(timeDelta)
    {
        if (boss.GetAbsVelocity().Length() < 200)
            return;
        local bossOrigin = boss.GetOrigin();
        foreach(target in GetAliveMercs())
        {
            if (target == boss)
                continue;
            local targetOrigin = target.GetOrigin();
            local distance = (bossOrigin - targetOrigin).Length();
            if (distance > 1600)
                continue;
            local shakeFactorAmp = clamp((1600 - distance) / 100, 3, 10) / 2;
            local shakeFactorDur = clamp((1600 - distance) / 1000, 0.1, 1);
            ScreenShake(targetOrigin, shakeFactorAmp, 16, shakeFactorDur, 50, 0, true);
        }
    }

    function OnDamageDealt(victim, params)
    {
        if (victim != null && victim.IsValid())
            ScreenShake(victim.GetCenter(), 140, 1, 1, 10, 0, true);
    }
};