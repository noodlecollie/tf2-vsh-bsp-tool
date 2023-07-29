//-----------------------------------------------------------------------------
//	Purpose: Handles registering custom weapons.
//-----------------------------------------------------------------------------
::RegisterCustomWeapon <- function(item_name, weapon, ItemDefinitionIndex_Override=null, gw_props=Defaults, PostWepFix=null, stats_function=null)
{
//Error if item_name is not a string
	if ( type( item_name ) != "string" ) {
		GTFW.DevPrint(1,"RegisterCustomWeapon", "Function failed. MUST use strings for custom item name. Returning null.");
		return null;
	}

	GTFW.DevPrint(0,"RegisterCustomWeapon", "Registering... \x22"+item_name+"\x22");

// Cancel registration check
	local CustomWeaponTable = GetWeaponTableNoPlayer(item_name);
	if ( CustomWeaponTable 			//Is name taken? If it pulls up a table, skips this check.
	 && !CVAR_GTFW_DEBUG_MODE ) {	//and is Debug mode OFF? if OFF, skip this check.
		GTFW.DevPrint(1,"RegisterCustomWeapon", "\x22"+item_name+"\x22 was already taken!");
		return null;
	}

//searches for the correct item based on parameter 'weapon'...
//  'weapon' can be a handle, string name (ex "Brass Beast"), classname (i.e. "raygun", "tf_wearable", etc), or weapon item definition index (from items_game.txt).
//  However, it does not support taking a weapon slot (i.e. TF_AMMOSLOTS.SLOT0).
	local table = GetWeaponTableNoPlayer(weapon);

	if ( table == null ) {
		GTFW.DevPrint(1,"RegisterCustomWeapon", "Function failed. Param 2 is a weapon that doesn't exist. Returning null.");
		return null;
	}


// Purpose: Override item ID
// If you wanted to create a weapon with different classname+IDX combos, this is the way.
//  Can make things like Reserve Shooter for as an Engineer Primary, for example!
	//accepts items_game.txt IDX's
	if ( type(ItemDefinitionIndex_Override) == "integer" && ItemDefinitionIndex_Override >= 0 && ItemDefinitionIndex_Override <= 65535) {
		table.itemID = GTFW.UniqueItemDefinitionIndex(ItemDefinitionIndex_Override);
		table.tf_class = GetWeaponTableNoPlayer(ItemDefinitionIndex_Override).tf_class;
	}
	//accepts names of weapons (i.e. "Toolbox")
	else if ( type(ItemDefinitionIndex_Override) == "string" ) {
		table.itemID = GTFW.UniqueItemDefinitionIndex(GetWeaponTableNoPlayer(ItemDefinitionIndex_Override).itemID);
		table.tf_class = GetWeaponTableNoPlayer(ItemDefinitionIndex_Override).tf_class;
	}
	// GTFW.UniqueItemDefinitionIndex() is a function that updates the IDX to a unique one (up to 63 different IDXs available as of GTFW v5.0.0)
	else table.itemID = GTFW.UniqueItemDefinitionIndex(table.itemID);

// Purpose: MvM / upgrading weapons via upgrade station
// If trying to find a weapon's slot (by "weapon = TF_WEAPONSLOTS.PRIMARY", for example), replace the weapon's classname to based on what ever the weapon you are currently using.
	if ( type( weapon ) == "integer" && weapon < 0 && weapon >= -6)	{
		table.classname = weapon;
		table.slot = abs(weapon);
	}

	if ( gw_props != Defaults )
		table.gw_props = gw_props;

	GTFW.DevPrint(0,"RegisterCustomWeapon", "Success! Registered \x22" + item_name + "\x22! IDX : "+table.itemID )

	::TF_CUSTOM_WEAPONS_REGISTRY[item_name] <- TF_CUSTOM_WEPS(item_name, table.classname, table.tf_class, table.slot, table.itemID, table.gw_props, stats_function, table.classArms, table.ammoType, table.clipSize, table.clipSizeMax, table.reserve, table.reserveMax, table.worldModel, table.viewModel, table.wearable, table.wearable_vm, PostWepFix, table.announce_quality, table.announce_prefix, table.announce_has_string)
}



