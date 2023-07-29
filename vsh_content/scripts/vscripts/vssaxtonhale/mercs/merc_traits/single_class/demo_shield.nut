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

PrecacheScriptSound("vsh_sfx.shield_break");
PrecacheScriptSound("demo.shield")
PrecacheScriptSound("demo.shield_lowhp")

characterTraitsClasses.push(class extends CharacterTrait
{
    wasDestroyed = false;
    function CanApply()
    {
        if (player.GetPlayerClass() != TF_CLASS_DEMOMAN)
            return false;
        local wearable = null;
        while (wearable = Entities.FindByClassname(wearable, "tf_wearable_demo*"))
            if (wearable.GetOwner() == player)
                return true;
        return false;
    }

    function OnDamageTaken(attacker, params)
    {
        if (wasDestroyed || !IsValidBoss(attacker) || player.InCond(TF_COND_INVULNERABLE))
            return;

        if ((params.damage_type == 1 || params.damage_type == DMG_BLAST) && params.damage < player.GetHealth())
            return;

        wasDestroyed = true;
        params.damage = 0;

        local wearable = null;
        while (wearable = Entities.FindByClassname(wearable, "tf_wearable_demo*"))
            if (wearable.GetOwner() == player)
            {
                wearable.Kill();
                break;
            }

        local deltaVector = player.GetCenter() - attacker.GetCenter();
        deltaVector.z = 0;
        deltaVector.Norm();
        player.Yeet(deltaVector * 900 + Vector(0, 0, 300));

        EmitSoundOn("vsh_sfx.shield_break", player);

        if (params.damage_type == DMG_BLAST)
            EmitPlayerVODelayed(player, "shield_lowhp", 1);
        else
            EmitPlayerVODelayed(player, "shield", 1);
    }
});