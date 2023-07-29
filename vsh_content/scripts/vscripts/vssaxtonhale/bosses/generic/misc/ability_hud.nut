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

::hudAbilityInstances <- {};

class AbilityHudTrait extends BossTrait
{
    game_text_tip_1 = null;
    game_text_tip_2 = null;
    game_text_charge = null;
    game_text_punch = null;
    game_text_slam = null;

    //₁₂₃₄₅₆₇₈₉₀
    //¹²³⁴⁵⁶⁷⁸⁹⁰
    big2small = {
        " ": " ", //" "
        "r": "✔",
        "1": "₁",
        "2": "₂",
        "3": "₃",
        "4": "₄",
        "5": "₅",
        "6": "₆",
        "7": "₇",
        "8": "₈",
        "9": "₉",
        "0": "₀",
    };

    function OnApply()
    {
        game_text_tip_1 = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 3,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 9999,
            message = "Hold 'Reload'",
            spawnflags = 0,
            x = 0.665,
            y = 0.955
        });

        game_text_tip_2 = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 5,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 9999,
            message = "Hold 'Crouch'",
            spawnflags = 0,
            x = 0.88,
            y = 0.955
        });

        game_text_charge = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 0,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.67,
            y = 0.91
        });

        game_text_punch = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 1,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.778,
            y = 0.91
        });

        game_text_slam = SpawnEntityFromTable("game_text",
        {
            color = "255 255 255",
            color2 = "0 0 0",
            channel = 2,
            effect = 0,
            fadein = 0,
            fadeout = 0,
            fxtime = 0,
            holdtime = 250,
            message = "0",
            spawnflags = 0,
            x = 0.885,
            y = 0.91
        });

        RunWithDelay2(this, 0.2, function () {
            EntFireByHandle(game_text_tip_1, "Display", "", 0, boss, boss);
            EntFireByHandle(game_text_tip_2, "Display", "", 0, boss, boss);
        });
    }

    function OnTickAlive(timeDelta)
    {
        if (!(player in hudAbilityInstances))
            return;

        local progressBarTexts = [];
        local colors = [];
        local overlay = "";
        foreach(ability in hudAbilityInstances[player])
        {
            local percentage = ability.MeterAsPercentage();
            local progressBarText = BigToSmallNumbers(ability.MeterAsNumber())+" ";
            local i = 13;
            for(; i < clampCeiling(100, percentage); i+=13)
                progressBarText += "▰";
            for(; i <= 100; i+=13)
                progressBarText += "▱";
            progressBarTexts.push(progressBarText);
            colors.push(ability.MeterAsColor());
            if (percentage >= 100)
                overlay += "on_";
            else
                overlay += "off_";
        }

        EntFireByHandle(game_text_charge, "AddOutput", "message "+progressBarTexts[0], 0, boss, boss);
        EntFireByHandle(game_text_charge, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_punch, "AddOutput", "message "+progressBarTexts[1], 0, boss, boss);
        EntFireByHandle(game_text_punch, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_slam, "AddOutput", "message "+progressBarTexts[2], 0, boss, boss);
        EntFireByHandle(game_text_slam, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_tip_1, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_tip_2, "Display", "", 0, boss, boss);

        player.SetScriptOverlayMaterial(API_GetString("ability_hud_folder") + "/" + overlay);
    }

    function OnDeath(attacker, params)
    {
        EntFireByHandle(game_text_charge, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_charge, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_punch, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_punch, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_slam, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_slam, "Display", "", 0, boss, boss);

        EntFireByHandle(game_text_tip_1, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_tip_1, "Display", "", 0, boss, boss);
        EntFireByHandle(game_text_tip_2, "AddOutput", "message ", 0, boss, boss);
        EntFireByHandle(game_text_tip_2, "Display", "", 0, boss, boss);

        player.SetScriptOverlayMaterial("");
    }

    function BigToSmallNumbers(input)
    {
        local result = "";
        foreach (char in input)
            result += big2small[char.tochar()];
        return result;
    }
};