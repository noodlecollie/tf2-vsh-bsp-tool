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

PrecacheClassVoiceLines("behind")
PrecacheClassVoiceLines("above")
PrecacheClassVoiceLines("contact")
PrecacheScriptSound("medic.contact_uber")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.5;
    sharedPlayInterval = 20;
    sharedPlayPool = 3;
    lastTimeBossWasInSightline = Time() + API_GetFloat("setup_length") + 10;
    lastTimeLookedAtBoss = Time() + API_GetFloat("setup_length") + 10;
    lastTimePlayedLine = {};

    function OnTickAlive(tickDelta)
    {
        local boss = GetBossPlayers()[0]; //todo supports only 1 boss
        if (!IsValidBoss(boss) || !IsPlayerAlive(boss) || GetAliveMercCount() <= 1)
            return;
        local time = Time();

        //Checking light of sight between this player and Boss
        if (TraceLine(player.EyePosition(), boss.GetCenter(), null) < 0.99)
            return;

        local deltaVector = boss.GetCenter() - player.EyePosition();
        local playerEyes = player.EyeAngles().Forward();
        local dot = playerEyes.Dot(deltaVector);

        if (!ShouldPlayVoiceLine(time))
            return UpdateTimers(dot);

        local deltaVectorXY = Vector(deltaVector.x, deltaVector.y, 0);
        local playerEyesXY = Vector(playerEyes.x, playerEyes.y, 0);

        local distanceToBoss = deltaVector.Length();
        local distanceToBossXY = deltaVectorXY.Length();

        deltaVector.Norm();
        playerEyes.Norm();
        deltaVectorXY.Norm();
        playerEyesXY.Norm();

        local dotXY = playerEyesXY.Dot(deltaVectorXY);
        local deltaZ = boss.IsOnGround() ? 0 : deltaVector.z;
        local timeWithNoSightline = time - lastTimeBossWasInSightline;
        local timeNotLookedAtBoss = time - lastTimeLookedAtBoss;

        if (deltaZ > 0.3 && timeNotLookedAtBoss > 4 && distanceToBossXY < 1300)
        {
            lastTimePlayedLine[player] <- time;
            EmitFromSomeoneElse("above");
        }
        else if (dotXY < -0.3 && timeNotLookedAtBoss > 7 && distanceToBoss < 1300)
        {
            lastTimePlayedLine[player] <- time;
            EmitFromSomeoneElse("behind");
        }
        else if (dotXY > 0.2 && timeWithNoSightline > 7)
        {
            lastTimePlayedLine[player] <- time;
            if (player.GetPlayerClass() == TF_CLASS_MEDIC && GetPropFloat(player.GetActiveWeapon(), "m_flChargeLevel") >= 1.0)
                EmitPlayerVO(player, "contact_uber");
            else
                EmitPlayerVO(player, "contact");
        }

        UpdateTimers(dot);
    }

    function UpdateTimers(dotProduct)
    {
        lastTimeBossWasInSightline = Time();
        if (dotProduct > 0.3)
            lastTimeLookedAtBoss = lastTimeBossWasInSightline;
    }

    function ShouldPlayVoiceLine(time)
    {
        if (lastTimePlayedLine.len() > 200) //Easy anti-memory leak fix
            lastTimePlayedLine = {};
        local playSlotsOccupied = 0;
        foreach (teammate, lastPlayTime in lastTimePlayedLine)
            if (time - lastPlayTime < sharedPlayInterval
                && (++playSlotsOccupied >= sharedPlayPool || player == teammate || time - lastPlayTime < 3))
                    return false;
        return true;
    }

    function EmitFromSomeoneElse(soundLine)
    {
        local aliveMercs = GetAliveMercs();
        if (aliveMercs.len() < 2)
            return;

        local clDist = 1500;
        local clTeammate = null;
        foreach (teammate in aliveMercs)
        {
            if (teammate == player)
                continue;
            local teammateClass = teammate.GetPlayerClass();
            local distance = (player.GetOrigin() - teammate.GetOrigin()).Length();
            if (distance < clDist
                && TraceLine(player.EyePosition(), teammate.EyePosition(), null) > 0.99
                && teammateClass != TF_CLASS_SPY && teammateClass != TF_CLASS_SNIPER)
            {
                clTeammate = teammate;
                clDist = distance;
            }
        }
        if (clTeammate != null)
            EmitPlayerToPlayerVO(clTeammate, player, clDist, soundLine);
    }
});