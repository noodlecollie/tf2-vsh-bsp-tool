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

function Include(path)
{
    IncludeScript("vssaxtonhale/" + path);
}

Include("__lizardlib/netprops.nut");
Include("__lizardlib/constants.nut");
Include("__lizardlib/listeners.nut");
Include("__lizardlib/player_util.nut");
Include("__lizardlib/weapons.nut");
Include("__lizardlib/character_trait.nut");
Include("__lizardlib/game_events.nut");

::CreateAoE <- function(center, radius, applyDamageFunc, applyPushFunc)
{
    foreach(target in GetAliveMercs())
    {
        local deltaVector = target.GetCenter() - center;
        local distance = deltaVector.Norm();
        if (distance > radius)
            continue;

        applyPushFunc(target, deltaVector, distance);
        applyDamageFunc(target, deltaVector, distance);
    }

    local target = null;
    while (target = Entities.FindByClassname(target, "obj_*"))
    {
        local deltaVector = target.GetCenter() - center;
        local distance = deltaVector.Norm();
        if (distance > radius)
            continue;

        applyDamageFunc(target, deltaVector, distance);
    }
}

::CreateAoEAABB <- function(center, min, max, applyDamageFunc, applyPushFunc)
{
    local min = center + min;
    local max = center + max;
    foreach(target in GetAliveMercs())
    {
        local targetCenter = target.GetCenter();
        if (targetCenter.x >= min.x
            && targetCenter.y >= min.y
            && targetCenter.z >= min.z
            && targetCenter.x <= max.x
            && targetCenter.y <= max.y
            && targetCenter.z <= max.z)
            {
                local deltaVector = targetCenter - center;
                local distance = deltaVector.Norm();
                applyPushFunc(target, deltaVector, distance);
                applyDamageFunc(target, deltaVector, distance);
            }
    }

    local target = null;
    while (target = Entities.FindByClassname(target, "obj_*"))
    {
        local targetCenter = target.GetCenter();
        if (targetCenter.x >= min.x
            && targetCenter.y >= min.y
            && targetCenter.z >= min.z
            && targetCenter.x <= max.x
            && targetCenter.y <= max.y
            && targetCenter.z <= max.z)
            {
                local deltaVector = targetCenter - center;
                local distance = deltaVector.Norm();
                applyDamageFunc(target, deltaVector, distance);
            }
    }
}

::clampCeiling <- function(valueA, valueB)
{
    if (valueA < valueB)
        return valueA;
    return valueB;
}

::clampFloor <- function(valueA, valueB)
{
    if (valueA > valueB)
        return valueA;
    return valueB;
}

::clamp <- function(value, min, max)
{
    if (value < min)
        return min;
    if (value > max)
        return max;
    return value;
}

::SetPersistentVar <- function(name, value)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    persistentVars[name] <- value;
}

::GetPersistentVar <- function(name, defValue = null)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    return name in persistentVars ? persistentVars[name] : defValue;
}

::RunWithDelay <- function(func, activator, delay)
{
    EntFireByHandle(vsh_vscript_entity, "RunScriptCode", func, delay, activator, activator);
}

::RunWithDelay2 <- function (scope, delay, func, ...)
{
    local name = UniqueString();
    vsh_vscript[name] <- function()
    {
        try { func.acall([scope].extend(vargv)) }
        catch (e) { throw e; }
        delete vsh_vscript[name];
    }
    RunWithDelay(name + "()", null, delay);
}