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

::SetNextBossByEntity <- function(playerEnt)
{
    SetPersistentVar("next_boss", playerEnt.entindex());
}

::SetNextBossByEntityIndex <- function(playerEntIndex)
{
    SetPersistentVar("next_boss", playerEntIndex);
}

::SetNextBossByUserId <- function(userId)
{
    local playerEnt = GetPlayerFromUserID(userId);
    SetPersistentVar("next_boss", playerEnt.entindex());
}

function ProgressBossQueue(iterations = 0)
{
    try
    {
        local nextBossIndex = GetPersistentVar("next_boss", null);
        if (nextBossIndex != null)
        {
            SetPersistentVar("next_boss", null);
            local nextBossPlayer = PlayerInstanceFromIndex(nextBossIndex);
            if (IsValidPlayer(nextBossPlayer))
                return nextBossPlayer;
        }

        local playedAsBossAlready = GetPersistentVar("played_as_boss");
        if (playedAsBossAlready == null)
            SetPersistentVar("played_as_boss", playedAsBossAlready = []);

        local candidates = GetValidPlayers().slice();
        if (iterations < 3 && RandomInt(1, 10) != 1) //We leave a small chance for a completely random selection
        {
            foreach (played in playedAsBossAlready)
            {
                local index = candidates.find(played);
                if (index != null)
                    candidates.remove(index);
            }
            if (candidates.len() == 0)
            {
                for (local i = 0; i < clampCeiling(6, playedAsBossAlready.len()); i++)
                    playedAsBossAlready.remove(0);
                return ProgressBossQueue(iterations + 1);
            }
        }
        local newBossPlayer = candidates[RandomInt(0, candidates.len() - 1)];
        playedAsBossAlready.push(newBossPlayer);
        return newBossPlayer;
    }
    catch(e)
    {
        try
        {
            return GetValidPlayers()[RandomInt(0, GetValidPlayers().len() - 1)];
        }
        catch(e1)
        {
            return GetValidClients()[RandomInt(0, GetValidClients().len() - 1)];
        }
    }
}