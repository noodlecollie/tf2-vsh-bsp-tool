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

hale_aura_red_off <- "models/player/items/vsh_effect_ltarm_aura.mdl"
hale_aura_blue_off <- "models/player/items/vsh_effect_rtarm_aura.mdl"
hale_aura_red_on <- "models/player/items/vsh_effect_ltarm_aura_megapunch.mdl"
hale_aura_blue_on <- "models/player/items/vsh_effect_rtarm_aura_chargedash.mdl"

PrecacheModel(hale_aura_red_off);
PrecacheModel(hale_aura_blue_off);
PrecacheModel(hale_aura_red_on);
PrecacheModel(hale_aura_blue_on);

haleRedArmEnabled <- false;
haleBlueArmEnabled <- false;

function Hale_SetRedArm(boss, newStatus)
{
    local wearable = Entities.FindByName(null, "wearable_vs_hale_aura_red");
    if (wearable != null)
        wearable.Kill();
    if (newStatus)
        wearable = boss.CreateCustomWearable(null, hale_aura_red_on);
    else
        wearable = boss.CreateCustomWearable(null, hale_aura_red_off);
    wearable.KeyValueFromString("targetname", "wearable_vs_hale_aura_red");

    haleRedArmEnabled = newStatus;
    Hale_ColorThirdPersonArms(boss);

    local viewmodel = null;
    while (viewmodel = Entities.FindByClassname(viewmodel, "tf_wearable_vm"))
        if (viewmodel.GetOwner() == boss)
            viewmodel.SetBodygroup(1, newStatus ? 1 : 0);
    GetPropEntity(boss, "m_hViewModel").SetBodygroup(1, newStatus ? 1 : 0);
}

function Hale_SetBlueArm(boss, newStatus)
{
    local wearable = Entities.FindByName(null, "wearable_vs_hale_aura_blue");
    if (wearable != null)
        wearable.Kill();
    if (newStatus)
        wearable = boss.CreateCustomWearable(null, hale_aura_blue_on);
    else
        wearable = boss.CreateCustomWearable(null, hale_aura_blue_off);
    wearable.KeyValueFromString("targetname", "wearable_vs_hale_aura_blue");

    haleBlueArmEnabled = newStatus;
    Hale_ColorThirdPersonArms(boss);

    local viewmodel = null;
    while (viewmodel = Entities.FindByClassname(viewmodel, "tf_wearable_vm"))
        if (viewmodel.GetOwner() == boss)
            viewmodel.SetBodygroup(0, newStatus ? 1 : 0);
    if (newStatus)
        GetPropEntity(boss, "m_hViewModel").DisableDraw();
    else
        GetPropEntity(boss, "m_hViewModel").EnableDraw();
}

function Hale_ColorThirdPersonArms(boss)
{
    local newSkin = 0;
    if (haleRedArmEnabled)
        newSkin = haleBlueArmEnabled ? 4 : 2
    else
        newSkin = haleBlueArmEnabled ? 3 : 0;
    SetPropInt(boss, "m_nForcedSkin", newSkin);
}