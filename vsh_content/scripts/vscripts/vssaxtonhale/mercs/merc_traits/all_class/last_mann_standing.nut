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
    function OnTickAlive(timeDelta)
    {
        local mercsAlive = GetAliveMercCount();
        if (mercsAlive <= 3)
            player.AddCondEx(TF_COND_OFFENSEBUFF, 0.2, player);
        if (mercsAlive == 1)    //No, it's not "else if", because engie + sentry combo benefits from both crits and minicrits
            player.AddCondEx(TF_COND_CRITBOOSTED_ON_KILL, 0.2, player);
    }
});