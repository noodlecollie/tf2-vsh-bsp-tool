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

PrecacheScriptSound("spy.special_01")
PrecacheScriptSound("spy.noinvis")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    playInterval = 20;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnDamageTaken(attacker, params)
    {
        if (params.damage < 30 && player.GetHealth() > 50 && RandomInt(0, 2) == 0 && !player.InCond(TF_COND_STEALTHED))
            RunWithDelay2(this, 0, function()
            {
                if (IsPlayerAlive(player) && player.InCond(TF_COND_STEALTHED))
                    EmitPlayerVODelayed(player, "special_01", 1.5)
            });
    }

    function OnTickAlive(inverval)
    {
        if (!(GetPropInt(player, "m_nButtons") & IN_ATTACK2))
            return;
        local cloak = player.GetSpyCloakMeter();
        local isDR = WeaponIs(player.GetWeaponBySlot(TF_WEAPONSLOTS.INVIS_WATCH), "dead_ringer");
        if (
            (isDR && cloak > 85 && cloak < 100)
            || (!isDR && cloak < 10 && !player.InCond(TF_COND_STEALTHED)))
        {
            local myCenter = player.GetCenter();
            foreach (boss in GetAliveBossPlayers())
            {
                local distanceToBoss = (boss.GetCenter() - myCenter).Length()
                if (distanceToBoss < 600)
                    return EmitPlayerVO(player, "noinvis");
            }
        }
    }
});