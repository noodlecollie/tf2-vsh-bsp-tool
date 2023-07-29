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

PrecacheScriptSound("vsh_sfx.saxton_punch");
PrecacheScriptSound("saxton_hale.saxton_punch_ready")
PrecacheScriptSound("saxton_hale.saxton_punch")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "vsh_megapunch_shockwave" })

class SaxtonPunchTrait extends BossTrait
{
    meter = -30;

    function OnApply()
    {
        if (!(player in hudAbilityInstances))
            hudAbilityInstances[player] <- [];
        hudAbilityInstances[player].push(this);
    }

    function OnTickAlive(timeDelta)
    {
        if (meter < 0 && !IsRoundSetup())
        {
            meter += timeDelta;
            if (meter >= 0)
            {
                meter = 0;
                vsh_vscript.Hale_SetRedArm(boss, true);
                EmitPlayerVO(boss, "saxton_punch_ready");
                BossPlayViewModelAnim(boss, "vsh_megapunch_ready");
                boss.AddCond(TF_COND_CRITBOOSTED);
            }
        }
    }

    function OnDamageDealt(victim, params)
    {
        if (!IsCollateralDamage(params.damage_type) && player != victim && Perform(victim))
            params.damage_type = DMG_BLAST;
    }

    function Perform(victim)
    {
        if (meter != 0)
            return false;
        meter -= 30;

        vsh_vscript.Hale_SetRedArm(boss, false);

        local haleEyeVector = boss.EyeAngles().Forward();
        haleEyeVector.Norm();

        boss.RemoveCond(TF_COND_CRITBOOSTED);
        EmitSoundOn("TFPlayer.CritHit", boss);
        EmitSoundOn("vsh_sfx.saxton_punch", boss);
        if (GetAliveMercCount() > 1)
            EmitPlayerVO(boss, "saxton_punch");
        DispatchParticleEffect("vsh_megapunch_shockwave", victim.EyePosition(), QAngle(0,boss.EyeAngles().Yaw(),0).Forward());
        ScreenShake(boss.GetCenter(), 10, 2.5, 1, 1000, 0, true);

        CreateAoE(boss.GetCenter(), 600,
            function (target, deltaVector, distance) {
                local dot = haleEyeVector.Dot(deltaVector);
                if (dot < 0.6)
                    return;
                local damage = target.GetMaxHealth() * (0.7 - distance / 2000);
                if (!target.IsPlayer())
                    damage *= 2;
                target.TakeDamageEx(
                    boss,
                    boss,
                    boss.GetActiveWeapon(),
                    deltaVector * 1250,
                    boss.GetOrigin(),
                    damage,
                    DMG_BLAST);
            }
            function (target, deltaVector, distance) {
                local dot = haleEyeVector.Dot(deltaVector);
                if (dot < 0.6)
                    return;
                local pushForce = distance < 100 ? 10 : 10 / sqrt(distance);
                deltaVector.x = deltaVector.x * 1250 * pushForce;
                deltaVector.y = deltaVector.y * 1250 * pushForce;
                deltaVector.z = 750 * pushForce;
                target.Yeet(deltaVector);
            });
        return true;
    }

    function MeterAsPercentage()
    {
        if (meter < 0)
            return (30 + meter) * 100 / 30;
        return 200
    }

    function MeterAsNumber()
    {
        local mapped = -meter+0.99;
        if (mapped <= 1)
            return "r";
        if (mapped < 10)
            return format(" %d", mapped);
        else
            return format("%d", mapped);
    }

    function MeterAsColor()
    {
        if (meter < 0)
            return "255 255 255";
        return "0 255 0";
    }
};