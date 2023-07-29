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

::bossLibrary <- {};
::traitLibrary <- {};
::bosses <- {};

class BossTrait extends CharacterTrait
{
    boss = null;
    function CheckTeam()
    {
        boss = player;
        return true;
    }
}

class Boss extends CharacterTrait
{
    traits = null;
    name = null;
    startingHealth = 0;

    function CheckTeam() { return true; }

    function OnApply()
    {
        player.ForceRespawn();
        RunWithDelay2(this, 0, OnApply0Delay);
    }

    function OnApply0Delay()
    {
        foreach (traitClass in traitLibrary[name])
            traitClass().TryApply(player);
        bosses[player] <- this;

        ClearPlayerWearables(player);
    }
}
function AddBossTrait(bossName, traitClass)
{
    if (!(bossName in traitLibrary))
        traitLibrary[bossName] <- [];
    traitLibrary[bossName].push(traitClass);
}

Include("/bosses/boss_util.nut");

Include("/bosses/generic/abilities/brave_jump.nut");
Include("/bosses/generic/passives/stun_breakout.nut");
Include("/bosses/generic/passives/debuff_resistance.nut");
Include("/bosses/generic/passives/aoe_punch.nut");
Include("/bosses/generic/passives/received_damage_scaling.nut");
Include("/bosses/generic/passives/head_stomp.nut");
Include("/bosses/generic/misc/ability_hud.nut");
Include("/bosses/generic/misc/death_cleanup.nut");
Include("/bosses/generic/misc/movespeed.nut");
Include("/bosses/generic/misc/screen_shake.nut");
Include("/bosses/generic/misc/setup_stat_refresh.nut");
Include("/bosses/generic/misc/taunt_handler.nut");
Include("/bosses/generic/misc/building_damage_rescale.nut");
Include("/bosses/generic/misc/spawn_protection.nut");
Include("/bosses/generic/misc/no_gib_fix.nut");
Include("/bosses/generic/voice_lines/jarated.nut");
Include("/bosses/generic/voice_lines/kill.nut");
Include("/bosses/generic/voice_lines/round_start.nut");
Include("/bosses/generic/voice_lines/last_mann_hiding.nut");
Include("/bosses/generic/voice_lines/round_end.nut");

Include("/bosses/saxton_hale/saxton_hale.nut");
