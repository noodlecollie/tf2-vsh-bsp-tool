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

::listeners <- {}

//The higher the value the LATER it will execute
::AddListener <- function(event, order, listener, scope = null)
{
    local listenerEntry = [order, listener, scope];
    if (event in listeners)
    {
        local queue = listeners[event]
        local size = queue.len()
        local i = 0
        for (; i < size; i++)
            if (queue[i][0] > order)
                break
        queue.insert(i, listenerEntry)
    }
    else
        listeners[event] <- [listenerEntry]
    return listenerEntry;
}

//Removing listeners is not really intended,
//  but in case you need it, you can store the return of `AddListener` in a variable,
//  and then pass that variable to `RemoveListener`.
::RemoveListener <- function(entry)
{
    if (entry in listeners)
        listeners.remove(entry);
}

::FireListeners <- function(event, ...)
{
    if (!(event in listeners))
        return;

    foreach (entry in listeners[event])
    {
        local scope = entry[2];
        if (scope == null)
            scope = this;
        try { entry[1].acall([scope].extend(vargv)) }
        catch (e) { throw e; }
    }
}
