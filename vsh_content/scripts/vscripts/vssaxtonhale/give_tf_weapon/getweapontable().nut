//-----------------------------------------------------------------------------
// Purpose: Finds a weapon based on handle, slot, ID, classnames, or string.
// 			Requires player handle to start the function.
//-----------------------------------------------------------------------------

::CTFPlayer.GetWeaponTableBySlot <- function(slot=TF_WEAPONSLOTS.SLOT0)
{
	if ( slot == null || type ( slot ) != "integer" ) {
		GTFW.DevPrint(1,"GetWeaponTableBySlot", "Function failed. Parameter is Null. Returning null.");
		return null;
	}
	
	local ply = this;
	
// Purpose: Begins to search by slot
// All slots MUST be searched as negative number, otherwise it won't take.
	if ( GTFW.CheckNegativeSlotBool(slot) ) {
		for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
		{
			local wep = GetPropEntityArray(ply, "m_hMyWeapons", i);
			if ( wep )
			{
				if ( GTFW.TestWeaponBySlotBool(wep, slot) )
				{
					local ItemID = GetItemID(wep);
					local baseitem = GetWeaponTableNoPlayer(ItemID);
					baseitem = GTFW.PostWepFix(baseitem,ply);
					return baseitem;
				}
			}
		}
	}
//if all else fails, have an error!
	GTFW.DevPrint(1,"GetWeaponTableBySlot", "Function failed. Could not find weapon by slot. Returning null.");
	return null;
}

::CTFPlayer.GetWeaponTableByClassname <- function(WepC=null)
{
	if ( WepC == null || type ( WepC ) != "string" ) {
		GTFW.DevPrint(1,"GetWeaponTableByClassname", "Function failed. Parameter is Null. Returning null.");
		return null;
	}
	
	local ply = this;
	
// Purpose: Searches by classname.
// 			Runs a loop to check all entities under array netprop "m_hMyWeapons"
	 if ( type( WepC ) == "string"
	 && SearchAllWeapons.find( WepC.find("weapon") ? WepC.slice(10) : WepC ) ) {	// makes sure to remove "tf_weapon_" if it's there
		WepC = WepC.find("weapon") ? WepC : "tf_weapon_" + WepC;				// makes sure "tf_weapon_" is added if it wasn't there before

		for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
		{
			local wep = GetPropEntityArray(ply, "m_hMyWeapons", i);

			if ( wep )
			{
				if ( wep.GetClassname() == WepC )
				{
					local ItemID = GetItemID(wep);
					local baseitem = GetWeaponTableNoPlayer(ItemID);
					baseitem = GTFW.PostWepFix(baseitem, ply);
					return baseitem;
				}
			}
		}
	}
//if all else fails, have an error!
	GTFW.DevPrint(1,"GetWeaponTableByClassname", "Function failed. Could not find weapon by classname. Returning null.");
	return null;
}

::CTFPlayer.GetWeaponTableByString <- function(string=null)
{
	if ( string == null || type ( string ) != "string" ) {
		GTFW.DevPrint(1,"GetWeaponTableByString", "Function failed. Parameter is Null. Returning null.");
		return null;
	}
	
// Purpose: Catches item names (i.e. "Brass Beast" or "Wrench", etc)
	local baseitem = GetWeaponTableNoPlayer(string);
	
	if ( baseitem ) {
		baseitem = GTFW.PostWepFix(baseitem,this);
		return baseitem;
	}
	
//if all else fails, have an error!
	GTFW.DevPrint(1,"GetWeaponTableByString", "Function failed. Could not find weapon by name. Returning null.");
	return null;
}

