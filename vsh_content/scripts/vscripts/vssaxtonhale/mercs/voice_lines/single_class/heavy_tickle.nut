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

PrecacheScriptSound("heavy.tickle")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.5;
    playInterval = 20;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_HEAVY
            && WeaponIs(player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE), "holiday_punch");
    }

    function OnTickAlive(timeDelta)
    {
        local weapon = player.GetActiveWeapon();
        if (weapon == null || weapon.GetSlot() != TF_WEAPONSLOTS.MELEE)
            return;
        local myCenter = player.GetCenter();
        foreach (boss in GetAliveBossPlayers())
        {
            local distanceToBoss = (boss.GetCenter() - myCenter).Length()
            if (distanceToBoss < 400)
                return EmitPlayerVO(player, "tickle");
        }
    }
});