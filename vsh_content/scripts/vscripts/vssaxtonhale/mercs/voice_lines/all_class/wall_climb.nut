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

PrecacheClassVoiceLines("wall_climb")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.5;
    sharedPlayInterval = 20;
    sharedPlayPool = 3;
    lastTimePlayedLine = {};
    climbLineTimesPlayed = [0];
    wallClimbListener = null;

    function OnApply()
    {
        wallClimbListener = AddListener("wall_climb", 0, OnWallClimb, this);
    }

    function OnWallClimb(otherPlayer, streak, quickFixLink)
    {
        if (quickFixLink || player != otherPlayer || !ShouldPlayVoiceLine())
            return;

        local inverseChance = climbLineTimesPlayed[0]++ < 3 ? 3 : 5;
        if (player.GetPlayerClass() == TF_CLASS_SCOUT)
            inverseChance *= 2;
        if (RandomInt(0, inverseChance) == 0)
        {
            lastTimePlayedLine[player] <- Time();
            EmitPlayerVODelayed(player, "wall_climb", 0.2);
        }
    }

    function ShouldPlayVoiceLine()
    {
        if (lastTimePlayedLine.len() > 200) //Easy anti-memory leak fix
            lastTimePlayedLine = {};
        local time = Time();
        local playSlotsOccupied = 0;
        foreach (otherPlayer, lastPlayTime in lastTimePlayedLine)
            if (time - lastPlayTime < sharedPlayInterval
                && (++playSlotsOccupied >= sharedPlayPool || player == otherPlayer))
                    return false;
        return true;
    }

    function OnDiscard()
    {
        RemoveListener(wallClimbListener);
    }
});