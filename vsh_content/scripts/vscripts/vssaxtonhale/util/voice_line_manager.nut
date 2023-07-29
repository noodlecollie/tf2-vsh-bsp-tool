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

::BOSS_NAMES <- ["saxton_hale"]

class CustomVoiceLine extends CharacterTrait
{
    tickInverval = 0.1;
    playInterval = 0.1;
    lastTick = 0;
    lastPlay = 0;

    function constructor()
    {
        lastTick = Time();
        lastPlay = 0;
    }

    function DoTick(timeDelta)
    {
        local time = Time();
        while (time - lastTick >= tickInverval)
        {
            local timeDelta = time - lastTick;
            lastTick += tickInverval;
            if (time - lastPlay >= playInterval)
            {
                local wasPlayed = IsPlayerAlive(player) ? OnTickAlive(timeDelta) : false;
                local wasPlayed2 = OnTickAliveOrDead(timeDelta);
                if (wasPlayed || wasPlayed2)
                    lastPlay = time;
            }
        }
    }
}

class BossVoiceLine extends CustomVoiceLine
{
    boss = null;

    function CheckTeam()
    {
        boss = player;
        return IsValidBoss(player);
    }
}

::PrecacheClassVoiceLines <- function(name)
{
    foreach (className in TF_CLASS_NAMES)
        PrecacheScriptSound(className+"."+name);
    foreach (className in BOSS_NAMES)
        PrecacheScriptSound(className+"."+name);
}

::GetCurrentCharacterName <- function(player)
{
    local bossName = GetBossName(player);
    if (bossName != null)
        return bossName;
    local className = TF_CLASS_NAMES[player.GetPlayerClass()];
    if (className != null)
        return className;
    return "generic";
}

::MedicsAtStart <- function()
{
    local count = 0;
    foreach (player in GetValidPlayers())
        if (player.GetPlayerClass() == TF_CLASS_MEDIC)
            count++;
    return count;
}

function PlaySoundForAll(soundScript)
{
    foreach (player in GetValidClients())
        EmitSoundOnClient(soundScript, player);
    return true;
}

::PlayAnnouncerVO <- function(player, soundPath)
{
    if (player == null)
        return false;
    PlaySoundForAll(GetCurrentCharacterName(player)+"."+soundPath);
    return true;
}

::PlayAnnouncerVODelayed <- function(player, soundPath, delay)
{
    RunWithDelay("PlayAnnouncerVO(activator,`"+soundPath+"`)", player, delay);
    return true;
}

::PlayAnnouncerVOToPlayer <- function(player, emitter, soundPath)
{
    EmitSoundOnClient(GetCurrentCharacterName(emitter)+"."+soundPath, player);
    return true;
}

::EmitPlayerVO <- function(player, soundPath)
{
    if (player == null)
        return false;
    EmitSoundOn(GetCurrentCharacterName(player)+"."+soundPath, player);
    return true;
}

::EmitPlayerVODelayed <- function(player, soundPath, delay)
{
    RunWithDelay("if (IsValidPlayer(activator) && IsPlayerAlive(activator)) EmitPlayerVO(activator,`"+soundPath+"`)", player, delay);
    return true;
}

::EmitPlayerToPlayerVO <- function(source, target, distance, soundPath)
{
    if (source == null || target == null)
        return false;
    EmitSoundEx({
        sound_name = GetCurrentCharacterName(source)+"."+soundPath,
        filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_SINGLE_PLAYER
        volume = (GetAliveMercCount() > 10 ? 1 : 1.2 - clampFloor(300.0, distance) / 1500.0) / 1.8,
        flags =  1,
        entity = target,
        origin = source.GetCenter(),
        speaker_entity = source
    });
    return true;
}

::EmitEntityVO <- function(entity, soundBank, soundPath)
{
    EmitSoundOn(soundBank+"."+soundPath, entity);
    return true;
}
