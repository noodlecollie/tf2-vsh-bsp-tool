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

::saxton_model_path <- "models/player/saxton_hale.mdl";
::saxton_aura_model_path <- "models/player/items/vsh_effect_body_aura.mdl"
::saxton_viewmodel_path <- "models/weapons/c_models/c_saxton_arms.mdl"
::saxton_viewmodel_index <- GetModelIndex("models/weapons/c_models/c_saxton_arms.mdl")

PrecacheModel(saxton_model_path);
PrecacheModel(saxton_aura_model_path);
PrecacheModel(saxton_viewmodel_path);

class SaxtonHale extends Boss
{
    name = "saxton_hale";

    function OnApply0Delay()
    {
        player.SetPlayerClass(TF_CLASS_HEAVY);
        player.Regenerate(true);
        SetPropInt(player, "m_bForcedSkin", 1);
        SetPropInt(player, "m_nForcedSkin", 0);

        base.OnApply0Delay();

        player.SetCustomModelWithClassAnimations(saxton_model_path);
        vsh_vscript.Hale_SetRedArm(player, false);
        vsh_vscript.Hale_SetBlueArm(player, false);
        RunWithDelay2(this, 0.1, function() {
            vsh_vscript.Hale_SetRedArm(player, false);
            vsh_vscript.Hale_SetBlueArm(player, false);
            player.CreateCustomWearable(null, saxton_aura_model_path);
            player.GiveWeapon("Hale's Own Fists");
        });

        player.SetModelScale(API_GetFloat("boss_scale"), 0);
        player.GiveWeapon("Hale's Own Fists");

        player.AddCustomAttribute("move speed bonus", 1.8, -1);
        player.AddCustomAttribute("cancel falling damage", 1, -1);
        player.AddCustomAttribute("voice pitch scale", 0, -1);
        player.AddCustomAttribute("melee range multiplier", 1.2, -1);
        player.AddCustomAttribute("damage bonus", 3, -1);
        player.AddCustomAttribute("melee bounds multiplier", 1.1, -1);
        player.AddCustomAttribute("crit mod disabled hidden", 0, -1);
        player.AddCustomAttribute("increase player capture value", 2, -1);
        player.AddCustomAttribute("cannot pick up intelligence", 1, -1);
        player.AddCustomAttribute("patient overheal penalty", 1, -1);
        player.AddCustomAttribute("health from packs decreased", 0, -1);
        player.AddCustomAttribute("damage force reduction", 0.75, -1);
        player.AddCustomAttribute("dmg taken from crit reduced", 0.75, -1);

        player.AddCond(TF_COND_CANNOT_SWITCH_FROM_MELEE);
    }
}
RegisterBoss("saxton_hale", SaxtonHale);

Include("/bosses/saxton_hale/abilities/sweeping_charge.nut");
Include("/bosses/saxton_hale/abilities/mighty_slam.nut");
Include("/bosses/saxton_hale/abilities/saxton_punch.nut");
Include("/bosses/saxton_hale/misc/colored_arms.nut");
Include("/bosses/saxton_hale/misc/visible_weapon_fix.nut");

AddBossTrait("saxton_hale", AbilityHudTrait);
AddBossTrait("saxton_hale", SweepingChargeTrait);
AddBossTrait("saxton_hale", SaxtonPunchTrait);
AddBossTrait("saxton_hale", MightySlamTrait);

AddBossTrait("saxton_hale", BraveJumpTrait);
AddBossTrait("saxton_hale", DeathCleanupTrait);
AddBossTrait("saxton_hale", MovespeedTrait);
AddBossTrait("saxton_hale", ScreenShakeTrait);
AddBossTrait("saxton_hale", SetupStatRefreshTrait);
AddBossTrait("saxton_hale", TauntHandlerTrait);
AddBossTrait("saxton_hale", AoEPunchTrait);
AddBossTrait("saxton_hale", DebuffResistanceTrait);
AddBossTrait("saxton_hale", HeadStompTrait);
AddBossTrait("saxton_hale", ReceivedDamageScalingTrait);
AddBossTrait("saxton_hale", StunBreakoutTrait);
AddBossTrait("saxton_hale", BuildingDamageRescaleTrait);
AddBossTrait("saxton_hale", SpawnProtectionTrait);
AddBossTrait("saxton_hale", NoGibFixTrait);

AddBossTrait("saxton_hale", JaratedVoiceLine);
AddBossTrait("saxton_hale", LastMannHidingVoiceLine);
AddBossTrait("saxton_hale", KillVoiceLine);

RegisterCustomWeapon(
    "Hale's Own Fists",
    "Fists",
    null,
    Defaults,
    function (table, player) {
        table.worldModel = "models/empty.mdl";
        table.viewModel = saxton_viewmodel_path;
        table.classArms = saxton_viewmodel_path;
    },
    function (weapon, player)
    {
        if (player.ValidateScriptScope())
            player.GetScriptScope()["hide_base_arms"] <- true;

        weapon.AddAttribute("kill eater", casti2f(9001), -1);

        local isModelFlipped = false;
        try { isModelFlipped = Convars.GetClientConvarValue("cl_flipviewmodels", player.entindex()).tointeger() > 0; }
        catch(ignored) { }
        SetPropInt(weapon, "m_bFlipViewModel", isModelFlipped ? 1 : 0);
    }
);