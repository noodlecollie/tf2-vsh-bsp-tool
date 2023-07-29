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

::IsPlayerAlive <- function(player)
{
    return GetPropInt(player, "m_lifeState") == LIFE_STATE.ALIVE;
}

::IsPlayerDead <- function(player)
{
    return GetPropInt(player, "m_lifeState") != LIFE_STATE.ALIVE;
}

::CTFPlayer.IsOnGround <- function()
{
    return this.GetFlags() & FL_ONGROUND;
}

::CTFBot.IsOnGround <- CTFPlayer.IsOnGround;

::IsValidClient <- function(player)
{
    try
    {
        return player != null && player.IsValid() && player.IsPlayer();
    }
    catch(e)
    {
        return false;
    }
}

::IsValidPlayer <- function(player)
{
    try
    {
        return player != null && player.IsValid() && player.IsPlayer() && player.GetTeam() > 1;
    }
    catch(e)
    {
        return false;
    }
}

::IsValidPlayerOrBuilding <- function(entity)
{
    try
    {
        return entity != null
            && entity.IsValid()
            && entity.GetTeam() > 1
            && (entity.IsPlayer() || entity.GetClassname().find("obj_") == 0);
    }
    catch(e)
    {
        return false;
    }
}

::IsValidBuilding <- function(building)
{
    try
    {
        return building != null
            && building.IsValid()
            && building.GetClassname().find("obj_") == 0
            && building.GetTeam() > 1;
    }
    catch(e)
    {
        return false;
    }
}

::GetPlayerFromParams <- function(params, key = "userid")
{
    if (!(key in params))
        return null;
    local player = GetPlayerFromUserID(params[key]);
    if (IsValidPlayer(player))
        return player;
    return null;
}

::PlaySoundForAll <- function(soundScript)
{
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (IsValidPlayer(player))
            EmitSoundOnClient(soundScript, player);
    }
}

::CTFPlayer.Yeet <- function(vector)
{
    SetPropEntity(this, "m_hGroundEntity", null);
    this.ApplyAbsVelocityImpulse(vector);
    this.RemoveFlag(FL_ONGROUND);
}

::CTFBot.Yeet <- CTFPlayer.Yeet;

::CTFBot.SwitchTeam <- function(team)
{
    this.ForceChangeTeam(team, true);
    SetPropInt(this, "m_iTeamNum", team);
}

::CTFPlayer.SwitchTeam <- function(team)
{
    SetPropInt(this, "m_bIsCoaching", 1);
    this.ForceChangeTeam(team, true);
    SetPropInt(this, "m_bIsCoaching", 0);
}

::SwitchPlayerTeam <- function(player, team)
{
    if (IsValidPlayer(player))
    {
        player.SwitchTeam(team);
        if (!IsBoss(player) && IsRoundSetup())
        {
            player.ForceRegenerateAndRespawn();
            local ammoPack = null;
            while (ammoPack = Entities.FindByClassname(ammoPack, "tf_ammo_pack"))
                if (ammoPack.GetOwner() == player)
                {
                    ammoPack.Kill();
                    return;
                }
        }
    }
}