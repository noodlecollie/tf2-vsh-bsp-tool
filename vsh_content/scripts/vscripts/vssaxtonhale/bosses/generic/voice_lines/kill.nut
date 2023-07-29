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

PrecacheClassVoiceLines("kill_scout")
PrecacheClassVoiceLines("kill_soldier")
PrecacheClassVoiceLines("kill_pyro")
PrecacheClassVoiceLines("kill_demoman")
PrecacheClassVoiceLines("kill_heavy")
PrecacheClassVoiceLines("kill_engineer")
PrecacheClassVoiceLines("kill_medic")
PrecacheClassVoiceLines("kill_sniper")
PrecacheClassVoiceLines("kill_spy")
PrecacheClassVoiceLines("kill_spy_dr")
PrecacheClassVoiceLines("kill_building")
PrecacheClassVoiceLines("kill_dispenser")
PrecacheClassVoiceLines("kill_generic")
PrecacheClassVoiceLines("kill_medic_last")
PrecacheClassVoiceLines("kill_medic_only")
PrecacheClassVoiceLines("kill_medic_vacc")

::bossKillLinesEnabled <- [];
::bossKillLinesLastPlayed <- 0;

class KillVoiceLine extends BossVoiceLine
{
    function OnApply()
    {
        bossKillLinesEnabled.push(boss);
    }
};

AddListener("death", 10, function (attacker, victim, params)
{
    if (params.crit_type > 0
        || Time() - bossKillLinesLastPlayed < (GetAliveMercCount() > 20 ? 8 : 5)
        || GetAliveMercCount() == 1
        || IsBoss(victim)
        || bossKillLinesEnabled.find(attacker) == null
        || !IsPlayerAlive(attacker))
        return;

    local voiceLine = null;
    if (victim.GetPlayerClass() == TF_CLASS_MEDIC && WeaponIs(victim.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY), "vaccinator"))
        voiceLine = "kill_medic_vacc";
    else if (victim.GetPlayerClass() == TF_CLASS_SPY && RandomInt(1, 3) == 1 && WeaponIs(victim.GetWeaponBySlot(TF_WEAPONSLOTS.INVIS_WATCH), "dead_ringer"))
        voiceLine = "kill_spy_dr";
    else if (victim.GetPlayerClass() == TF_CLASS_MEDIC && IsOnlyOneMedicAlive())
        voiceLine = MedicsAtStart() > 1 ? "kill_medic_last" : "kill_medic_only";
    else if (!IsCollateralDamage(params.damagebits) && RandomInt(1, 3) == 1)
        voiceLine = RandomInt(0,1) == 0 ? "kill_generic" : "kill_"+GetCurrentCharacterName(victim);

    if (voiceLine != null)
    {
        bossKillLinesLastPlayed = Time();
        PlayAnnouncerVO(attacker, voiceLine);
    }
});

AddListener("builing_destroyed", 0, function (attacker, params)
{
    if (RandomInt(1, 4) == 1 && bossKillLinesEnabled.find(attacker) != null && Time() - bossKillLinesLastPlayed > 5)
    {
        bossKillLinesLastPlayed = Time();
        if (params.objecttype != 0 || RandomInt(1, 5) != 1)
            PlayAnnouncerVO(attacker, "kill_building");
        else
            PlayAnnouncerVO(attacker, "kill_dispenser");
    }
});

function IsOnlyOneMedicAlive()
{
    local aliveMedics = 0;
    foreach (player in GetAliveMercs())
        if (player.GetPlayerClass() == TF_CLASS_MEDIC)
            if (++aliveMedics > 1)
                return false;
    return aliveMedics == 1;
}