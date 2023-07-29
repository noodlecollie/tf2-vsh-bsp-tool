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

//Hale is technically a Heavy with Voice Pitch shifted to 0.
//Pyrovision overrides that shift enabling Heavy's lines.
characterTraitsClasses.push(class extends CharacterTrait
{
    function OnApply()
    {
        local wearable = null;
        while (wearable = Entities.FindByClassname(wearable, "tf_we*"))
            if (wearable.GetOwner() == player)
                wearable.AddAttribute("vision opt in flags", 0, -1);
    }
});