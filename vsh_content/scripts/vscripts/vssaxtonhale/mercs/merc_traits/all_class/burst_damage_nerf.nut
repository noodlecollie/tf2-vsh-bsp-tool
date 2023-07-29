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
    damageDoneRecently = 0;

    function OnTickAlive(tickDelta)
    {
        damageDoneRecently = clampFloor(0, damageDoneRecently / 2.0);
    }

    function OnDamageDealt(victim, params)
    {
        if (IsBoss(victim) && damageDoneRecently > 300)
        {
            local scaled = clampFloor(0.3, 1 - 0.0015 * (damageDoneRecently - 300));
            local pre = params.damage
            params.damage *= scaled;
        }
    }

    function OnHurtDealtEvent(victim, params)
    {
        if (IsBoss(victim))
            damageDoneRecently += params.damageamount;
    }
});