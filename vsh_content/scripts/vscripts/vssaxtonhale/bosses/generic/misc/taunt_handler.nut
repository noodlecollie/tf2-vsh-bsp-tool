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

PrecacheClassVoiceLines("laugh")
PrecacheClassVoiceLines("rps_init")
PrecacheClassVoiceLines("rps_lose")
PrecacheClassVoiceLines("rps_lose_rock")
PrecacheClassVoiceLines("rps_lose_paper")
PrecacheClassVoiceLines("rps_lose_scissors")
PrecacheClassVoiceLines("rps_win_rock")
PrecacheClassVoiceLines("rps_win_paper")
PrecacheClassVoiceLines("rps_win_scissors")
PrecacheClassVoiceLines("rps_on3")
PrecacheClassVoiceLines("rps_1")
PrecacheClassVoiceLines("rps_2")
PrecacheClassVoiceLines("rps_3")
PrecacheClassVoiceLines("high5")

class TauntHandlerTrait extends BossTrait
{
    //Only Valve-made taunts for copyright reasons.
    //Commented-out taunts aren't animated properly.
    static allowedTaunts = [
        -1,
        167 //High Five!
		438 //Director's Vision
		463 //Schadenfreude
		1106 //Square Dance
		1107 //Flippin' Awesome
		1110 //Rock, Paper, Scissors
        1111 //Skullcracker
		1118 //Conga
		1157 //Kazotsky Kick
		1162 //Mannrobics
		//1172 //Victory Lap
		//1182 //Yeti Punch
		//1183 //Yeti Smash
    ];

    isTaunting = false;
    rpsReannounceTime = 0;
    partnerJoinTime = Time() + 9999;
    hasTauntPartner = false;

    function OnApply()
    {
        AddListener("rps_with_boss", 0, OnRPS);
    }

    function OnFrameTickAlive()
    {
        local time = Time();
        local tauntId = GetPropInt(boss, "m_iTauntItemDefIndex");
        if (!hasTauntPartner)
        {
            local tauntPartner = GetPropEntity(boss, "m_hHighFivePartner");
            if (tauntPartner != null)
            {
                hasTauntPartner = true;
                partnerJoinTime = time;
                local tauntIdPartner = GetPropInt(tauntPartner, "m_iTauntItemDefIndex");
                if (tauntIdPartner == 1111)
                    tauntId = 1111;
                if (tauntId == 1110 || tauntIdPartner == 1110) //RPS
                {
                    EmitPlayerVO(boss, "rps_on3");
                    EmitPlayerVODelayed(boss, "rps_1", 1.7);
                    EmitPlayerVODelayed(boss, "rps_2", 2.1);
                    EmitPlayerVODelayed(boss, "rps_3", 2.5);
                    return;
                }
            }
        }
        if (!boss.InCond(TF_COND_TAUNTING))
        {
            isTaunting = false;
            hasTauntPartner = false;
            partnerJoinTime = time + 9999;
            return;
        }
        if (tauntId == 167) //High Five
        {
            if (!isTaunting)
            {
                EmitPlayerVO(boss, "high5");
                isTaunting = true;
            }
        }
        else if (tauntId == 463) //Schadenfreude
        {
            if (!isTaunting)
            {
                EmitPlayerVO(boss, "laugh");
                isTaunting = true;
            }
        }
        else if (tauntId == 1107 || tauntId == 1111) //Flippin' Awesome or Skullcracker
        {
            if (time - partnerJoinTime > (tauntId == 1107 ? 1.45 : 1.72))
            {
                local tauntPartner = GetPropEntity(boss, "m_hHighFivePartner");
                if (tauntPartner != null)
                {
                    local deltaVector = tauntPartner.GetCenter() - boss.GetCenter();
                    deltaVector.z += tauntId == 1107 ? 100 : 20;
                    tauntPartner.TakeDamageEx(
                        boss,
                        boss,
                        boss.GetActiveWeapon(),
                        deltaVector * 1000,
                        boss.GetOrigin(),
                        9999,
                        1);
                    partnerJoinTime = time + 9999;
                }
            }
        }
        else if (tauntId == 1110) //RPS
        {
            if (time - rpsReannounceTime > 6)
            {
                if (GetPropEntity(boss, "m_hHighFivePartner") == null)
                    EmitPlayerVO(boss, "rps_init");
                rpsReannounceTime = time;
            }
            if (!isTaunting)
                isTaunting = true;
        }
        else
            isTaunting = false;
        if (allowedTaunts.find(tauntId) == null)
            boss.RemoveCond(TF_COND_TAUNTING);
    }

    function OnRPS(winner, loser, params)
    {
        local voiceLine = null;
        if (IsBoss(winner))
            voiceLine = "rps_win_"+["rock","paper","scissors"][params.winner_rps];
        else if (IsBoss(loser))
        {
            lostByRPS = true;
            voiceLine = RandomInt(1, 2) == 1 ? "rps_lose" : "rps_lose_"+["rock","paper","scissors"][params.loser_rps];
            RunWithDelay2(this, 3, function(winner, loser) {
                if (!IsValidPlayer(loser))
                    return;
                local attacker = IsValidPlayer(winner) ? winner : lower
                loser.TakeDamageEx(
                    attacker,
                    attacker,
                    attacker.GetActiveWeapon(),
                    Vector(0,0,0),
                    attacker.GetOrigin(),
                    99999,
                    0);
            }, winner, loser);
        }

        if (voiceLine != null)
            PlayAnnouncerVODelayed(IsBoss(winner) ? winner : loser, voiceLine, 1);
    }
};