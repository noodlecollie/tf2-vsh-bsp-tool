//-----------------------------------------------------------------------------
// Purpose: Returns weapon from player as a hPlayer.
//-----------------------------------------------------------------------------
::CTFPlayer.GetWeapon <- function(searched_weapon=null)
{
//Error if param is null
	if ( searched_weapon == null ) {
		GTFW.DevPrint(1,"GetWeapon", "Function failed. Parameter is null. Returning null.")
		return null
	}
//searches for the correct item based on parameter 'searched_weapon'...
	local table = this.GetWeaponTable(searched_weapon);
	if ( table == null ) {
		GTFW.DevPrint(1,"GetWeapon", "Function failed. Could not find \x22"+searched_weapon+"\x22. Returning null.");
		return null;
	}

	local player = this;
	local WepC = table.classname;
	local GetThis = table.itemID;
	local Slot = table.slot;
	local YourGunFoundBySaxtonHale;

// Searches passive weapons like Gunboats, Targe, etc.
	if ( SearchPassiveItems.find(WepC) ) {
		YourGunFoundBySaxtonHale = player.GetPassiveWeaponBySlot(Slot);
	}
// Searches for active weapons
	else {
		for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
		{
			local wep = GetPropEntityArray(this, "m_hMyWeapons", i);

			if ( wep )
			{
				if ( GTFW.TestWeaponBySlotBool(wep, searched_weapon) )
				{
					GetThis = GetItemID(wep);
				}
				if ( GetItemID(wep) == GetThis )
				{
					YourGunFoundBySaxtonHale = wep;
					break;
				}
			}
		}
	}

	if ( YourGunFoundBySaxtonHale == null ) {
		GTFW.DevPrint(1,"GetWeapon", "Function failed. Could not find \x22"+searched_weapon+"\x22 (ID "+table.itemID+"). Returning null.");
		return null;
	}
	return YourGunFoundBySaxtonHale;
}



//-----------------------------------------------------------------------------
// Purpose: Returns weapon, searched by slot.
// Requested by Lizard of Oz
//-----------------------------------------------------------------------------
::CTFPlayer.GetWeaponBySlot <- function(slot)
{
	if ( type( slot ) != "integer" ) {
		GTFW.DevPrint(1,"GetWeaponBySlot", "Parameter 1 not an integer. Returning null.")
		return null
	}
	local ply = this;
	local GetThis;
	local YourGunFoundBySaxtonHale;

	for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
	{
		local wep = GetPropEntityArray(ply, "m_hMyWeapons", i);

		if ( wep == null ) continue
			if ( GetWeaponBySlotBool(wep, slot) )
			{
				GetThis = wep.GetClassname();
			}
			if ( wep.GetClassname() == GetThis )
			{
				YourGunFoundBySaxtonHale = wep;
				break;
			}
	}
	return YourGunFoundBySaxtonHale;
}


//-----------------------------------------------------------------------------
// Purpose: Find slot of weapon by classname
//			Searches some lists to find the weapon in the slot
//-----------------------------------------------------------------------------

::GetWeaponSlot <- function(classname) {
	local weapon = classname.find("weapon") ? classname.slice(10) : classname;
	if ( SearchPrimaryWeapons.find( weapon ) )
		return 0;
	else if ( SearchSecondaryWeapons.find( weapon ) )
		return 1;
	else if ( SearchMeleeWeapons.find( weapon ) )
		return 2;
	else if ( SearchSlot3Weapons.find( weapon ) )
		return 3;
	else if ( SearchSlot4Weapons.find( weapon ) )
		return 4;
	else if ( SearchSlot5Weapons.find( weapon ) )
		return 5;
	else if ( SearchSlot6Weapons.find( weapon ) )
		return 6;
	return -1;
}


