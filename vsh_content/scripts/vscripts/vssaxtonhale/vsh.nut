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

ClearGameEventCallbacks();

IncludeScript("vssaxtonhale/__lizardlib/util.nut");
Include("/util/entities.nut");
Include("/vsh_api.nut");
Include("/util/player_cache.nut");
Include("/_gamemode/boss_queue.nut");
Include("/_gamemode/forced_arena.nut");
Include("/_gamemode/scoreboard.nut");
Include("/util/voice_line_manager.nut");
Include("/give_tf_weapon/_master.nut");
Include("/mercs/merc_traits.nut");
Include("/_gamemode/round_logic.nut");
Include("/bosses/boss.nut");
Include("/_gamemode/hud.nut");
Include("/_gamemode/gamerules.nut");

try { IncludeScript("vsh_addons/main.nut"); } catch(e) { }

__CollectGameEventCallbacks(this);
__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);