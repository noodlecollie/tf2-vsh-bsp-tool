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

damage <- {}

function ResetRoundDamage()
{
    damage <- {};
}

function GetRoundDamage(player)
{
    return player in damage ? damage[player] : 0;
}

function SetRoundDamage(player, damageValue)
{
    damage[player] <- damageValue;
}

AddListener("player_hurt", 5, function (attacker, victim, params)
{
    local damage = params.damageamount;
    if (victim.GetHealth() < 0)
        damage -= params.health - victim.GetHealth();
    if (!IsValidBoss(victim))
        return;
    SetRoundDamage(attacker, GetRoundDamage(attacker) + damage);
});

function GetDamageBoardSorted()
{
    function sortFunction(it, that)
    {
        return that[1] - it[1];
    }

    local damageAsArray = []
    foreach(player, dmg in damage)
        damageAsArray.push([player, dmg]);
    damageAsArray.sort(@(it, that) that[1] - it[1]);
    return damageAsArray;
}