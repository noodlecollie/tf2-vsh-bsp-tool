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

PrecacheClassVoiceLines("last_mann_hiding")

class LastMannHidingVoiceLine extends BossVoiceLine
{
    tickInterval = 1;
    lastTimeSeenAnyMercs = 0;
    wasPlayed = false;

    function OnTickAlive(timeDelta)
    {
        if (GetAliveMercCount() != 1 || startMercCount < 2 || wasPlayed)
            return;
        if (lastTimeSeenAnyMercs == 0)
            lastTimeSeenAnyMercs = Time();

        foreach (target in GetAliveMercs())
        {
            if (!target.InCond(TF_COND_STEALTHED))
            {
                local fraction = TraceLine(boss.EyePosition(), target.GetCenter(), null);
                if (fraction > 0.99)
                {
                    lastTimeSeenAnyMercs = Time();
                    return;
                }
            }
            if (Time() - lastTimeSeenAnyMercs > 15)
            {
                wasPlayed = true;
                return PlayAnnouncerVO(boss, "last_mann_hiding");
            }
        }
    }
};