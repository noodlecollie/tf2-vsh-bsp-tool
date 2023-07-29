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

PrecacheScriptSound("demo.sticky_trap")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tickInverval = 0.5;
    playInterval = 30;
    deltaStickies = 0.0;
    oldStickyValue = 0;

    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_DEMOMAN;
    }

    function OnTickAlive(timeDelta)
    {
        local newStickyValue = clampFloor(0, GetPropInt(player.GetActiveWeapon(), "PipebombLauncherLocalData.m_iPipebombCount"));

        if (deltaStickies < -0.5)
            oldStickyValue = newStickyValue;
        deltaStickies = clampFloor(0, deltaStickies - timeDelta / 2.0);
        deltaStickies += newStickyValue - oldStickyValue;
        oldStickyValue = newStickyValue;

        if (deltaStickies > 2.8)
        {
            deltaStickies = -1;
            return EmitPlayerVO(player, "sticky_trap");
        }
    }
});