//-----------------------------------------------------------------------------
// Purpose: Shows in console all equips on host of listen server.
//	-> See top of script for more info
//-----------------------------------------------------------------------------

::CheckItems <- function()
{
	local ActiveWeapon = GetListenServerHost().GetActiveWeapon()
	local ActiveWeaponID = GetItemID(ActiveWeapon)

	Say(GetListenServerHost(), " ", false)
	Say(GetListenServerHost(), format("Active Slot%i [%s] (ItemID = %i)", ActiveWeapon.GetSlot(), ActiveWeapon.GetClassname(), ActiveWeaponID), false)

	for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
	{
		local wep = GetPropEntityArray(GetListenServerHost(), "m_hMyWeapons", i)
		local wep_itemID = GetItemID(wep)
		ClientPrint(GetListenServerHost(), 2, i+" "+wep+" (ItemID = "+wep_itemID+")" )

		if ( wep && wep != ActiveWeapon)
		{
			Say(GetListenServerHost(), format("Slot%i [%s] (ItemID = %i)", wep.GetSlot(), wep.GetClassname(), wep_itemID), false)
		}
	}
}




//-----------------------------------------------------------------------------
// Purpose: Prints error messages if CVAR_GTFW_DEBUG_MODE = true
//-----------------------------------------------------------------------------
::GTFW.DevPrint <- function(error=false,func="",message="")
{
	if ( !CVAR_GTFW_DEBUG_MODE ) return;

	if ( error )
		error = "\tERROR ";
	else error = ""

	printl( format("g_tf_w %s%s: %s",error.tostring(),func.tostring(),message.tostring() ) );
}
//-----------------------------------------------------------------------------
// Purpose: Grabs net name for player
//-----------------------------------------------------------------------------
::GTFW.GetNetName <- function(player) {
	if ( HasProp(player, "m_szNetname") )
		return GetPropString(player, "m_szNetname");
	return player;
}

//-----------------------------------------------------------------------------
// Purpose: Used by events to clean up any unused entities made by this script.
//-----------------------------------------------------------------------------
::CTFPlayer.GTFW_Cleanup <- function()
{
	GTFW.DevPrint(0,"GTFW_Cleanup", "Running cleanup for "+GTFW.GetNetName(this));

	// Deletes any viewmodels that the script has created
	local main_viewmodel = GetPropEntity(this, "m_hViewModel");
	AddThinkToEnt(main_viewmodel, null);	//clears script if it was being used
	if ( main_viewmodel && main_viewmodel.IsValid() ) {
		if ( main_viewmodel.FirstMoveChild() )
		{
			main_viewmodel.FirstMoveChild().Kill()
		}
		if ( this.HasGunslinger() && this.GetPlayerClass() == 9 )
			main_viewmodel.SetModelSimple( GTFW_MODEL_ARMS[10] );
		else
			main_viewmodel.SetModelSimple( GTFW_MODEL_ARMS[this.GetPlayerClass()] );
	}


//clears all custom weapons in player scope
	local player = this;
	local playerScope;
	if( player.ValidateScriptScope() )
	{
		playerScope = player.GetScriptScope();

		if ( "AMMOFIX" in playerScope ) {
			local AmmoFix = playerScope["AMMOFIX"];
			if (AmmoFix && AmmoFix.IsValid() ) {
				GTFW.DevPrint(0,"GTFW_Cleanup", "Deleted AMMOFIX from "+GTFW.GetNetName(player));

				AmmoFix.Kill();
			}
			delete playerScope["AMMOFIX"];
		}
		if ( "classarms" in playerScope ) {
			local classarms = playerScope["classarms"];
			if ( classarms && classarms.IsValid() ) {
				GTFW.DevPrint(0,"GTFW_Cleanup", "Deleted class arms from "+GTFW.GetNetName(player));

				classarms.Kill();
			}
			delete playerScope["classarms"];
		}
	}


// Yaki: Me finding out that I/O works better than VScript
	EntFire("tf_wearable_vs_"+player.entindex()+"*","RunScriptCode","self ? self.Kill() : null",0.0,worldspawn)

}

