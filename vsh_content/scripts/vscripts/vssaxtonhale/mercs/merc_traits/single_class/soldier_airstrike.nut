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

characterTraitsClasses.push(class extends CharacterTrait
{
    damageAccumulated = 0;
    lastHitWasAirStrike = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnDamageDealt(victim, params)
    {
        lastHitWasAirStrike = WeaponIs(params.weapon, "airstrike");
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (lastHitWasAirStrike)
        {
            damageAccumulated += params.damageamount;
            while (damageAccumulated >= 250)
            {
                AddPropInt(player, "m_Shared.m_iDecapitations", 1);
                damageAccumulated -= 250;
            }
        }
    }
});