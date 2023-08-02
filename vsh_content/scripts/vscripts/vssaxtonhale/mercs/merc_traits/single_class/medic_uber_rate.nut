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
        if (player.GetPlayerClass() != TF_CLASS_MEDIC)
            return false;
    }

    function OnDamageDealt(victim, params)
    {
        if (params.damage_type & 128)
        {
            local melee = player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE);
            if (WeaponIs(melee, "ubersaw") || WeaponIs(melee, "ubersaw_xmas"))
                AddPropFloat(player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY), "m_flChargeLevel", 0.25);
        }
    }

    function OnApply()
    {
        local medigun = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
        if (medigun != null)
            medigun.AddAttribute("ubercharge rate bonus", 2, -1);
    }
});