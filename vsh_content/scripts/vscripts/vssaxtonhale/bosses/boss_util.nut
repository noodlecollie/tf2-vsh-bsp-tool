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

::IsCollateralDamage <- function(damage_type)
{
    return damage_type == 1 || damage_type == 2 || damage_type == DMG_BLAST;
}

function AssignBoss(bossClass, bossPlayer)
{
    bosses[bossPlayer] <- bossLibrary[bossClass]();
}

function RegisterBoss(name, bossClass)
{
    bossLibrary[name] <- bossClass;
}

::GetBossName <- function(player)
{
    if (player in bosses)
        return bosses[player].name;
    return null;
}

::IsAnyBossValid <- function()
{
    foreach (player, boss in bosses)
        if (IsValidPlayer(player))
            return true;
    return false;
}

::IsAnyBossAlive <- function()
{
    foreach (player, boss in bosses)
        if (IsValidPlayer(player) && IsPlayerAlive(player))
            return true;
    return false;
}

::IsValidBoss <- function(player)
{
    return IsBoss(player) && IsValidPlayer(player);
}

::IsBoss <- function(player)
{
    return player in bosses;
}

::GetBossPlayers <- function()
{
    local players = []
    foreach (player, boss in bosses)
        if (IsValidPlayer(player))
            players.push(player);
    return players;
}

::GetAliveBossPlayers <- function()
{
    local players = []
    foreach (player, boss in bosses)
        if (IsValidPlayer(player) && IsPlayerAlive(player))
            players.push(player);
    return players;
}

::GetRandomBossPlayer <- function()
{
    local players = GetBossPlayers();
    return players.len() > 0 ? players[RandomInt(0, players.len() - 1)] : null;
}

::BossPlayViewModelAnim <- function(boss, animation)
{
    local main_viewmodel = GetPropEntity(boss, "m_hViewModel")
    local sequenceId = main_viewmodel.LookupSequence(animation);
    if (main_viewmodel.GetSequence() != sequenceId)
        main_viewmodel.SetSequence(sequenceId)
}