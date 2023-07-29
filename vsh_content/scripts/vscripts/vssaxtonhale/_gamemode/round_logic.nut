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

isRoundOver <- false;
::isRoundSetup <- true;
hasTimerBeenShortened <- false;

AddListener("setup_start", 0, function ()
{
    Convars.SetValue("mp_bonusroundtime", GetPersistentVar("mp_bonusroundtime"));

    RecachePlayers();
    AssignBoss("saxton_hale", ProgressBossQueue());

    foreach (player in GetValidMercs())
    {
        player.SwitchTeam(TF_TEAM_MERCS);
        player.ForceRegenerateAndRespawn();
    }

    foreach (player in GetBossPlayers())
    {
        player.SwitchTeam(TF_TEAM_BOSS);
        player.ForceRegenerateAndRespawn();
        bosses[player].TryApply(player);
    }
});

AddListener("setup_end", 0, function()
{
    //Respawn all Mercs when Setup ends
    foreach (player in GetValidMercs())
        if (!IsPlayerAlive(player))
            player.ForceRespawn();

    local respawnRoom = null;
    local respawnsToKill = [];
    while (respawnRoom = Entities.FindByClassname(respawnRoom, "func_respawnroom"))
        respawnsToKill.push(respawnRoom);
    foreach (respawnRoom in respawnsToKill)
        respawnRoom.Kill();

    SetPropInt(tf_gamerules, "m_iRoundState", 7);
    SetPropInt(tf_gamerules, "m_nHudType", 2);

    Convars.SetValue("tf_rd_points_per_approach", "10");
});

AddListener("death", 2, function (attacker, victim, params)
{
    if (IsRoundSetup() && !IsAnyBossAlive())
    {
        Convars.SetValue("mp_bonusroundtime", 5);
        EndRound(TF_TEAM_UNASSIGNED);
    }
});

AddListener("tick_always", 8, function(timeDelta)
{
    if (IsInWaitingForPlayers())
        return;
    if (IsRoundSetup())
    {
        if (GetValidPlayerCount() <= 1 && !IsAnyBossAlive())
        {
            SetPropInt(team_round_timer, "m_bTimerPaused", 1);
            return;
        }
        //Bailout
        if (!IsAnyBossAlive())
        {
            Convars.SetValue("mp_bonusroundtime", 5);
            EndRound(TF_TEAM_UNASSIGNED);
        }
        return;
    }
    if (GetAliveMercCount() <= 5 && GetPropFloat(team_round_timer, "m_flTimeRemaining") > 60)
        EntFireByHandle(team_round_timer, "SetTime", "60", 0, null, null);

    local noBossesAlive = !IsAnyBossAlive();
    local noMercsAlive = GetAliveMercCount() <= 0;

    if (noBossesAlive && noMercsAlive)
        EndRound(TF_TEAM_UNASSIGNED);
    else if (noBossesAlive)
        EndRound(TF_TEAM_MERCS);
    else if (noMercsAlive)
        EndRound(TF_TEAM_BOSS);
});

function EndRound(winner)
{
    if (isRoundOver)
        return;
    if (!IsAnyBossAlive() && IsRoundSetup())
        winner = TF_TEAM_UNASSIGNED;

    local roundWin = Entities.FindByClassname(null, "game_round_win");
    if (roundWin == null)
    {
        roundWin = SpawnEntityFromTable("game_round_win",
        {
            win_reason = "0",
            force_map_reset = "1", //not having
            TeamNum = "0",         //these 3 lines
            switch_teams = "0"     //causes the crash when trying to fire game_round_win
        });
    }
    EntFireByHandle(roundWin, "SetTeam", "" + winner, 0, null, null);
    EntFireByHandle(roundWin, "RoundWin", "", 0, null, null);

    DoEntFire("vsh_round_end*", "Trigger", "", 0, null, null);
    if (winner == TF_TEAM_MERCS)
        DoEntFire("vsh_mercs_win*", "Trigger", "", 0, null, null);
    else
        DoEntFire("vsh_boss_win*", "Trigger", "", 0, null, null);
    FireListeners("round_end", winner);
    isRoundOver = true;
    SetPersistentVar("last_round_winner", winner)
}

function IsNotValidRound()
{
    return IsInWaitingForPlayers() || !IsAnyBossValid() || GetValidPlayerCount() < 2;
}

function IsValidRound()
{
    return !IsInWaitingForPlayers() && IsAnyBossValid() && GetValidPlayerCount() >= 2;
}

function IsValidRoundPreStart()
{
    return !IsInWaitingForPlayers() && GetValidPlayerCount() >= 2;
}

::IsRoundSetup <- function()
{
    return isRoundSetup;
}

function IsRoundOver()
{
    return isRoundOver;
}