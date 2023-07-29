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

characterTraitsClasses.push(class extends CharacterTrait
{
    lastTimeApplied = 0;
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT;
    }

    function OnDamageDealt(victim, params)
    {
        if (Time() - lastTimeApplied < 0.1 || !IsBoss(victim)
            || (!WeaponIs(params.weapon, "force_a_nature") && !WeaponIs(params.weapon, "force_a_nature_xmas")))
            return;
        local deltaVector = victim.GetOrigin() - player.GetOrigin();
        deltaVector.z = 100;
        local distance = deltaVector.Norm();
        if (distance < 600)
            victim.Yeet(deltaVector * (300 - distance / 2));
    }
});