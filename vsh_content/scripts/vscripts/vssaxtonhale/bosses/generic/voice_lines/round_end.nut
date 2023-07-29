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

PrecacheClassVoiceLines("boss_win")
PrecacheClassVoiceLines("boss_win_4boss")
PrecacheClassVoiceLines("mercs_win_capture")
PrecacheClassVoiceLines("mercs_win_kill")
PrecacheClassVoiceLines("bailout")

::lostByRPS <- false;

AddListener("round_end", 0, function (winnerTeam)
{
    if (lostByRPS)
        return;
    local voiceLine = null;
    if (winnerTeam == TF_TEAM_BOSS)
        voiceLine = "boss_win";
    else if (winnerTeam == TF_TEAM_MERCS)
        voiceLine = IsAnyBossAlive() ? "mercs_win_capture" : "mercs_win_kill";
    else if (IsRoundSetup())
        voiceLine = "bailout";
    if (voiceLine != null)
        PlayAnnouncerVODelayed(GetRandomBossPlayer(), voiceLine, 1);
    if (winnerTeam == TF_TEAM_BOSS)
        foreach (boss in GetBossPlayers())
            RunWithDelay("PlayAnnouncerVOToPlayer(activator, activator, `boss_win_4boss`)", boss, 1);
});