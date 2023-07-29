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

PrecacheScriptSound("scout.marked")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    playInterval = 10;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT
            && WeaponIs(player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE), "fan_o_war");
    }

    function OnDamageDealt(victim, params)
    {
        if ((params.damage_type & 128) && Time() - lastPlay >= playInterval)
        {
            lastPlay = Time();
            EmitPlayerVODelayed(player, "marked", 0.2);
        }
    }
});