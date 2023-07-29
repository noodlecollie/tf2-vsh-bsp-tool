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

PrecacheClassVoiceLines("rage")
PrecacheScriptSound("xmas.jingle_noisemaker");

class StunBreakoutTrait extends BossTrait
{
    stunTimer = 0;
    stunInitHealth = 0;
    holidayPunchTimeStamp = 0;

    function OnTickAlive(timeDelta)
    {
        if (boss.IsControlStunned() || (Time() - holidayPunchTimeStamp <= 4 && boss.InCond(TF_COND_TAUNTING)))
        {
            stunTimer += timeDelta;

            if (stunInitHealth == 0)
                stunInitHealth = boss.GetHealth();
            else if (boss.GetHealth() < stunInitHealth - 1000)
            {
                DoBreakOut();
                return;
            }
        }
        else if (stunTimer > 0)
            stunTimer -= timeDelta;
        if (stunTimer < 0)
        {
            stunTimer = 0;
            stunInitHealth = 0;
        }

        if (stunTimer >= 4)
            DoBreakOut();
    }

    function OnDamageTaken(attacker, params)
    {
        if (WeaponIs(params.weapon, "holiday_punch") && !boss.InCond(TF_COND_TAUNTING))
        {
            RunWithDelay2(this, 0, function(boss)
            {
                if (IsValidBoss(boss) && boss.InCond(TF_COND_TAUNTING))
                {
                    EmitPlayerVO(attacker, "laugh");
                    EmitSoundOn("xmas.jingle_noisemaker", boss);
                    holidayPunchTimeStamp = Time();
                    EmitPlayerVO(boss, "laugh");
                    boss.AddCustomAttribute("airblast vulnerability multiplier", 0.01, 4)
                    boss.AddCustomAttribute("damage force increase", 0.7, 4)
                }
            }, boss);
        };
    }

    function DoBreakOut()
    {
        stunTimer = 0;
        stunInitHealth = 0;

        EmitPlayerVO(boss, "rage");
        boss.RemoveCond(TF_COND_STUNNED);
        boss.RemoveCond(TF_COND_TAUNTING);
        boss.Yeet(Vector(0,0,800));

        DispatchParticleEffect("hammer_impact_button", boss.GetOrigin() + Vector(0,0,20), Vector(0,0,0));
        EmitSoundOn("vsh_sfx.boss_slam_impact", boss);

        CreateAoE(boss.GetCenter(), 400,
            function (target, deltaVector, distance) {
                target.TakeDamageEx(
                    boss,
                    boss,
                    boss.GetActiveWeapon(),
                    deltaVector * 1250,
                    boss.GetOrigin(),
                    1,
                    1);
            }
            function (target, deltaVector, distance) {
                local pushForce = distance < 100 ? 10 : 10 / sqrt(distance);
                deltaVector.x = deltaVector.x * 1450 * pushForce;
                deltaVector.y = deltaVector.y * 1450 * pushForce;
                deltaVector.z = 450 * pushForce;
                target.Yeet(deltaVector);
            });
    }
};