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

class SpawnProtectionTrait extends BossTrait
{
    roundStartTime = Time();

    function CanApply()
    {
        return API_GetBool("spawn_protection");
    }

    function OnApply()
    {
        AddListener("setup_end", 0, function()
        {
            roundStartTime = Time();
        }, this);
    }

    function OnDamageTaken(attacker, params)
    {
        local scaling = clampCeiling(1, 0.3 + (Time() - roundStartTime) * 0.11);
        params.damage *= scaling;
    }
};