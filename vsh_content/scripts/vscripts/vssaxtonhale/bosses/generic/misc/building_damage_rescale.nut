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

class BuildingDamageRescaleTrait extends BossTrait
{
    function OnDamageDealt(victim, params)
    {
        if (victim == null || IsCollateralDamage(params.damage_type) || victim.GetClassname().find("obj_") == null)
            return;

        local level = GetPropInt(victim, "m_iUpgradeLevel");
        params.damage *= 1 - 0.2 * level;
        if (GetPropInt(victim, "m_nShieldLevel") > 0)
            params.damage *= 3;
    }
};