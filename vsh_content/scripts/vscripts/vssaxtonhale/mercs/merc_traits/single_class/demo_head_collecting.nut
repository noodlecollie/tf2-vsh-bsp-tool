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

PrecacheScriptSound("demo.special_01")

characterTraitsClasses.push(class extends CharacterTrait
{
    lastTimeSoundPlayed = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnDamageDealt(victim, params)
    {
        local weapon = params.weapon;
        if (WeaponIs(weapon, "eyelander")
        || WeaponIs(weapon, "eyelander_xmas")
        || WeaponIs(weapon, "headtaker")
        || WeaponIs(weapon, "golf_club")
        || WeaponIs(weapon, "eyelander_xmas"))
            AddHead();
    }

    function AddHead()
    {
        local heads = GetPropInt(player, "m_Shared.m_iDecapitations");
        SetPropInt(player, "m_Shared.m_iDecapitations", heads + 1);
        player.AddCond(TF_COND_DEMO_BUFF);
        player.AddCondEx(TF_COND_SPEED_BOOST, 0.01, 0.01);
        if (player.GetHealth() <= 300)
            player.SetHealth(player.GetHealth() + 15);

        if (heads > 1 && Time() > lastTimeSoundPlayed + 20 && RandomInt(0, 2) == 0)
        {
            lastTimeSoundPlayed = Time();
            EmitPlayerVODelayed(player, "special_01", 0.2);
        }
    }
});