//-----------------------------------------------------------------------------
// Old stuff connected to GTFW_Cleanup()
/*
	local item = player.FirstMoveChild();

	for ( local i = 0; i < 42; i++ )
	{
		if ( item && item.IsValid() ) {

			if ( item.GetName().find("wearable_vs") ) {
				GTFW.DevPrint(0,"GTFW_Cleanup", "Deleted item... : "+item.GetName() );

				DoEntFire("!self","RunScriptCode","self.Kill()",1.0,item,item);
			}
			if ( item && item.IsValid() ) {
				item = item.NextMovePeer();	//defines next child parented to the player. Repeats
			}
		}
		else break;
	}
/*

/* Deletes passive items found in weapon slots
	local item = null;

	for ( local i = 0; i < 2; i++ ) {
		item = player.GetPassiveWeaponBySlot(i);
		if ( item ) {
			GTFW.DevPrint(0,"GTFW_Cleanup", "Deleted item... : "+item.GetModelName() );

			if ( item.GetClassname() == "tf_wearable_demoshield" )
				SetPropInt(player, "m_Shared.m_bShieldEquipped", 0);

			item.Kill();
		}
	}*/
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// Purpose: Deletes weapons and all wearables tied to it.
//-----------------------------------------------------------------------------
::KillWepAll <- function(wep=null)
{
	if ( type( wep ) != "instance") {
		GTFW.DevPrint(1,"KillWepAll", "Function failed. Parameter 1 not an instance.");
		return null;
	}
	local player = wep.GetOwner();

	if( wep && wep.IsValid() )
	{
		local wearable = GetPropEntity(wep, "m_hExtraWearable");
		local wearable_vm = GetPropEntity(wep, "m_hExtraWearableViewModel");
		if ( wearable && wearable.IsValid() ) {
			GTFW.DevPrint(0,"KillWepAll", "Deleted "+wearable + " from " +GTFW.GetNetName(player));
			wearable.Kill();
		}
		if ( wearable_vm && wearable_vm.IsValid() ) {
			GTFW.DevPrint(0,"KillWepAll", "Deleted VM "+wearable + " from " +GTFW.GetNetName(player));
			wearable_vm.Kill();
		}
		wep.Kill();
	}
}


//-----------------------------------------------------------------------------
// Purpose: For testing if weapon is custom
// If "bool" set to "true", adds bit flags to make the weapon custom
// If "bool" set to "false", removes the bits of a custom weapon
//-----------------------------------------------------------------------------
::IS_CUSTOM <- function(weapon, bool=null)
{
	local CUSTOM_ID = abs(GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemIDHigh"));

// Adds Custom bits if bool==true
	if ( bool && HasProp(weapon,"m_AttributeManager.m_Item.m_iItemIDHigh") ) {
		SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemIDHigh", CUSTOM_ID | (1 << 10) );

		if (weapon.GetOwner())
			GTFW.DevPrint(0,"IS_CUSTOM", format("Added Custom bits to %s's \x22%s\x22",GTFW.GetNetName(weapon.GetOwner()).tostring(), weapon.tostring()));
	}
// Removes Custom bits if bool==false
	else if ( bool == false && HasProp(weapon,"m_AttributeManager.m_Item.m_iItemIDHigh") ) {
		SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemIDHigh", CUSTOM_ID & ~(1 << 10) );

		if (weapon.GetOwner())
			GTFW.DevPrint(0,"IS_CUSTOM", format("Removed Custom bits from %s's \x22%s\x22",GTFW.GetNetName(weapon.GetOwner()).tostring(), weapon.tostring()));
	}

	CUSTOM_ID = abs(GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemIDHigh"));

	if ( CUSTOM_ID & (1 << 10) ) {
		return true;
	}
	else { return false; }
}


//-----------------------------------------------------------------------------
// Purpose: Finds Gunslinger on player, but only for Engineer. If found, returns true.
//-----------------------------------------------------------------------------
::CTFPlayer.HasGunslinger <- function(gunslinger=null)
{
	if ( this.GetPlayerClass() == 9 )
	{
		for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
		{
			local wep = GetPropEntityArray(this, "m_hMyWeapons", i)

			if ( wep && wep.GetClassname() == "tf_weapon_robot_arm" ) {
				return true
			}
		}
	}
	return false
}




//-----------------------------------------------------------------------------
// Purpose: Finds item ID of weapon.
//-----------------------------------------------------------------------------
::GetItemID <- function(wep=null,clearbits=0)
{
//Error if param is wep is null
	if ( type(wep) != "instance" && type(wep) != "integer"  ) {
		GTFW.DevPrint(1,"GetItemID", "Function failed. Parameter 1 is not a handle or int. Returning null.");
		return wep;
	}

	local id = wep;
	if ( type(wep) == "instance"  )
		id = GetPropInt(wep, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

//clears custom bits if "ForceNotCustom" bit set
	if ( clearbits & ForceNotCustom ) {
		for ( local bit = 16; bit <= 21; bit++ ) {
			id = id & ~( 1 << bit );
		}
	}

	return id
}
