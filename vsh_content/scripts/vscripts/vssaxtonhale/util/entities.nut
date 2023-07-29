::vsh_vscript <- this;
if(self.GetName() == "")
    self.KeyValueFromString("targetname", "logic_script_vsh");
::vsh_vscript_name <- self.GetName();
::vsh_vscript_entity <- self;

//This hack allows to detect when a melee weapon hits the world
::worldspawn <- Entities.FindByClassname(null, "worldspawn");
SetPropInt(worldspawn, "m_takedamage", 1);

::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules");
tf_gamerules.ValidateScriptScope();
::tf_player_manager <- Entities.FindByClassname(null,"tf_player_manager");
::team_round_timer <- null;
::pd_logic <- null;