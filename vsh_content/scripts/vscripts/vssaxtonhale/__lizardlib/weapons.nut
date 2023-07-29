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

//Why does this table exist? Because the same weapon can have multiple IDs, namely, pre-JI weapon skins.
::weaponModels <- {
    market_gardener = GetModelIndex("models/workshop/weapons/c_models/c_market_gardener/c_market_gardener.mdl"),
    holiday_punch = GetModelIndex("models/workshop/weapons/c_models/c_xms_gloves/c_xms_gloves.mdl"),
    eyelander = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore.mdl"),
    eyelander_xmas = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore_xmas.mdl"),
    headtaker = GetModelIndex("models/weapons/c_models/c_headtaker/c_headtaker.mdl"),
    golf_club = GetModelIndex("models/workshop/weapons/c_models/c_golfclub/c_golfclub.mdl"),
    claymore_xmas = GetModelIndex("models/weapons/c_models/c_claymore/c_claymore_xmas.mdl"),
    natasha = GetModelIndex("models/weapons/c_models/c_minigun/c_minigun_natascha.mdl"),
    kunai = GetModelIndex("models/workshop_partner/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl"),
    big_earner = GetModelIndex("models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl"),
    your_eternal_reward = GetModelIndex("models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl"),
    wanga_prick = GetModelIndex("models/workshop/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl"),
    vaccinator = GetModelIndex("models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defense.mdl"),
    warriors_spirit = GetModelIndex("models/workshop/weapons/c_models/c_bear_claw/c_bear_claw.mdl"),
    direct_hit = GetModelIndex("models/weapons/c_models/c_directhit/c_directhit.mdl"),
    reserve_shooter = GetModelIndex("models/workshop/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl"),
    candy_cane = GetModelIndex("models/workshop/weapons/c_models/c_candy_cane/c_candy_cane.mdl"),
    fan_o_war = GetModelIndex("models/workshop_partner/weapons/c_models/c_shogun_warfan/c_shogun_warfan.mdl"),
    rocket_jumper = GetModelIndex("models/weapons/c_models/c_rocketjumper/c_rocketjumper.mdl"),
    dead_ringer = GetModelIndex("models/weapons/v_models/v_watch_pocket_spy.mdl"),
    ubersaw = GetModelIndex("models/weapons/c_models/c_ubersaw/c_ubersaw.mdl"),
    ubersaw_xmas = GetModelIndex("models/weapons/c_models/c_ubersaw/c_ubersaw_xmas.mdl"),
    quick_fix = GetModelIndex("models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl"),
    scottish_resistance = GetModelIndex("models/weapons/c_models/c_scottish_resistance/c_scottish_resistance.mdl"),
    force_a_nature = GetModelIndex("models/weapons/c_models/c_double_barrel.mdl"),
    force_a_nature_xmas = GetModelIndex("models/weapons/c_models/c_xms_double_barrel.mdl"),
    sticky_jumper = GetModelIndex("models/weapons/c_models/c_sticky_jumper/c_sticky_jumper.mdl"),
    disciplinary_action = GetModelIndex("models/workshop/weapons/c_models/c_riding_crop/c_riding_crop.mdl"),
    eviction_notice = GetModelIndex("models/workshop/weapons/c_models/c_eviction_notice/c_eviction_notice.mdl"),
    diamondback = GetModelIndex("models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl"),
}

::SetItemId <- function(item, id)
{
    if (item != null)
        SetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", id);
}

::ClearPlayerWearables <- function(player)
{
    local item = null;
    local itemsToKill = [];
    while (item = Entities.FindByClassname(item, "tf_we*"))
    {
        if (item.GetOwner() == player)
            itemsToKill.push(item);
    }
    item = null;
    while (item = Entities.FindByClassname(item, "tf_powerup_bottle"))
    {
        if (item.GetOwner() == player)
            itemsToKill.push(item);
    }
    foreach (item in itemsToKill)
        item.Kill();
}

::WeaponIs <- function(weapon, name)
{
    if (weapon == null)
        return false;
    if (name == "kgb")
        return GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 43;
    else if (name == "mad_milk")
        return weapon.GetClassname() == "tf_weapon_jar_milk";
    else if (name == "airstrike")
        return weapon.GetClassname() == "tf_weapon_rocketlauncher_airstrike";
    else if (name == "half_zatoichi")
        return weapon.GetClassname() == "tf_weapon_katana";
    else if (name == "any_stickybomb_launcher")
        return weapon.GetClassname() == "tf_weapon_pipebomblauncher";
    else if (name == "any_sword")
        return weapon.GetClassname() == "tf_weapon_sword" || weapon.GetClassname() == "tf_weapon_katana";
    return (name in weaponModels ? weaponModels[name] : null) == GetPropInt(weapon, "m_iWorldModelIndex");
}