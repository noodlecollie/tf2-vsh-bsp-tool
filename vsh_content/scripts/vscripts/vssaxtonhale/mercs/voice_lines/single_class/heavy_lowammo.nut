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

PrecacheScriptSound("heavy.low_ammo")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.5;
    wentAbove100 = true;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVY;
    }

    function OnTickAlive(timeDelta)
    {
        local minigunAmmo = GetPropIntArray(player, "m_iAmmo", 1);
        if (minigunAmmo >= 100)
            wentAbove100 = true;
        if (minigunAmmo < 50 && wentAbove100)
        {
            wentAbove100 = false;
            EmitPlayerVO(player, "low_ammo");
        }
    }
});