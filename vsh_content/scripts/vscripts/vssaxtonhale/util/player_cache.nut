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

::validClients <- [];
::validPlayers <- [];
::validMercs <- [];
::alivePlayers <- [];
::aliveMercs <- [];

::RecachePlayers <- function()
{
    local validClientsL = [];
    local validPlayersL = [];
    local alivePlayersL = [];
    local validMercsL = [];
    local aliveMercsL = [];
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (IsValidClient(player))
        {
            validClientsL.push(player);
            if (player.GetTeam() > TF_TEAM_SPECTATOR)
            {
                validPlayersL.push(player);

                local isAlive = IsPlayerAlive(player);
                local isMerc = !IsBoss(player);

                if (isAlive && isMerc)
                    aliveMercsL.push(player);
                if (isAlive)
                    alivePlayersL.push(player);
                if (isMerc)
                    validMercsL.push(player);
            }
        }
    }
    validClients = validClientsL;
    validPlayers = validPlayersL;
    validMercs = validMercsL;
    alivePlayers = alivePlayersL;
    aliveMercs = aliveMercsL;
};
AddListener("tick_frame", -9999, RecachePlayers);
AddListener("tick_always", -9999, function(tickDelta)
{
    RecachePlayers();
});
AddListener("disconnect", -9999, function(player, params)
{
    RecachePlayers();
});

::GetValidClients <- function()
{
    return validClients;
}

::GetValidPlayers <- function()
{
    return validPlayers;
}

::GetValidMercs <- function()
{
    return validMercs;
}

::GetValidPlayerCount <- function()
{
    return validPlayers.len();
}

::GetAlivePlayers <- function()
{
    return alivePlayers;
}

::GetAliveMercs <- function()
{
    return aliveMercs;
}

::GetAliveMercCount <- function()
{
    return aliveMercs.len();
}

::IsMercValidAndAlive <- function(player)
{
    return IsValidPlayer(player) && !IsValidBoss(player) && IsPlayerAlive(player);
}