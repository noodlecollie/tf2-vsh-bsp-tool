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

PrecacheScriptSound("soldier.gardened")
PrecacheScriptSound("vsh_sfx.gardened");

characterTraitsClasses.push(class extends CharacterTrait
{
    function CanApply()
    {
        return player.GetPlayerClass() == TF_CLASS_SOLDIER;
    }

    function OnDamageDealt(victim, params)
    {
        if (player.InCond(TF_COND_BLASTJUMPING) && WeaponIs(params.weapon, "market_gardener"))
        {
            params.damage = vsh_vscript.CalcStabDamage(victim) / 2.5;
            EmitSoundOn("vsh_sfx.gardened", player);
            EmitPlayerVODelayed(player, "gardened", 0.3);
        }
    }
});