//-----------------------------------------------------------------------------
// Purpose: Finds passive weapons like Booties, Gunboats, Targe, etc.
// 			Looks through entities parented to the player.
//-----------------------------------------------------------------------------
::CTFPlayer.GetPassiveWeaponBySlot <- function(Slot=0)
{
//define variables
	local player = this;
	local item = player.FirstMoveChild();
	local getWeapon;

	while ( item )
	{
	//	if ( item && item.IsValid() ) {
			local itemC = item.GetClassname()
			local itemID = GetItemID(item,ForceNotCustom)

			if ( Slot == 0 ) {
				if (itemID == 405	//Ali Baba's Wee Booties
				 ||	itemID == 608		//Bootlegger
				 ||	itemC == "tf_weapon_parachute"				//BASE Jumper
				 ||	itemC == "tf_weapon_parachute_primary" ) {	//BASE Jumper Demo
					GTFW.DevPrint(0,"GetPassiveWeaponBySlot", format("Found %s in slot %i.",itemC,Slot) );

					getWeapon = item;
					break;
				}
			}
			else if ( Slot == 1 ) {
				if (itemID == 231			//Darwin's Danger Shield
				 ||	itemID == 642			//Cozy Camper
				 ||	itemID == 133			//Gunboats
				 ||	itemID == 444			//Mantreads
				 ||	itemC == "tf_wearable_demoshield"		//Demo Shields
				 ||	itemC == "tf_wearable_razorback"		//Razorback
				 ||	itemC == "tf_weapon_parachute"		//BASE Jumper
				 ||	itemC == "tf_weapon_parachute_secondary" ) {	//BASE Jumper Soldier
					GTFW.DevPrint(0,"GetPassiveWeaponBySlot", format("Found %s in slot %i.",itemC,Slot) );

					getWeapon = item;
					break;
				}
			}
			else if ( Slot >= 7 ) {
				if (itemC == "tf_wearable_vs"	//the classname keyvalue is changed from "tf_wearable" -> "tf_wearable_vs". Found in file `GiveWeapon().nut`
				 || itemID == 231			//Darwin's Danger Shield
				 ||	itemID == 642			//Cozy Camper
				 ||	itemID == 133			//Gunboats
				 ||	itemID == 444			//Mantreads
				 || itemID == 405		//Ali Baba's Wee Booties
				 ||	itemID == 608		//Bootlegger
				 ||	itemC == "tf_wearable_demoshield"		//Demo Shields
				 ||	itemC == "tf_wearable_razorback"		//Razorback
				 ||	itemC == "tf_weapon_parachute"					//BASE Jumper
				 ||	itemC == "tf_weapon_parachute_primary"			//BASE Jumper Demo
				 ||	itemC == "tf_weapon_parachute_secondary" ) {	//BASE Jumper Soldier
					GTFW.DevPrint(0,"GetPassiveWeaponBySlot", format("Found %s in slot %i.",itemC,Slot) );

					getWeapon = item;
					break;
				}
			}

		// if it doesn't find anything...
			if ( item )
				item = item.NextMovePeer();	//searches the next child parented to the player.
	//	}
	//	else break;
	}

	return getWeapon
}


//-----------------------------------------------------------------------------
// Purpose: Finds a weapon by slot.
// function GetWeaponBySlotBool = slot number must be positive
// function GTFW.TestWeaponBySlotBool = Does the same as above but slot must be negative, used by this script
// function GTFW.CheckNegativeSlotBool = Just needs a negative slot#
//-----------------------------------------------------------------------------
::GetWeaponBySlotBool <- function(wep=null, slot=0)
{
	return wep.GetSlot() == slot ? true : false;
}
::GTFW.TestWeaponBySlotBool <- function(wep=null, slot=-0.0)
{
	if ( type ( slot ) == "integer" || slot == -0.0 ) {
		local string = split(slot.tostring()+"a",abs(slot).tostring())[0];
		if ( string == "-" )	//if slot checks as negative... test!
		{
			slot = abs(slot);
			if ( wep.GetSlot() == slot )
			{
				return true;
			}
		}
	}
	return false;
}
::GTFW.CheckNegativeSlotBool <- function(slot=-0.0)
{
	if ( type ( slot ) == "integer" || slot == -0.0 ) {
		local string = split(slot.tostring()+"a",abs(slot).tostring())[0];
		if ( string == "-" )	//if slot checks as negative... test!
		{
			return true;
		}
	}
	return false;
}
