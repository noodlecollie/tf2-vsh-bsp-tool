//-----------------------------------------------------------------------------
// Purpose: Finds the best weapon to switch to and switches to it.
//			Accepts handle only
//			If no param is set, then switches to the best weapon (from primary to slot6)
//-----------------------------------------------------------------------------
::CTFPlayer.SwitchToBest <- function(NewGun=null)
{
	if ( NewGun && NewGun.IsValid() && SearchPassiveItems.find(NewGun.GetClassname()) ) {
		GTFW.DevPrint(1,"SwitchToBest", "Function failed. Handle cannot be switched to!");
		return null;
	}

	local ply = this;

// Purpose: Calls above function by a delay because sending wep.Kill() is delayed
	if ( type( NewGun ) == "instance" ) {
		local wep_entindex = NewGun.entindex();
		EntFireByHandle(ply,"RunScriptCode","GTFW.SwitchDelay(self,"+wep_entindex+")",0.07,ply,ply);
	}
	else {
		EntFireByHandle(ply,"RunScriptCode","GTFW.SwitchDelay(self)",0.07,ply,ply);
	}
}
//-----------------------------------------------------------------------------
// Purpose: The actual weapon switch code.
//			Above "SwitchToBest()" is just there for the delay.
//-----------------------------------------------------------------------------
::GTFW.SwitchDelay <- function(ply,wep_entindex=null) {
	local SwitchTo;
	if ( wep_entindex )
		SwitchTo = EntIndexToHScript(wep_entindex);

	local wep;

	if ( ply.GetActiveWeapon() == SwitchTo ) { }
	else if ( !SwitchTo || !SwitchTo.GetClassname().find("weapon") ) {

		local list = [-1, -1, -1, -1, -1, -1, -1];

		for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
		{
			wep = GetPropEntityArray(ply, "m_hMyWeapons", i);
			if ( wep == null ) continue

				switch ( wep.GetSlot() ) {
					case 0 : list.remove(0); list.insert(0, wep.entindex()); break;
					case 1 : list.remove(1); list.insert(1, wep.entindex()); break;
					case 2 : list.remove(2); list.insert(2, wep.entindex()); break;
					case 3 : list.remove(3); list.insert(3, wep.entindex()); break;
					case 4 : list.remove(4); list.insert(4, wep.entindex()); break;
					case 5 : list.remove(5); list.insert(5, wep.entindex()); break;
					case 6 : list.remove(6); list.insert(6, wep.entindex()); break;
					default : break;
				}
		}
		foreach ( v in list ) {
			if ( v == -1 ) continue
				SwitchTo = EntIndexToHScript(v);
				break;
		}
	}
	if ( SwitchTo && SwitchTo != ply.GetActiveWeapon() ) {
		if ( SwitchTo.GetClassname().find("weapon") )	//fixes disabling weapon switch by changing classname of weapon
			ply.Weapon_Switch(SwitchTo);
	}
//This part fixes broken switching animations if the weapon has a different class_arms than original
	else if ( SwitchTo && SwitchTo == ply.GetActiveWeapon() && IS_CUSTOM(SwitchTo) ) {
	//Creates a dummy weapon to switch to then back to the intended weapon, to fix class_arms
		local dummy = ply.AddWeapon("tf_weapon_bat", 0, 47);	//creates a dummy weapon
		EntFireByHandle(ply,"RunScriptCode","EntIndexToHScript("+dummy.entindex()+") ? self.Weapon_Switch(EntIndexToHScript("+dummy.entindex()+")) : null",0.01,ply,ply);
		EntFireByHandle(ply,"RunScriptCode","EntIndexToHScript("+SwitchTo.entindex()+") ? self.Weapon_Switch(EntIndexToHScript("+SwitchTo.entindex()+")) : null",0.03,ply,ply);
		EntFireByHandle(dummy,"RunScriptCode","self ? self.Kill() : null",0.06,dummy,dummy);
	}
}