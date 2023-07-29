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

PrecacheScriptSound("pyro.airblast")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.1;
    playInterval = 20;
    counter = 0.0;
    lastAirblast = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_PYRO;
    }

    function OnTickAlive(timeDelta)
    {
        if (counter > 0)
            counter -= timeDelta * 0.2;
        foreach (boss in GetAliveBossPlayers())
        {
            if (boss.InCond(TF_COND_KNOCKED_INTO_AIR) && (GetPropInt(player, "m_nButtons") & IN_ATTACK2))
            {
                if (Time() > lastAirblast + 0.2)
                    counter+=1;
                lastAirblast = Time();
                if (counter >= 2.1)
                {
                    counter = 0;
                    return EmitPlayerVO(player, "airblast");
                }
            }
        }
    }
});