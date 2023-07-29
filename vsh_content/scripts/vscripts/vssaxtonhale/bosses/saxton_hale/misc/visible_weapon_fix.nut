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

::empty_model_index <- GetModelIndex("models/empty.mdl")

AddListener("tick_always", 0, function (timeDelta)
{
    foreach (boss in GetBossPlayers())
    {
        local weapon = boss.GetActiveWeapon();
        if (weapon != null && weapon.IsValid())
        {
            SetPropInt(weapon, "m_iWorldModelIndex", empty_model_index);
            weapon.DisableDraw();
            SetPropInt(weapon, "m_nRenderMode", 1);
            weapon.SetModelScale(0.05, 0)
        }
    }
});