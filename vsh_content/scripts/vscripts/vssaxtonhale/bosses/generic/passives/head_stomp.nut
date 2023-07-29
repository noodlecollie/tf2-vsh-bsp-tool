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

class HeadStompTrait extends BossTrait
{
    canStomp = false;

    function OnFrameTickAlive()
    {
        if (!boss.IsOnGround())
            canStomp = boss.GetAbsVelocity().z < -500;
        else
        {
            if (canStomp)
            {
                canStomp = false;
                local victim = GetPropEntity(boss, "m_hGroundEntity");
                if (!IsValidPlayer(victim))
                    return;

                //We change weapon to Mantreads to change the icon
                local weapon = boss.GetActiveWeapon();
                SetItemId(weapon, 444); //Mantreads
                victim.TakeDamageEx(boss,
                    boss,
                    weapon,
                    Vector(0,0,0),
                    boss.GetOrigin(),
                    195,
                    1);
                SetItemId(weapon, 5);

                EmitAmbientSoundOn("Weapon_Mantreads.Impact", 8, 1, 100, victim);
                EmitAmbientSoundOn("Player.FallDamageDealt", 4, 1, 100, victim);
                DispatchParticleEffect("stomp_text", boss.GetOrigin(), Vector(0,0,0));
            }
            canStomp = false;
        }
    }
};