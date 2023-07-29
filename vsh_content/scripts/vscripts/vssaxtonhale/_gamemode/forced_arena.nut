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

AddListener("spawn", 0, function (player, params)
{
    if (IsRoundSetup())
        return;

    player.TakeDamage(9999, 0, null);
    SetPropInt(player, "m_lifeState", LIFE_STATE.DEAD);
    if (player.GetTeam() != TF_TEAM_MERCS)
        player.ForceChangeTeam(TF_TEAM_MERCS, true);

    local ammoPack = null;
    while (ammoPack = Entities.FindByClassname(ammoPack, "tf_ammo_pack"))
        if (ammoPack.GetOwner() == player)
        {
            ammoPack.Kill();
            return;
        }
});

AddListener("class_change", 0, function (player, params)
{
    local currentClass = GetPropInt(player, "m_PlayerClass.m_iClass");
    local desiredClass = params["class"];

    if (IsRoundSetup() && IsValidPlayer(player) && !IsValidBoss(player))
    {
        player.SetPlayerClass(desiredClass);
        player.ForceRegenerateAndRespawn();

        local building = null;
        local buildingToKill = [];
        while (building = Entities.FindByClassname(building, "obj_*"))
            if (GetPropEntity(building, "m_hBuilder") == player)
                buildingToKill.push(building);
        foreach (building in buildingToKill)
            building.Kill();
    }
    else
    {
        SetPropInt(player, "m_PlayerClass.m_iClass", desiredClass);
        RunWithDelay("SetPropInt(activator, `m_PlayerClass.m_iClass`, "+currentClass+")", player, 0);
    }
});

AddListener("team_change", 0, function (player, params)
{
    if (IsBoss(player) && params.team != TF_TEAM_BOSS)
        RunWithDelay("SwitchPlayerTeam(activator, TF_TEAM_BOSS)", player, 0);
    if (!IsBoss(player) && params.team == TF_TEAM_BOSS)
        RunWithDelay("SwitchPlayerTeam(activator, TF_TEAM_MERCS)", player, 0);
    if (!IsBoss(player) && params.team == TF_TEAM_SPECTATOR && params.silent)
    {
        local name = GetPropString(player, "m_szNetname");
        Say(null, "Player '"+name+"' was moved to spectators for some reason. Moving them back.", false);
        RunWithDelay("SwitchPlayerTeam(activator, TF_TEAM_MERCS)", player, 0);
    }
});

AddListener("tick_frame", 0, function()
{
    local pdFlag = Entities.FindByClassname(null, "item_teamflag");
    if (pdFlag != null)
        pdFlag.Kill();
});