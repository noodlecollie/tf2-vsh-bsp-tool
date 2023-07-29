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

::VSH_API_DEF_VALUES <- {
    boss_scale = 1.2,
    round_time = 240,
    jump_force = 700,
    health_factor = 40,
    setup_length = 16,
    setup_lines = true,
    beer_lines = false,
    long_setup_lines = true,
    setup_countdown_lines = true,
    spawn_protection = false,
    ability_hud_folder = "vgui/vssaxtonhale/"
}

::VSH_API_VALUES <- {}

function ReadMapAPI()
{
    local vshConfigEnt = null;
    while (vshConfigEnt = Entities.FindByName(vshConfigEnt, "vsh_config"))
    {
        local key = "error";
        for (local i = 0; i < 63; i++)
        {
            local entry = strip(GetPropString(vshConfigEnt, "m_iszControlPointNames["+i+"]"));
            if (entry.len() == 0)
                continue;
            if (i % 2 == 0)
                key = entry;
            else
                VSH_API_VALUES[key] <- entry;
        }
    }
}
ReadMapAPI();

::API_GetString <- function(key)
{
    if (key in VSH_API_VALUES)
        return VSH_API_VALUES[key];
    return VSH_API_DEF_VALUES[key];
}

::API_GetInt <- function(key)
{
    if (key in VSH_API_VALUES)
        try { return VSH_API_VALUES[key].tointeger(); } catch(e) { }
    return VSH_API_DEF_VALUES[key].tointeger();
}

::API_GetBool <- function(key)
{
    if (key in VSH_API_VALUES)
    {
        if (VSH_API_VALUES[key] == "true")
            return true;
        else if (VSH_API_VALUES[key] == "false")
            return false;
    }
    return API_GetInt(key) > 0;
}

::API_GetFloat <- function(key)
{
    if (key in VSH_API_VALUES)
        try { return VSH_API_VALUES[key].tofloat(); } catch(e) { }
    return VSH_API_DEF_VALUES[key].tofloat();
}