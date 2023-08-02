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

PrecacheClassVoiceLines("jump")

enum BOSS_JUMP_STATUS
{
    WALKING = 0,
    JUMP_STARTED = 1,
    CAN_DOUBLE_JUMP = 2,
    DOUBLE_JUMPED = 3
};

class BraveJumpTrait extends BossTrait
{
    jumpForce = API_GetFloat("jump_force");
    jumpStatus = BOSS_JUMP_STATUS.WALKING;
    voiceLinePlayed = 0;
    lastTimeJumped = Time();

    function OnFrameTickAlive()
    {
        local buttons = GetPropInt(boss, "m_nButtons");

        if (!boss.IsOnGround())
        {
            if (jumpStatus == BOSS_JUMP_STATUS.WALKING)
                jumpStatus = BOSS_JUMP_STATUS.JUMP_STARTED;
            else if (jumpStatus == BOSS_JUMP_STATUS.JUMP_STARTED && !(buttons & IN_JUMP))
                jumpStatus = BOSS_JUMP_STATUS.CAN_DOUBLE_JUMP;
        }
        else
            jumpStatus = BOSS_JUMP_STATUS.WALKING;

        if (buttons & IN_JUMP && jumpStatus == BOSS_JUMP_STATUS.CAN_DOUBLE_JUMP)
        {
            if (!IsRoundSetup() && Time() - voiceLinePlayed > 1.5)
            {
                voiceLinePlayed = Time();
                EmitPlayerVO(boss, "jump");
            }

            jumpStatus = BOSS_JUMP_STATUS.DOUBLE_JUMPED;
            Perform();
        }

        if (Time() > lastTimeJumped + API_GetInt("setup_length") + 30)
        {
            NotifyJump();
        }
    }

    function Perform()
    {
        lastTimeJumped = Time() + 9999;

        local buttons = GetPropInt(boss, "m_nButtons");
        local eyeAngles = boss.EyeAngles();
        local forward = eyeAngles.Forward();
        forward.z = 0;
        forward.Norm();
        local left = eyeAngles.Left();
        left.z = 0;
        left.Norm();

        local forwardmove = 0
        if (buttons & IN_FORWARD)
            forwardmove = 1;
        else if (buttons & IN_BACK)
            forwardmove = -1;
        local sidemove = 0
        if (buttons & IN_MOVELEFT)
            sidemove = -1;
        else if (buttons & IN_MOVERIGHT)
            sidemove = 1;

        local newVelocity = Vector(0,0,0);
        newVelocity.x = forward.x * forwardmove + left.x * sidemove;
        newVelocity.y = forward.y * forwardmove + left.y * sidemove;
        newVelocity.Norm();
        newVelocity *= 300;
        newVelocity.z = jumpForce

        local currentVelocity = boss.GetAbsVelocity();
        if (currentVelocity.z < 300)
            currentVelocity.z = 0;

        SetPropEntity(boss, "m_hGroundEntity", null);
        boss.SetAbsVelocity(currentVelocity + newVelocity);
    }

    function NotifyJump()
    {
        lastTimeJumped = Time() + 9999;
        local text_tf = SpawnEntityFromTable("game_text_tf", {
            message = "#ClassTips_1_2",
            icon = "ico_notify_flag_moving_alt",
            background = TF_TEAM_BOSS,
            display_to_team = TF_TEAM_BOSS
        });
        EntFireByHandle(text_tf, "Display", "", 0.1, player, player);
        EntFireByHandle(text_tf, "Kill", "", 1, player, player);
    }
};