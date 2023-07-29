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

PrecacheScriptSound("soldier.setup_special")

characterTraitsClasses.push(class extends CustomVoiceLine
{
    tmpFix = [false];
    function CanApply()
    {
        if (!tmpFix[0] && player.GetPlayerClass() == TF_CLASS_SOLDIER
            && RandomInt(0, 5) == 0
            && WeaponIs(player.GetWeaponBySlot(TF_WEAPONSLOTS.PRIMARY), "rocket_jumper"))
        {
            tmpFix[0] = true;
            local secondary = player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY);
            if (secondary == null)
                return true;
            local clip = GetPropInt(player.GetWeaponBySlot(TF_WEAPONSLOTS.SECONDARY), "LocalWeaponData.m_iClip1");
            return clip < 0 || clip >= 255;
        }
        return false;
    }

    function OnApply()
    {
        EmitPlayerVODelayed(player, "setup_special", RandomInt(13, 15));
    }
});