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
    function CanApply()
    {
        local playerClass = player.GetPlayerClass();
        return playerClass == TF_CLASS_SOLDIER || playerClass == TF_CLASS_DEMOMAN;
    }

    function OnDamageDealt(victim, params)
    {
        if (WeaponIs(params.weapon, "half_zatoichi"))
        {
            local newHealth = player.GetHealth() + player.GetMaxHealth() / 2.0;
            local maxOverheal = player.GetMaxHealth() * 1.5
            player.SetHealth(clampCeiling(newHealth, maxOverheal));
			SetPropInt(params.weapon, "m_bIsBloody", 1);
			AddPropInt(player, "m_Shared.m_iKillCountSinceLastDeploy", 1);
        }
    }
});