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

PrecacheClassVoiceLines("count1")
PrecacheClassVoiceLines("count2")
PrecacheClassVoiceLines("count3")
PrecacheClassVoiceLines("count4")
PrecacheClassVoiceLines("count5")

PrecacheClassVoiceLines("round_start")
PrecacheClassVoiceLines("round_start_4boss")
PrecacheClassVoiceLines("round_start_long")
PrecacheClassVoiceLines("round_start_beer")
PrecacheClassVoiceLines("round_start_after_loss")

AddListener("setup_start", 0, function ()
{
    if (API_GetBool("setup_lines"))
        RunWithDelay("PlayRoundStartVO()", null, 2);
});

function PlayRoundStartVO()
{
    if (IsRoundOver())
        return;
    local boss = GetRandomBossPlayer();
    if (boss == null)
        return;
    if (API_GetBool("long_setup_lines") && RandomInt(1, 10) <= 4)
        PlayAnnouncerVO(boss, "round_start_long");
    else
    {
        if (API_GetBool("beer_lines") && RandomInt(1, 10) <= 4)
            PlayAnnouncerVO(boss, "round_start_beer")
        else if (RandomInt(1, 5) == 1 && GetPersistentVar("last_round_winner") == TF_TEAM_BOSS)
            PlayAnnouncerVO(boss, "round_start_after_loss")
        else
            PlayAnnouncerVO(boss, "round_start")

        if (!API_GetBool("setup_countdown_lines"))
            return;
        local countdownDelay = API_GetFloat("setup_length") - 8;
        PlayAnnouncerVODelayed(boss, "count5", countdownDelay++);
        PlayAnnouncerVODelayed(boss, "count4", countdownDelay++);
        PlayAnnouncerVODelayed(boss, "count3", countdownDelay++);
        PlayAnnouncerVODelayed(boss, "count2", countdownDelay++);
        PlayAnnouncerVODelayed(boss, "count1", countdownDelay);
    }
    PlayAnnouncerVOToPlayer(boss, boss, "round_start_4boss");
}