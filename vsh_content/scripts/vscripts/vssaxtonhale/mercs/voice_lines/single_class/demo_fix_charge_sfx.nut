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

PrecacheScriptSound("vsh_sfx.demo_charge");

characterTraitsClasses.push(class extends CustomVoiceLine
{
    isInCharge = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnTickAlive(timeDelta)
    {
        local isInChargeNew = player.InCond(TF_COND_SHIELD_CHARGE);
        if (!isInCharge && isInChargeNew)
            EmitSoundOn("vsh_sfx.demo_charge", player);
        isInCharge = isInChargeNew;
    }
});