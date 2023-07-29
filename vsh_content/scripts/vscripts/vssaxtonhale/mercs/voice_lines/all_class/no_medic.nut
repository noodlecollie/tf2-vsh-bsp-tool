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

PrecacheClassVoiceLines("medic_dead")
PrecacheClassVoiceLines("no_medic")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    nextTimeAvailable = 0;
    function OnFrameTickAlive()
    {
        if (player.GetTimeSinceCalledForMedic() > 0.1 || Time() < nextTimeAvailable || IsAnyMedicsAlive())
            return;
        nextTimeAvailable = Time() + 0.5;

        if (MedicsAtStart() > 0)
            return EmitPlayerVODelayed(player, "medic_dead", 0);
        else
            return EmitPlayerVODelayed(player, "no_medic", 0);
    }

    function IsAnyMedicsAlive()
    {
        foreach (player in GetAliveMercs())
            if (player.GetPlayerClass() == TF_CLASS_MEDIC)
                return true;
        return false;
    }
});