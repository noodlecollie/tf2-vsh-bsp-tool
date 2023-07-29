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

PrecacheScriptSound("spy.left_last")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 1;
    lastTimeSeenByBoss = 0;
    wasPlayed = false;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SPY;
    }

    function OnTickAlive(timeDelta)
    {
        if (GetAliveMercCount() != 1 || startMercCount < 2 || wasPlayed)
            return;
        if (lastTimeSeenByBoss == 0)
            lastTimeSeenByBoss = Time();

        if (!player.InCond(TF_COND_STEALTHED))
        {
            local fraction = TraceLine(GetRandomBossPlayer().EyePosition(), player.GetCenter(), null);
            if (fraction > 0.99)
            {
                lastTimeSeenByBoss = Time();
                return;
            }
        }
        if (Time() - lastTimeSeenByBoss > 10)
        {
            wasPlayed = true;
            return EmitPlayerVO(player, "left_last");
        }
    }
});