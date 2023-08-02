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

foreach (c in [
    Constants.ETFClass,
    Constants.ETFTeam,
    Constants.ETFCond,
    Constants.FPlayer,
    Constants.FButtons,
    Constants.FDmgType,
    Constants.FSolid,
    Constants.ETFDmgCustom
])
    foreach (k, v in c)
        getroottable()[k] <- v;

::TF_TEAM_UNASSIGNED <- TEAM_UNASSIGNED;
::TF_TEAM_SPECTATOR <- TEAM_SPECTATOR;
::TF_TEAM_BLU <- TF_TEAM_RED;
::TF_TEAM_MERC <- TF_TEAM_RED;
::TF_TEAM_MERCS <- TF_TEAM_RED;
::TF_TEAM_BOSS <- TF_TEAM_BLUE;
::TF_TEAM_BOSSES <- TF_TEAM_BLUE;
::TF_CLASS_HEAVY <- TF_CLASS_HEAVYWEAPONS;
::MAX_PLAYERS <- MaxClients().tointeger();

::TF_CLASS_NAMES <- [
    "generic",
    "scout",
    "sniper",
    "soldier",
    "demo",
    "medic",
    "heavy",
    "pyro",
    "spy",
    "engineer"
];

enum TF_DEATHFLAG
{
    KILLER_DOMINATION = 1,
    ASSISTER_DOMINATION = 2,
    KILLER_REVENGE = 4
    ASSISTER_REVENGE = 8
    FIRST_BLOOD = 16
    DEAD_RINGER = 32
    INTERRUPTED = 64
    GIBBED = 128
    PURGATORY = 256
}

enum LIFE_STATE
{
    ALIVE = 0,
    DYING = 1,
    DEAD = 2,
    RESPAWNABLE = 3,
    DISCARDBODY = 4
}