::CTFPlayer.GetWeaponTableByID <- function(idx=null)
{
	if ( type ( idx ) != "integer" && type ( idx ) != "instance" ) {
		GTFW.DevPrint(1,"GetWeaponTableByID", "Function failed. Parameter is not an integer or instance. Returning null.")
		return null
	}
	
	local ItemID = idx
	if ( type( idx ) == "instance" && HasProp(idx, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") ) {
		ItemID = GetItemID(idx)
	}
	
	// this one catches item IDs if we are using a handle
	local baseitem = GetWeaponTableNoPlayer(ItemID)
	
	if ( baseitem ) {
		baseitem = GTFW.PostWepFix(baseitem,this)
		return baseitem
	}
	
//if all else fails, have an error!
	GTFW.DevPrint(1,"GetWeaponTableByID", "Function failed. Could not find weapon by Item Definition Index. Returning null.")
	return null
}








//-----------------------------------------------------------------------------
// Purpose: Finds a weapon based on handle, slot, ID, classnames, or string.
// 			Requires player handle to start the function.
//-----------------------------------------------------------------------------
::CTFPlayer.GetWeaponTable <- function(weapon=null)
{	
	if ( weapon == null ) {
		GTFW.DevPrint(1,"GetWeaponTable", "Function failed. Parameter is Null. Returning null.");
		return null;
	}
	else 
		GTFW.DevPrint(0,"GetWeaponTable", "Getting table for \x22"+weapon+"\x22.");

	
	local ply = this;
	local getWeapon;

	getWeapon = ply.GetWeaponTableBySlot(weapon)
	if ( getWeapon )
		return getWeapon;
	getWeapon = ply.GetWeaponTableByClassname(weapon)
	if ( getWeapon )
		return getWeapon;
	getWeapon = ply.GetWeaponTableByString(weapon)
	if ( getWeapon )
		return getWeapon;
	getWeapon = ply.GetWeaponTableByID(weapon)
	if ( getWeapon )
		return getWeapon;
	
//if all else fails, have an error!
	GTFW.DevPrint(1,"GetWeaponTable", "Function failed. Could not find \x22"+weapon+"\x22. Returning null.");
	return null;
}





	
//-----------------------------------------------------------------------------
// Purpose: Searches all items under tables.nut, then returns a table
// 			First looks through all custom weapons that were registered
// 			Same as handle.GetWeaponTable() but without the handle and post fixes to classnames/ammo.
// 			Used by handle.GetWeaponTable().
//-----------------------------------------------------------------------------
::GetWeaponTableNoPlayer <- function(baseitem=null)
{
	if ( baseitem == null ) {
		GTFW.DevPrint(1,"GetWeaponTableNoPlayer", "Function failed.");
		return;
	}
	
//Define variables
	local typeItem = type ( baseitem );
	local baseitem_toupper;
	if ( typeItem == "string" )
		baseitem_toupper = baseitem.toupper();
	
	local Continue = true
	local ID;
	local wepTable;
	
	local classname;
	local itemid;
	local itemstring;
	local itemstring2;
	
	foreach (table in TF_CUSTOM_WEAPONS_REGISTRY)
	{
		itemstring	= table.name;
		itemid		= table.itemID;
	
	//Searches for CW name first
		if ( typeItem == "string"
		 && itemstring.toupper() == baseitem_toupper )
		{
			ID = itemid;
			wepTable = GTFW.PreWepFix(table, ID);
			
			Continue = false;
			return wepTable;
		}
	//Next searches for item item definition index
		else if ( itemid == baseitem )
		{
			ID = itemid;
			wepTable = GTFW.PreWepFix(table, ID);
				
			Continue = false;
			return wepTable;
		}
	}
	if ( Continue )
	{
		foreach (table in TF_WEAPONS_ALL)
		{
			classname	= table.classname;
			itemid		= table.itemID;
			itemstring = "";
			if ( table.name ) {
				itemstring	= table.name.toupper();
			}
			itemstring2 = "";
			if ( table.name2 ) {
				itemstring2	= table.name2.toupper();
			}
			
	//Searches for classname first, due to things like "revolver" and "REVOLVER" potentially processing as the same thing
			if ( typeItem == "string"
			 && table.classname == baseitem )
			{
				ID = itemid;
				
				wepTable = GTFW.PreWepFix(table, ID);
				
				Continue = false;
				return wepTable;
			}
	// Searches for item string next
			if ( typeItem == "string"
			 && itemstring == baseitem_toupper || itemstring2 == baseitem_toupper )
			{
				ID = itemid;
				
				wepTable = GTFW.PreWepFix(table, ID);
				
				Continue = false;
				return wepTable;
			}
	// then tries item definition index
			if ( itemid == baseitem )
			{
				ID = itemid;
				
				wepTable = GTFW.PreWepFix(table, ID);
				
				Continue = false;
				return wepTable;
			}
		}
	//Searches for warpaints n bot killers last
		if ( Continue )
		{
			foreach (table in TF_WEAPONS_ALL_WARPAINTSnBOTKILLERS)
			{
				if ( table.itemID == baseitem || table.itemID2 == baseitem || table.itemID3 == baseitem
				|| table.itemID4 == baseitem || table.itemID5 == baseitem || table.itemID6 == baseitem
				|| table.itemID7 == baseitem || table.itemID8 == baseitem || table.itemID9 == baseitem
				|| table.itemID10 == baseitem || table.itemID11 == baseitem || table.itemID12 == baseitem
				|| table.itemID13 == baseitem || table.itemID14 == baseitem || table.itemID15 == baseitem)
				{
					if ( table.itemID == baseitem ) {
						ID = table.itemID;
					}
					else if ( table.itemID2 == baseitem )
						ID = table.itemID2;
					else if ( table.itemID3 == baseitem )
						ID = table.itemID3;
					else if ( table.itemID4 == baseitem )
						ID = table.itemID4;
					else if ( table.itemID5 == baseitem )
						ID = table.itemID5;
					else if ( table.itemID6 == baseitem )
						ID = table.itemID6;
					else if ( table.itemID7 == baseitem )
						ID = table.itemID7;
					else if ( table.itemID8 == baseitem )
						ID = table.itemID8;
					else if ( table.itemID9 == baseitem )
						ID = table.itemID9;
					else if ( table.itemID10 == baseitem )
						ID = table.itemID10;
					else if ( table.itemID11 == baseitem )
						ID = table.itemID11;
					else if ( table.itemID12 == baseitem )
						ID = table.itemID12;
					else if ( table.itemID13 == baseitem )
						ID = table.itemID13;
					else if ( table.itemID14 == baseitem )
						ID = table.itemID14;
					else if ( table.itemID15 == baseitem )
						ID = table.itemID15;
					
					wepTable = GTFW.PreWepFix(table, ID);
					
					return wepTable;
				}
			}
		}
	}
	
	GTFW.DevPrint(1,"GetWeaponTableNoPlayer", "Function failed.");
	return null
}


//-----------------------------------------------------------------------------
// Purpose: Pre-Fixes up all items when found by handle.GetWeaponTable().
// It shoves everything into a table.
//-----------------------------------------------------------------------------
::GTFW.PreWepFix <- function(table, ID)
{
	local tf_class = 0;
	local func;
	local worldModel;
	local viewModel;
	local classarms;
	
	if ( "tf_class" in table )
		tf_class = table.tf_class;
	
	if ( "func" in table )
		func = table.func;

	if ( "worldModel" in table && "viewModel" in table ) {
		worldModel = table.worldModel;
		viewModel = table.viewModel;
	}
	else if ( "worldModel" in table && !("viewModel" in table) ) {
		worldModel = table.worldModel;
		viewModel = table.worldModel;
	}
	else if ( "viewModel" in table && !("worldModel" in table) ) {
		worldModel = table.viewModel;
		viewModel = table.viewModel;
	}

	if ( "classarms" in table )
		classarms = table.classArms;

	
	local itemName	= table.name;
	local slot		= table.slot;
	local classname	= table.classname;
	local itemID	= ID;
	local ammoType	= table.ammoType;
	
	
	local clipSize	= table.clipSize;
	local clipSizeMax;
	if ( "clipSizeMax" in table )
		clipSizeMax	= table.clipSizeMax;
	else
		clipSizeMax	= table.clipSize;
	
	local reserve	= table.reserve;
	local reserveMax;
	if ( "reserveMax" in table )
		reserveMax	= table.reserveMax;
	else
		reserveMax	= table.reserve;
	
	local wearable	= table.wearable;
	
	local wearable_vm;
	if ( "wearable_vm" in table )
		wearable_vm	= table.wearable_vm;
	
	// gw_props stands for GiveWeapon PROPertieS
	// It's a bitmask that gives extra customization for weapons
	// i.e. if the weapon replaces the old one in slot, if it auto switches when obtained, if the weapon is announced in chat, etc.
	// "Defaults" is defined in `_master.nut`
	local gw_props = 0;
	if ( "gw_props" in table )
		gw_props = table.gw_props;
	
	//AnnounceToChat bitmask
	 // item quality; color
	local announce_quality;
	if ( "announce_quality" in table )
		announce_quality = table.announce_quality;
	 // item prefix; i.e. "Unusual", "Haunted", "Collector's", etc.
	local announce_prefix;
	if ( "announce_prefix" in table )
		announce_prefix = table.announce_prefix;
	 // item "has found:" string
	local announce_has_string;
	if ( "announce_has_string" in table )
		announce_has_string = table.announce_has_string;


	// Post Wep Fix, for changing any other attributes
	local postwepfix;
	if ( "PostWepFix" in table )
		postwepfix = table.PostWepFix;
	
	// Finalize
	local baseitem	= TF_WEAPONS_BASE(tf_class, slot, classname, itemID, itemName, ammoType, clipSize, clipSizeMax, reserve, reserveMax, worldModel, viewModel, wearable, wearable_vm, gw_props, func, classarms, postwepfix, announce_quality, announce_prefix, announce_has_string)
	
	return baseitem
}



//-----------------------------------------------------------------------------
// Purpose: Post-Fixes up all items found by handle.GetWeaponTable.
// Things like what the classname is, what type of shotgun it is, etc.
// Supports inserting custom function using RegisterCustomWeapon()
//-----------------------------------------------------------------------------
::GTFW.PostWepFix <- function(table, ply)
{
	local wep = table;
	if ( wep == null) {
		return;
	}

// Define variable
	local WepC = wep.classname;
	
	if ( WepC == "demoshield" )
		wep.classname = "tf_wearable_demoshield";
	else if ( WepC == "razorback" )
		wep.classname = "tf_wearable_razorback";
	else if ( WepC == "tf_wearable" )
		wep.classname = WepC;
	else if ( WepC == "saxxy" )
		wep.classname = GTFW_Saxxy[ply.GetPlayerClass()];
	else if ( WepC == "pistol" ) {
	// All-Class Winger
		if ( wep.itemID == 449 ) {
			wep.name		= "Winger";
		}
	// All-Class Pocket Pistol
		else if ( wep.itemID == 773 ) {
			wep.name		= "Pretty Boy's Pocket Pistol";
		}
		
		if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SCOUT ) {
			wep.classname	= "pistol_scout";
			wep.reserve	= 36;
			wep.tf_class 	= Constants.ETFClass.TF_CLASS_SCOUT;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER ) {
			wep.classname	= "pistol";
			wep.reserve	= 200;
			wep.tf_class 	= Constants.ETFClass.TF_CLASS_ENGINEER;
		}
		else {
			wep.classname	= "pistol";
			wep.reserve	= 36;
			wep.tf_class 	= Constants.ETFClass.TF_CLASS_ENGINEER;
		}
	}
	else if ( WepC == "pistol_scout" ) {
		if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER ) {
			wep.classname	= "pistol_scout";
			wep.reserve		= 200;
			wep.tf_class 	= Constants.ETFClass.TF_CLASS_ENGINEER;
		}
	}
	else if ( WepC == "shotgun" ) {
	//Fixups for All-Class Shotguns
		if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_ENGINEER ) {
			wep.classname	= "shotgun_primary";
			wep.slot = 0;
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_ENGINEER;
			wep.ammoType	=	TF_AMMO.PRIMARY;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_HEAVYWEAPONS ) {
			wep.classname	= "shotgun_hwg";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_HEAVYWEAPONS;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SOLDIER ) {
			wep.classname	= "shotgun_soldier";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_SOLDIER;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_PYRO ) {
			wep.classname	= "shotgun_pyro";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_PYRO;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_DEMOMAN ) {
			wep.classname	= "shotgun_soldier";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_SOLDIER;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_MEDIC ) {
			wep.classname	= "shotgun_primary";
			wep.slot = 0;
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_ENGINEER;
			wep.ammoType	=	TF_AMMO.PRIMARY;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SPY ) {
			wep.classname	= "shotgun_primary";
			wep.slot = 0;
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_ENGINEER;
			wep.ammoType	=	TF_AMMO.PRIMARY;
		}
		else if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SCOUT ) {
			wep.classname	= "shotgun_primary";
			wep.slot = 0;
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_ENGINEER;
			wep.ammoType	=	TF_AMMO.PRIMARY;
		}
		else {
			wep.classname	= "shotgun_pyro";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_PYRO;
		}
	// All-Class Widowmaker
		if ( wep.itemID == 527 ) {
			wep.name		= "Widowmaker";
			wep.ammoType	=	TF_AMMO.METAL;
		}
	// All-Class Frontier Justice
		else if ( wep.itemID == 141 ) {
			wep.name		= "Frontier Justice";
		}
	// All-Class Family Business
		else if ( wep.itemID == 527 ) {
			wep.name		= "Family Business";
		}
	}
	else if ( WepC == "katana" ) {
		if ( ply.GetPlayerClass() == Constants.ETFClass.TF_CLASS_DEMOMAN ) {
			wep.classname = "katana";
			wep.tf_class 	=	Constants.ETFClass.TF_CLASS_DEMOMAN;
		}
	}
	else if ( WepC == "revolver" ) {
		if ( ply.GetPlayerClass() != Constants.ETFClass.TF_CLASS_SPY ) {
			wep.classname = "revolver";
			wep.ammoType	=	TF_AMMO.PRIMARY;
		}
	}
	else if ( WepC == "parachute" || WepC == "parachute_primary" || WepC == "parachute_secondary" ) {
		if ( wep.itemID == 1101 ) {
			wep.name		= "B.A.S.E. Jumper";	//updates announce quality name
		}
	}
//Stock items
	else if ( wep.itemID <= 30 )
		wep.announce_quality = 0;	// gray quality (for stock items)
// Horseless Horseman's Headtaker
	else if ( wep.itemID == 266 )
		wep.announce_quality = 5;	// Unusual quality (for HHHH)


// If making a custom item, run this function
	if ( wep.PostWepFix ) {
		wep.PostWepFix(wep, ply);
	}

// Adds prefix "tf_weapon_" if unavailable
	if ( !wep.classname.find("wearable") ) 
		wep.classname = wep.classname.find("weapon") ? wep.classname : "tf_weapon_" + wep.classname;

	return wep
}