//-----------------------------------------------------------------------------
//	Purpose: Updates the item definition index (IDX) to a unique one.
//			 This function generates up to 63 unique IDX's for one weapon IDX, uses bits 16-21 in different combinations.
//  DevNote: 65535 is the highest item definition index, while bit (1<<16) = 65536
//-----------------------------------------------------------------------------
::GTFW.UniqueItemDefinitionIndex <- function(ID=null)
{
	//This function is only usable within the scope of this function
	GTFW.MakeCustom <- function(i) {
		//Clears all item IDs bits so we just have the bits we want
		for ( local bit = 0; bit <= 15; bit++ ) {
			i = i & ~( 1 << bit );
		}

		switch ( i ) {
		//yes I did this by hand
			case (1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21) : i = (1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<18)|(1<<19)|(1<<20)|(1<<21) : i = (1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<18)|(1<<19)|(1<<20)|(1<<21) : i = (1<<16)|(1<<18)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<19)|(1<<20)|(1<<21) : i = (1<<18)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<17)|(1<<19)|(1<<20)|(1<<21) : i = (1<<16)|(1<<17)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<19)|(1<<20)|(1<<21) : i = (1<<17)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<19)|(1<<20)|(1<<21) : i = (1<<16)|(1<<19)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<20)|(1<<21) : i = (1<<19)|(1<<20)|(1<<21); break;
			case (1<<17)|(1<<18)|(1<<20)|(1<<21) : i = (1<<16)|(1<<17)|(1<<18)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<18)|(1<<20)|(1<<21) : i = (1<<17)|(1<<18)|(1<<20)|(1<<21); break;
			case (1<<18)|(1<<20)|(1<<21) : i = (1<<16)|(1<<18)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<20)|(1<<21) : i = (1<<18)|(1<<20)|(1<<21); break;
			case (1<<17)|(1<<20)|(1<<21) : i = (1<<16)|(1<<17)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<20)|(1<<21) : i = (1<<17)|(1<<20)|(1<<21); break;
			case (1<<20)|(1<<21) : i = (1<<16)|(1<<20)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<21) : i = (1<<20)|(1<<21); break;
			case (1<<17)|(1<<18)|(1<<19)|(1<<21) : i = (1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<21); break;
			case (1<<16)|(1<<18)|(1<<19)|(1<<21) : i = (1<<17)|(1<<18)|(1<<19)|(1<<21); break;
			case (1<<18)|(1<<19)|(1<<21) : i = (1<<16)|(1<<18)|(1<<19)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<19)|(1<<21) : i = (1<<18)|(1<<19)|(1<<21); break;
			case (1<<17)|(1<<19)|(1<<21) : i = (1<<16)|(1<<17)|(1<<19)|(1<<21); break;
			case (1<<16)|(1<<19)|(1<<21) : i = (1<<17)|(1<<19)|(1<<21); break;
			case (1<<19)|(1<<21) : i = (1<<16)|(1<<19)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<21) : i = (1<<19)|(1<<21); break;
			case (1<<17)|(1<<18)|(1<<21) : i = (1<<16)|(1<<17)|(1<<18)|(1<<21); break;
			case (1<<16)|(1<<18)|(1<<21) : i = (1<<17)|(1<<18)|(1<<21); break;
			case (1<<18)|(1<<21) : i = (1<<16)|(1<<18)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<21) : i = (1<<18)|(1<<21); break;
			case (1<<17)|(1<<21) : i = (1<<16)|(1<<17)|(1<<21); break;
			case (1<<16)|(1<<21) : i = (1<<17)|(1<<21); break;
			case (1<<21) : i = (1<<16)|(1<<21); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20) : i = (1<<21); break;
			case (1<<17)|(1<<18)|(1<<19)|(1<<20) : i = (1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20); break;
			case (1<<16)|(1<<18)|(1<<19)|(1<<20) : i = (1<<17)|(1<<18)|(1<<19)|(1<<20); break;
			case (1<<18)|(1<<19)|(1<<20) : i = (1<<16)|(1<<18)|(1<<19)|(1<<20); break;
			case (1<<16)|(1<<17)|(1<<19)|(1<<20) : i = (1<<18)|(1<<19)|(1<<20); break;
			case (1<<17)|(1<<19)|(1<<20) : i = (1<<16)|(1<<17)|(1<<19)|(1<<20); break;
			case (1<<16)|(1<<19)|(1<<20) : i = (1<<17)|(1<<19)|(1<<20); break;
			case (1<<19)|(1<<20) : i = (1<<16)|(1<<19)|(1<<20); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<20) : i = (1<<19)|(1<<20); break;
			case (1<<17)|(1<<18)|(1<<20) : i = (1<<16)|(1<<17)|(1<<18)|(1<<20); break;
			case (1<<16)|(1<<18)|(1<<20) : i = (1<<17)|(1<<18)|(1<<20); break;
			case (1<<18)|(1<<20) : i = (1<<16)|(1<<18)|(1<<20); break;
			case (1<<16)|(1<<17)|(1<<20) : i = (1<<18)|(1<<20); break;
			case (1<<17)|(1<<20) : i = (1<<16)|(1<<17)|(1<<20); break;
			case (1<<16)|(1<<20) : i = (1<<17)|(1<<20); break;
			case (1<<20) : i = (1<<16)|(1<<20); break;
			case (1<<16)|(1<<17)|(1<<18)|(1<<19) : i = (1<<20); break;
			case (1<<17)|(1<<18)|(1<<19) : i = (1<<16)|(1<<17)|(1<<18)|(1<<19); break;
			case (1<<16)|(1<<18)|(1<<19) : i = (1<<17)|(1<<18)|(1<<19); break;
			case (1<<18)|(1<<19) : i = (1<<16)|(1<<18)|(1<<19); break;
			case (1<<16)|(1<<17)|(1<<19) : i = (1<<18)|(1<<19); break;
			case (1<<17)|(1<<19) : i = (1<<16)|(1<<17)|(1<<19); break;
			case (1<<16)|(1<<19) : i = (1<<17)|(1<<19); break;
			case (1<<19) : i = (1<<16)|(1<<19); break;
			case (1<<16)|(1<<17)|(1<<18) : i = (1<<19); break;
			case (1<<17)|(1<<18) : i = (1<<16)|(1<<17)|(1<<18); break;
			case (1<<16)|(1<<18) : i = (1<<17)|(1<<18); break;
			case (1<<18) : i = (1<<16)|(1<<18); break;
			case (1<<16)|(1<<17) : i = (1<<18); break;
			case (1<<17) : i = (1<<16)|(1<<17); break;
			case (1<<16) : i = (1<<17); break;
			case 0 : i = (1 << 16); break;

			default : throw "error! made too many of the same weapon type!" ; break;
		}

		return i
	}


	if ( type( ID ) != "integer" ) {
		GTFW.DevPrint(1,"UniqueItemDefinitionIndex", "error");
	}

	//printl("starting id : "+ID)

	for ( local bit = 16; bit <= 21; bit++ ) {
		ID = ID & ~( 1 << bit );
	}

	//printl("base id " + ID)

	local i;
	local weaponList = [];
	foreach (table in TF_CUSTOM_WEAPONS_REGISTRY)
	{
		local tableID = table.itemID
		for ( local bit = 16; bit <= 21; bit++ ) {
			tableID = tableID & ~( 1 << bit );
			//printl("OK... " + tableID)
		}

		if ( tableID == ID ) {
			weaponList.append(table.itemID);
			//printl("right... ")
		}
	}
	//grabs all custom weapons of the base item, and puts them into a list
	//then
	if ( weaponList.len() ) {
		weaponList.sort(@(a,b) a <=> b);
		for ( local n = 0; n < weaponList.len(); n++ )
		{
			i = GTFW.MakeCustom(weaponList[n]);

			//printl("loop "+n + " : "+i)
		}
	}
	else i = GTFW.MakeCustom(ID);

	//printl("ending id : "+i)

	ID = ( ID + i );

	return ID;
}
