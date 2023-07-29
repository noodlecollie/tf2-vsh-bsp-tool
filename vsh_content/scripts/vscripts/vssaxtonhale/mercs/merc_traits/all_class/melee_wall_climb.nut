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

hitStreak <- {};
ignoreWallClimb <- [
    "player",
    "tf_bot",
    "obj_sentrygun",
    "obj_dispenser",
    "obj_teleporter"
]

function MeleeWallClimb_Hit(params)
{
    if (IsMercValidAndAlive(params.attacker))
        MeleeClimb_Perform(params.attacker);
}

function MeleeWallClimb_Check(params)
{
    return ignoreWallClimb.find(params.const_entity.GetClassname()) == null;
}

AddListener("tick_always", 0, function (timeDelta)
{
    foreach (player in GetAliveMercs())
        if ((player.GetFlags() & FL_ONGROUND))
            hitStreak[player] <- 0;
});

function MeleeClimb_Perform(player, quickFixLink = false)
{
    local hits = (player in hitStreak ? hitStreak[player] : 0) + 1;
    local launchVelocity = hits == 1 ? 600 : hits == 2 ? 450 : hits <= 4 ? 400 : 200;
    hitStreak[player] <- hits;

    SetPropEntity(player, "m_hGroundEntity", null);
    player.RemoveFlag(FL_ONGROUND);

    local newVelocity = player.GetAbsVelocity();
    if (hits == 2)
    {
        newVelocity.x /= 2;
        newVelocity.y /= 2;
    }
    newVelocity.z = launchVelocity > 430 ? launchVelocity : launchVelocity + newVelocity.z;
    player.SetAbsVelocity(newVelocity);
    FireListeners("wall_climb", player, hits, quickFixLink);

    if (!quickFixLink)
        foreach (otherPlayer in GetAliveMercs())
        {
            if (otherPlayer.GetPlayerClass() != TF_CLASS_MEDIC)
                return;
            local medigun = otherPlayer.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
            if (!WeaponIs(medigun,"quick_fix"))
                return;
            local target = GetPropEntity(medigun, "m_hHealingTarget");
            if (target == player)
                return MeleeClimb_Perform(otherPlayer, true);
        }
}