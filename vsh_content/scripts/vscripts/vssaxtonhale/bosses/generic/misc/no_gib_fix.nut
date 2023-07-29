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

class NoGibFixTrait extends BossTrait
{
    function OnDeath(attacker, params)
    {
        if (!(params.death_flags & TF_DEATHFLAG.GIBBED)) //Was gibbed on death
            return;

        local propRagdoll = SpawnEntityFromTable("prop_ragdoll",
        {
            model = player.GetModelName(),
            origin = player.GetOrigin(),
            angles = player.GetAbsAngles(),
            spawnflags = 4
        });
        propRagdoll.SetOwner(player);
        local randomVector = Vector(RandomFloat(-1, 1), RandomFloat(-1, 1), RandomFloat(1, 2));
        randomVector.Norm();
        propRagdoll.SetPhysVelocity((player.GetAbsVelocity() + randomVector) * 10000.0);
    }
};