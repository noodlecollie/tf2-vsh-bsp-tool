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

totalHealthKits <- 0;

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SCOUT
            && WeaponIs(player.GetWeaponBySlot(TF_WEAPONSLOTS.MELEE), "candy_cane");
    }

    function OnDamageDealt(victim, params)
    {
        if (!(params.damage_type & 128) || vsh_vscript.totalHealthKits > 30)
            return;
        local healthKit = SpawnEntityFromTable("item_healthkit_small", {
            "OnPlayerTouch": "!self,Kill,,0,-1",
        });
        vsh_vscript.totalHealthKits++;
        healthKit.SetMoveType(Constants.EMoveType.MOVETYPE_FLYGRAVITY, Constants.EMoveCollide.MOVECOLLIDE_FLY_BOUNCE);
        healthKit.SetAbsOrigin(victim.GetCenter());
        healthKit.SetVelocity(Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 250));
        RunWithDelay2(this, 30, function(healthKit)
        {
            totalHealthKits--;
            if (healthKit != null && healthKit.IsValid())
                healthKit.Kill();
        }, healthKit);
    }
});