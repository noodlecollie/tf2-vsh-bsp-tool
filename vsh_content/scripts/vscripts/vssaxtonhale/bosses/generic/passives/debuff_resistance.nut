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

class DebuffResistanceTrait extends BossTrait
{
    static debuffConds = [
        TF_COND_URINE,
        TF_COND_MARKEDFORDEATH,
    ];

    function OnTickAlive(timeDelta)
    {
        foreach(debuffCond in debuffConds)
            boss.SetCondDuration(debuffCond, boss.GetCondDuration(debuffCond) - timeDelta);
    }
};