//-----------------------------------------------------------------------------
//	Purpose: Gives a weapon to the player.
//			 This script's bread 'n' butter.
//-----------------------------------------------------------------------------

::CTFPlayer.GiveWeapon <- function(weapon,ItemDefinitionIndex_Override=null,gw_props=Defaults,PostWepFix_Override=null,stats_function_Override=null)
{
// Starts with GetWeaponTable(weapon).
// This searches for the weapon in the database, and returns an assembled table with all the properties we need to make this weapon!
	local table;
// if we just put a classname in "weapon", pick the first "if" statement. Else, use the second statement.
	if ( type ( weapon ) == "string" && SearchAllWeapons.find( weapon.find("weapon") ? weapon.slice(10) : weapon ) ) {
		table = GetWeaponTableNoPlayer(weapon);
	}
	else { table = this.GetWeaponTable(weapon); }

// Error if there is no valid item found
	if ( table == null ) {
		GTFW.DevPrint(1,"GiveWeapon", "Function failed at finding item \x22"+weapon+"\x22. Returning null.");
		return null;
	}

// Fixes up the weapon if override present
	if ( type( PostWepFix_Override ) == "function" ) {
		PostWepFix_Override(table, this);
	}

// Define variables
	local player = this;

// Establish all variables from the table inside this script
	local WepC				= table.classname;
	local PlayerTFClass		= table.tf_class;
	local ItemID			= table.itemID;
	local Slot				= table.slot;
	local AmmoType			= table.ammoType;
	local ClipSize			= table.clipSize;
	local MaxClipSize		= table.clipSizeMax;
	local AmmoReserve		= table.reserve;
	local MaxAmmoReserve	= table.reserveMax;
	local Extra_Wearable	= table.wearable;
	local Extra_Wearable_VM	= table.wearable_vm;
	local AnnounceQuality	= table.announce_quality;
	local AnnouncePrefix	= table.announce_prefix;
	local AnnounceHasString	= table.announce_has_string;

	local worldModel		= table.worldModel;
	local viewModel		 	= table.viewModel;
	local stats_function 	= table.func;
	local classarms		 	= table.classArms;

	if ( ItemDefinitionIndex_Override ) {
		local overrides	= GetWeaponTableNoPlayer(ItemDefinitionIndex_Override)
		ItemID			= overrides.itemID;
		PlayerTFClass	= overrides.tf_class;
	}


// Purpose: Create weapon by classname
// If you wanted to create a weapon by classname + Item Definition Index, this is the way.
	if ( type ( weapon ) == "string" && SearchAllWeapons.find( weapon.find("weapon") ? weapon.slice(10) : weapon ) ) { // makes sure the string doesn't have "tf_weapon_" in it
		WepC = weapon.find("weapon") ? weapon : "tf_weapon_" + weapon;	//adds "tf_weapon_" if the string didn't have it before
	}


// Purpose: Extra properties for the weapon.
//	It utilizes a set of bits. This works exactly how the most entities with `effects` keyvalue can hold so many options inside one number!
	if ( type ( gw_props ) != "integer" ) { gw_props = Defaults; }
	else { gw_props = gw_props | table.gw_props; }

	local bit_DeleteAndReplace	= gw_props & DeleteAndReplace ? true : false;
	local bit_KeepIDX			= gw_props & KeepIDX ? true : false;
	local bit_AutoSwitch		= gw_props & AutoSwitch ? true : false;
	local bit_WipeAttributes	= gw_props & WipeAttributes ? true : false;
	local bit_ForceCustom		= gw_props & ForceCustom ? true : false;
	local bit_ForceNotCustom	= gw_props & ForceNotCustom ? true : false;
	local bit_AnnounceToChat	= gw_props & AnnounceToChat ? true : false;
	local bit_SaveWeapon		= gw_props & Save ? true : false;
	local bit_AutoRegister		= gw_props & AutoRegister ? true : false;


// Purpose: Weapon Creation
// It finds a slot to replace, deletes that weapon in slot, then creates either a passive item (i.e. booties, etc) or a active weapon.

	local GivenWeapon;

// This thing is might be huge, but the bulk of it is finding and deleting passive items. (also, active ones)
	if (  bit_KeepIDX == false ) {
		//If ReplaceWeapon is set in bitmasks, it finds the weapon in the slot the new weapon would be in, then deletes it.
		if ( bit_DeleteAndReplace ) {
			for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++) {

				local wep = GetPropEntityArray(player, "m_hMyWeapons", i);

				if ( wep == null ) continue
					if ( wep.GetSlot() == Slot ) {
						SetPropEntityArray(player, "m_hMyWeapons", null, i);
						KillWepAll(wep);
						break
					}
			}

	// Finds passive weapons like Gunboats, Targe, etc.
			local item = player.GetPassiveWeaponBySlot(Slot);
			if ( item ) {

				if ( item.GetClassname() == "tf_wearable_demoshield" )
					SetPropInt(player, "m_Shared.m_bShieldEquipped", 0);

				KillWepAll(item);
			}
			GTFW.DevPrint(0,"GiveWeapon", "Removed item from slot "+Slot+"!");
		}

	// Purpose: This creates the new items
	// Passive items: If the classname matches any of these under SearchPassiveItems (list in tables.nut), it creates a wearable. The "CreateCustomWearable()" function does the rest.
	// Active items: else, it creates the new active weapon using the "AddWeapon" function.

	// Purpose: Creates a passive item
		if ( SearchPassiveItems.find(WepC) ) {
			if ( ItemID < 65535						//if not custom. If bit 16 or over is set, it goes over this number
			 || WepC == "tf_wearable_demoshield" )	//if a demoshield
				GivenWeapon = player.CreateCustomWearable(WepC, null, ItemID);
			else
				GivenWeapon = player.CreateCustomWearable(WepC, worldModel, ItemID);

			//Demoshield fix
			if ( WepC == "tf_wearable_demoshield" )
				SetPropInt(player, "m_Shared.m_bShieldEquipped", 1);
		}
		else {
	// Purpose: Creates an active weapon
			for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++) {

				local wep = GetPropEntityArray(player, "m_hMyWeapons", i);

				if ( wep ) continue
					GivenWeapon = player.AddWeapon(WepC, ItemID, i);
					break;
			}
		}
	}

// If "bit_keepIDX" set to true, it will only change the item definition index of the weapon.
	else {
		GivenWeapon = player.ReturnWeaponBySlot(Slot);
		if ( ItemID >= 0 ) {
			SetPropInt(GivenWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", ItemID );
		}
		else {
			SetPropInt(GivenWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", GetItemID(GivenWeapon) );
		}
		GTFW.DevPrint(0,"GiveWeapon", "bit_keepIDX = true. \x22"+weapon+"\x22 updated to IDX "+GetPropInt(GivenWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")+"!");
	}

// Purpose: seems to throw an error only if it didn't create a weapon,
// that can only happen if weps in `m_hMyWeapons` exceeds GLOBAL_WEAPON_COUNT
	if ( GivenWeapon == null ) {
		GTFW.DevPrint(1,"GiveWeapon", "Function failed at giving weapon \x22"+weapon+"\x22. Returning null.");
		return null;
	}


// Purpose: Meant for CTFPlayer.GetPassiveWeaponBySlot()
// Should fix passive weapons not being found in slots >7.
	if ( GivenWeapon.GetClassname() == "tf_wearable" )
		GivenWeapon.KeyValueFromString("classname","tf_wearable_vs");

// If our weapon has a custom model or custom arms, makes it custom.
	if ( !bit_ForceNotCustom
	 && (ItemID & (1 << 16))
	 || worldModel || viewModel || classarms
	 || bit_ForceCustom
	 || ItemDefinitionIndex_Override
	 || ( player.GetPlayerClass() != PlayerTFClass && PlayerTFClass != 0 ) )
	{
		IS_CUSTOM(GivenWeapon, true);	//marks our weapon as custom (which means "m_iItemIDHigh" bit 6 set)
	}
	else if ( bit_ForceNotCustom ) {
		IS_CUSTOM(GivenWeapon, false)	//removes the custom weapon bits
	}


// Modifies ammo if ammo types don't match
	if ( HasProp(GivenWeapon, "LocalWeaponData.m_iPrimaryAmmoType") && AmmoType != GivenWeapon.GetPrimaryAmmoType() ) {
		SetPropInt(GivenWeapon, "LocalWeaponData.m_iPrimaryAmmoType", AmmoType);
	}

// Purpose: Custom stats function
// Forced overrides parameters...
	if ( stats_function_Override ) {
		stats_function = stats_function_Override;
	}
// Runs custom weapon function if it exists
	if ( type( stats_function ) == "function" ) {
		stats_function(GivenWeapon, player);
		GivenWeapon.ReapplyProvision();
	}

// If our weapon does not use original stats, clear them.
	if ( bit_WipeAttributes ) {
		SetPropInt(GivenWeapon, "m_AttributeManager.m_Item.m_bOnlyIterateItemViewAttributes", 1);	// Removes all pre-existing stats of the weapon.
	}

// Purpose: Extra wearable ( if applicable )
	if ( Extra_Wearable ) {
		player.CreateCustomWearable("tf_wearable", Extra_Wearable, null, GivenWeapon);
	}

// Purpose: Extra wearable for viewmodels ( if applicable )
	if ( Extra_Wearable_VM ) {
		player.CreateCustomWearable("tf_wearable_vm", Extra_Wearable_VM, null, GivenWeapon);
	}

// Purpose: For updates weapon models
// for UpdateCustomWeapon()
	if ( HasProp(GivenWeapon, "m_iWorldModelIndex") && worldModel == null && viewModel == null ) {
		worldModel = GetPropInt(GivenWeapon, "m_iWorldModelIndex");
		viewModel = GetPropInt(GivenWeapon, "m_iWorldModelIndex");
	}
	else if ( worldModel == null && viewModel == null ) {
		worldModel = GetPropInt(GivenWeapon, "m_nModelIndex");
		viewModel = GetPropInt(GivenWeapon, "m_nModelIndex");
	}
	if ( worldModel == null && viewModel) {
		worldModel = viewModel;
	}
	else if ( worldModel && viewModel == null) {
		viewModel = worldModel;
	}


// Purpose: Finalize weapon.
// Adds AmmoFix wearable (to fix ammo), updates class arms/viewmodels, updates world weapon models, and adds viewmodel's Think script
	GTFW.UpdateAmmoFix(player, GivenWeapon,PlayerTFClass,AmmoType,ClipSize,MaxClipSize,AmmoReserve,MaxAmmoReserve);
	GTFW.UpdateArms(player, GivenWeapon, null);
	GTFW.UpdateCustomWeapon(player, GivenWeapon, worldModel, viewModel);
	GTFW.AddThinkToViewModel(player);


// Purpose: Switches to another weapon if active one was deleted
	if ( bit_AutoSwitch )
		player.SwitchToBest(GivenWeapon);


// Purpose: Announces weapon in text chat that it has been found
	if ( bit_AnnounceToChat ) player.AnnounceWeapon(GetItemID(GivenWeapon),AnnounceQuality,AnnouncePrefix,AnnounceHasString);

// Purpose: Saves weapon so resupply or dying won't remove the weapon
	if ( bit_SaveWeapon ) player.SaveLoadout(weapon);

// Purpose: Automatically registers your given weapon as custom
// *Only use when you need it.* There can only be 63 custom weapons using the same item definition index.
	if ( bit_AutoRegister )
		RegisterCustomWeapon(UniqueString(), weapon, PostWepFix_Override,stats_function_Override);

// Purpose: Echoes to console who received what weapon
	if ( type( weapon ) == "integer" )
		weapon = table.name;
	GTFW.DevPrint(0,"GiveWeapon", "Gave "+GTFW.GetNetName(player)+" item \x22"+weapon+"\x22!");

	return GivenWeapon
}


//-----------------------------------------------------------------------------
//Base for making weapons. Base weapon netprops compiled by ficool2.
//-----------------------------------------------------------------------------
::CTFPlayer.AddWeapon <- function(classname, itemindex, slot)
{
	GTFW.DevPrint(0,"AddWeapon",format("%s %i %i",classname, itemindex, slot))
	local ply = this;
	local weapon = SpawnEntityFromTable(classname, {
		origin = ply.GetOrigin(),
		angles = ply.GetAbsAngles(),
		effects = 129,
		TeamNum = ply.GetTeam(),
		CollisionGroup = 11,
		ltime = Time(),
	});

	SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemindex);
	SetPropInt(weapon, "m_AttributeManager.m_Item.m_iEntityLevel", 0);
	SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true);

	SetPropBool(weapon, "m_bClientSideAnimation", true);
	SetPropBool(weapon, "m_bClientSideFrameReset", true);

	SetPropBool(weapon, "m_bValidatedAttachedEntity", true);
	//SetPropInt(weapon, "m_AttributeManager.m_Item.m_bOnlyIterateItemViewAttributes", 1);	// Removes all pre-existing stats of the weapon.
	SetPropInt(weapon, "m_AttributeManager.m_iReapplyProvisionParity", 1);

	SetPropEntity(weapon, "m_hOwner", ply);
	weapon.SetOwner(ply);

// Seems without this, we can't hit Engineer objects!
	local solidFlags = GetPropInt(weapon, "m_Collision.m_usSolidFlags");
	SetPropInt(weapon, "m_Collision.m_usSolidFlags", solidFlags | Constants.FSolid.FSOLID_NOT_SOLID);

	solidFlags = GetPropInt(weapon, "m_Collision.m_usSolidFlags");
	SetPropInt(weapon, "m_Collision.m_usSolidFlags", solidFlags & ~(Constants.FSolid.FSOLID_TRIGGER));


	Entities.DispatchSpawn(weapon)	//Dispatches weapon into the world
	weapon.ReapplyProvision()	// then applies any body attributes back onto the player.


	SetPropEntityArray(ply, "m_hMyWeapons", weapon, slot);

	DoEntFire("!self", "SetParent", "!activator", 0, ply, weapon);

	itemindex = GetItemID(itemindex,ForceNotCustom)	//clears custom bits

//Engy Toolbox
	if ( classname == "tf_weapon_builder" )	//IDX 28
	{
		GTFW.DevPrint(0,"AddWeapon", format("Classname %s is updating ",classname));

		SetPropInt(weapon, "BuilderLocalData.m_iObjectType", 0)
		SetPropInt(weapon, "m_iSubType", 0)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.000", 1)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.001", 1)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.002", 1)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.003", 0)
	}
//Sappers
	if ( classname == "tf_weapon_sapper" ) // IDX 735 and 736 are classname tf_weapon_builder in items_game.txt; opted to change them to tf_weapon_sapper in tables.nut for QoL
	{
		GTFW.DevPrint(0,"AddWeapon", format("Classname %s %i is updating ",classname,itemindex));

		SetPropInt(weapon, "BuilderLocalData.m_iObjectType", 3)
		SetPropInt(weapon, "m_iSubType", 3)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.000", 0)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.001", 0)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.002", 0)
		SetPropInt(weapon, "BuilderLocalData.m_aBuildableObjectTypes.003", 1)
	}

	if ( classname.find("lunchbox") || classname.find("jar") ) {
		SetPropFloat(weapon, "LocalActiveTFWeaponData.m_flEffectBarRegenTime", Time() + 0.03);
		if ( !classname.find("_gas") ) {
			DoEntFire("!self","RunScriptCode","SetPropIntArray(self, `m_iAmmo`, 1, 5)",0.0,ply,ply)
			DoEntFire("!self","RunScriptCode","SetPropIntArray(self, `m_iAmmo`, 1, 4)",0.0,ply,ply)
		}
		else {
			DoEntFire("!self","RunScriptCode","SetPropIntArray(self, `m_iAmmo`, 0, 5)",0.0,ply,ply)
			DoEntFire("!self","RunScriptCode","SetPropIntArray(self, `m_iAmmo`, 0, 4)",0.0,ply,ply)
		}
	}

	GTFW.DevPrint(0,"AddWeapon", "Initialized \x22"+weapon+"\x22.")
	return weapon
}

//-----------------------------------------------------------------------------
// Purpose: Fixes ammo.
// There is an invisible tf_wearable that tracks ammo for custom weapons, and DisableWeapon/EnableWeapon
// Same goes for metal ammotype weapons like Widowmaker, Wrenches, PDAs etc
//-----------------------------------------------------------------------------
::GTFW.UpdateAmmoFix <- function(player,weapon,WepTFClass,AmmoType,ClipSize,MaxClipSize,AmmoReserve,MaxAmmoReserve)
{
// throw an error if the weapon doesn't use ammo
	if ( !HasProp(weapon, "LocalWeaponData.m_iPrimaryAmmoType") ) {
		GTFW.DevPrint(1,"UpdateAmmoFix", weapon+" is not compatible with ammo fix!");
		return weapon;
	}

// Define variables
	local AmmoFix;
	local aThreshold = 0;
	local aPerClass = 0;
	local FinalAmmoReserve;

	if ( AmmoType > TF_AMMO.NONE && MaxAmmoReserve >= 0 ) {

	//grabs handle for AmmoFix (a tf_wearable)
		AmmoFix = GTFW.GetAmmoFix(player);

	// Purpose: Updates primary ammo reserve
		if ( AmmoType == TF_AMMO.PRIMARY ) {
			aPerClass = MaxAmmoReserve == -1 ? TF_AMMO_PER_CLASS_PRIMARY[WepTFClass] : MaxAmmoReserve;
			aThreshold = TF_AMMO_PER_CLASS_PRIMARY[player.GetPlayerClass()];
			AmmoFix.AddAttribute("hidden primary max ammo bonus", aPerClass.tofloat() / aThreshold.tofloat(), -1);
		}
	// Purpose: Updates secondary ammo reserve
		else if ( AmmoType == TF_AMMO.SECONDARY ) {
			aPerClass = MaxAmmoReserve == -1 ? TF_AMMO_PER_CLASS_SECONDARY[WepTFClass] : MaxAmmoReserve;
			aThreshold = TF_AMMO_PER_CLASS_SECONDARY[player.GetPlayerClass()];
			weapon.AddAttribute("hidden secondary max ammo penalty", aPerClass.tofloat() / aThreshold.tofloat(), -1);
		}
	// Purpose: Updates GRENADES1 ammo reserve
		else if ( AmmoType == TF_AMMO.GRENADES1 ) {
			aThreshold = 1;
			AmmoFix.AddAttribute("maxammo grenades1 increased", (MaxAmmoReserve.tofloat() / aThreshold.tofloat()), -1);
		}
	// Purpose: Updates metal capacity
		else if ( AmmoType == TF_AMMO.METAL ) {
			aThreshold = 200;
			AmmoFix.AddAttribute("maxammo metal increased", (MaxAmmoReserve.tofloat() / aThreshold.tofloat()), -1);
		}

	// Purpose: Applies all attributes to player
		AmmoFix.ReapplyProvision();
	}

	FinalAmmoReserve = MaxAmmoReserve;
// Purpose: Sets ammo reserve, but only if reserve is different than reserveMax
	if ( MaxAmmoReserve != AmmoReserve )
		FinalAmmoReserve = AmmoReserve.tofloat();

// Purpose: Sets ammo reserve
	if ( AmmoType == TF_AMMO.METAL && EntityOutputs.HasAction(AmmoFix, "OnUser3") == false && player.GetPlayerClass() != Constants.ETFClass.TF_CLASS_ENGINEER ) {
		EntityOutputs.AddOutput(AmmoFix, "OnUser3", "", "", "", 0.0, -1);	//used to flag for Metal ammo so we don't update twice
		SetPropIntArray(player, "m_iAmmo", FinalAmmoReserve, TF_AMMO.METAL);
	}
	else {
		SetPropIntArray(player, "m_iAmmo", FinalAmmoReserve, AmmoType);
	}

	if ( AmmoType == TF_AMMO.METAL && EntityOutputs.HasAction(AmmoFix, "OnUser3") == false && player.GetPlayerClass() != Constants.ETFClass.TF_CLASS_ENGINEER ) {
		EntityOutputs.AddOutput(AmmoFix, "OnUser3", "", "", "", 0.0, -1);	//used to flag for Metal ammo so we don't update twice
		SetPropIntArray(player, "m_iAmmo", AmmoReserve, TF_AMMO.METAL);
	}
	else {
		SetPropIntArray(player, "m_iAmmo", AmmoReserve, AmmoType);
	}
	// Purpose: Sets ammo clip
	// It seems like having both helps account for weapons that don't use the atomic upgrade, but atomic seems to supersede the %clipsize penalty for what ever reason
	if ( MaxClipSize >= 0 ) {
		if ( (MaxClipSize.tofloat() / weapon.GetMaxClip1().tofloat()) != 1 ) {
			weapon.AddAttribute("clip size upgrade atomic", 0 - (weapon.GetMaxClip1() - MaxClipSize), -1);
			weapon.AddAttribute("clip size penalty HIDDEN", MaxClipSize.tofloat() / weapon.GetMaxClip1().tofloat(), -1);
		}
		weapon.SetClip1(MaxClipSize);
	}
	if ( MaxClipSize != ClipSize ) {
		weapon.SetClip1(ClipSize);
	}

	return weapon
}

//-----------------------------------------------------------------------------
// Purpose: Creates an invisible tf_wearable with attributes that adjust ammo reserve
// First checks if it exists in player scope, if not, creates the invisible tf_wearable.
//-----------------------------------------------------------------------------
::GTFW.GetAmmoFix <- function(player=null) {
	if ( player && player.IsValid() && player.GetClassname() != "player" ) {
		GTFW.DevPrint(1,"GTFW.GetAmmoFix", "Function failed. Param 1 not a player. Returning null.");
		return null;
	}

	local AmmoFix;
	if ( player.ValidateScriptScope() ) {

		local plyScope = player.GetScriptScope();

		if ( !( "AMMOFIX" in plyScope ) ) {
			AmmoFix = player.CreateCustomWearable("tf_wearable", "models/empty.mdl");

			GTFW.DevPrint(0,"CreateAmmoFix", "Created ammofix for " + GTFW.GetNetName(player));

			plyScope["AMMOFIX"] <- AmmoFix;
		}
		GTFW.DevPrint(0,"GTFW.GetAmmoFix", "Returning AmmoFix entity in script.");
		return plyScope["AMMOFIX"];
	}
	GTFW.DevPrint(1,"GTFW.GetAmmoFix", "Function failed. Couldn't find player. Returning null.");
	return null;
}


//-----------------------------------------------------------------------------
// Purpose: Used to update viewmodel arms in GiveWeapon()
//-----------------------------------------------------------------------------
::GTFW.UpdateArms <- function(player, givenwep=null, force_class_arms=null)
{
// throw error if not using VM fix
	if ( !CVAR_USE_VIEWMODEL_FIX ) {
		GTFW.DevPrint(0,"UpdateArms", "CVAR_USE_VIEWMODEL_FIX = false. UpdateArms cancelled.")
		return null
	}
// throw error if weapon not compatible with class arms
// (tf_wearable and other passive items don't have "m_iPrimaryAmmoType" netprop)
	if ( !HasProp(givenwep, "LocalWeaponData.m_iPrimaryAmmoType") ) {
		GTFW.DevPrint(1,"UpdateArms", givenwep+" is not a compatible weapon!")
		return givenwep
	}

// Purpose: This is the special VM fix.
// it creates class arms that bonemerge with VM


// Deletes pre-existing bonemerged class arms model parented to the main_viewmodel
	local plyScope;

	if ( player.ValidateScriptScope() ) {

		plyScope = player.GetScriptScope();

		if ( "classarms" in plyScope ) {

			GTFW.DevPrint(0,"UpdateArms", "Deleted arms " + plyScope["classarms"])

			local arms = plyScope["classarms"]
			if ( arms && arms.IsValid() ) {
				arms.Kill()
			}
			delete plyScope["classarms"]
		}
	}

// Adds a class arms model if nothing has parented to the main_viewmodel
	if ( !( "classarms" in plyScope ) ) {
		local main_viewmodel = GetPropEntity(player, "m_hViewModel")
		local classarms_model = player.CreateCustomWearable("tf_wearable_vm", GTFW_MODEL_ARMS[player.GetPlayerClass()], null, main_viewmodel)

		GTFW.DevPrint(0,"UpdateArms", "Created arms " + classarms_model)

	// Purpose: Puts bonemerged class arms model in player scope for easy tracking
		plyScope["classarms"] <- classarms_model

	}

// Purpose: Writes to the scope above, which keep the class arms the weapon needs to update to when switched to.
	for (local i = 0; i < GLOBAL_WEAPON_COUNT; i++)
	{
		local wep = GetPropEntityArray(player, "m_hMyWeapons", i)

		if ( wep == null ) continue
			local wepID = GetItemID(wep);
			local wepID_Clean = GetItemID(wep,ForceNotCustom);	//clears custom bits to allow us to use custom watches/PDAs
			local table = player.GetWeaponTable(wepID);

			if ( table && wep == givenwep || force_class_arms ) {
				local model;

				if ( force_class_arms )
					model = force_class_arms;
				else if ( table.classname == "tf_weapon_pda_spy" )
					model = "models/weapons/v_models/v_pda_spy.mdl";
				else if ( table.classname == "tf_weapon_invis" && wepID_Clean == 30 )
					model = "models/weapons/v_models/v_watch_spy.mdl";
				else if ( table.classname == "tf_weapon_invis" && wepID_Clean == 59 )
					model = "models/weapons/v_models/v_watch_pocket_spy.mdl";
				else if ( table.classname == "tf_weapon_invis" && wepID_Clean == 60 )
					model = "models/weapons/v_models/v_watch_leather_spy.mdl";
				else if ( table.classname == "tf_weapon_invis" && wepID_Clean == 297 )
					model = "models/weapons/v_models/v_ttg_watch_spy.mdl";
				else if ( table.classname == "tf_weapon_invis" && wepID_Clean == 947 )
					model = "models/workshop_partner/weapons/v_models/v_hm_watch/v_hm_watch.mdl";
				else if ( table.classname == "tf_weapon_robot_arm" )
					model = GTFW_MODEL_ARMS[10];
				else if ( table.classArms )
					model = table.classArms;
				else if ( table.tf_class == 0 || player.GetPlayerClass() == table.tf_class )
					model = GTFW_MODEL_ARMS[player.GetPlayerClass()];
				else
					model = GTFW_MODEL_ARMS[table.tf_class];

				PrecacheModel( model );
				local modelIndex = GetModelIndex( model );;
				wep.SetModelSimple(model);
				wep.SetCustomViewModelModelIndex(modelIndex);
				NetProps.SetPropInt(wep, "m_iViewModelIndex", modelIndex);

				GTFW.DevPrint(0,"UpdateArms", "Updated model for " + wep);

				break;
			}
	}
}


//-----------------------------------------------------------------------------
//	Purpose: Updates all weapon models for custom/unintended for tfclass weapons
//	This function works with AddThinkToViewModel() to make weapons visible/invisible as needed.
//   Things like weapon switching, taunting, etc, will make the replaced weapon invisible and make the vscript custom weapon visible.
//-----------------------------------------------------------------------------

::GTFW.UpdateCustomWeapon <- function(player, weapon, worldModel, viewModel)
{
// Throw error if param player isn't valid
	if ( type( player ) != "instance" || ( player && player.IsValid() && player.GetClassname() != "player" ) ) {
		GTFW.DevPrint(1,"UpdateCustomWeapon", "Function failed. Parameter 1 is not a player. Returning null.");
		return null;
	}
	if ( type( weapon ) != "instance" ) {
		GTFW.DevPrint(1,"UpdateCustomWeapon", "Function failed. Parameter 2 is not a weapon. Returning null.");
		return null;
	}
	if ( type( worldModel ) != "integer" && type( worldModel ) != "string" ) {
		GTFW.DevPrint(1,"UpdateCustomWeapon", "Function failed. Parameter 3 is not an int or string. Returning null.");
		return null;
	}
	if ( type( viewModel ) != "integer" && type( viewModel ) != "string" ) {
		GTFW.DevPrint(1,"UpdateCustomWeapon", "Function failed. Parameter 4 is not an int or string. Returning null.");
		return null;
	}


// Define variables
	local hWearable;
	local WepC = weapon.GetClassname();

// Purpose: Only update if the weapon is custom, or a demoshield
// Deletes custom weapon models for ViewModel, then recreates them
	if ( IS_CUSTOM(weapon)					// If weapon is custom
	 || WepC == "tf_wearable_demoshield" )	// or a demoshield
	{
		GTFW.DevPrint(0,"UpdateCustomWeapon", "Updating \x22"+weapon+"\x22.");

		if ( WepC == "tf_wearable_demoshield" ) {
			local main_viewmodel = GetPropEntity(player, "m_hViewModel");
			hWearable = player.CreateCustomWearable("tf_wearable_vm", viewModel, null, main_viewmodel)
		}
		else if ( viewModel != "models/empty.mdl" ) {
			hWearable = player.CreateCustomWearable("tf_wearable_vm", viewModel, null, weapon)
		}


	// Purpose: Overrides thirdperson model if it's a passive item

		if ( SearchPassiveItems.find(WepC) ) {
			if ( type( worldModel ) == "string" )
				worldModel = PrecacheModel(worldModel);	//returns modelindex value
			SetPropInt(weapon, "m_nModelIndexOverrides", worldModel);
		}
		else if ( worldModel != "models/empty.mdl" ) {
			weapon.ValidateScriptScope();
			local wepScope = weapon.GetScriptScope();
			wepScope.worldModel <- player.CreateCustomWearable("tf_wearable", worldModel, null, weapon);
			SetPropEntity(wepScope.worldModel, "m_hWeaponAssociatedWith", weapon)
		}
	}

	return weapon
}


//-----------------------------------------------------------------------------
// Purpose: Updates viewmodel think script.
// Clears and updates the viewmodel think script for weapon switching, enabling/disabling visibility of custom weapons.
// Due to viewmodel issues with custom weapons, thirdperson model is set an override ("m_nModelIndexOverrides") only during taunting and ForcedTauntCam 1.
//   It is then reverted back after thirdperson action has taken place.
//-----------------------------------------------------------------------------
::GTFW.AddThinkToViewModel <- function(player)
{
	if ( !CVAR_USE_VIEWMODEL_FIX ) {
		GTFW.DevPrint(0,"AddThinkToViewModel", "CVAR_USE_VIEWMODEL_FIX set. Ignoring function.");
		return;
	}

	GTFW.DevPrint(0,"AddThinkToViewModel", "Function started.");

	local main_viewmodel = GetPropEntity(player, "m_hViewModel");
	local wep, wepScope, DisableDrawQueue;
	local WEPTAUNTFIX = true;
	local THIRDPERSONFIX = true;

	local last_active_building;

	local playerscope;
	player.ValidateScriptScope();
	playerscope = player.GetScriptScope();

	const THINK_VMFIX_DELAY = 0.1;

// Think script itself.
// Reads from several tables to find weapon's class arms.
	if( main_viewmodel.ValidateScriptScope() )
	{
		local entscriptname = "THINK_VM_FIX_"+player.entindex().tostring();
		local entityscript = main_viewmodel.GetScriptScope();
		entityscript[entscriptname] <- function()
		{
		// Fixes Thirdperson modes (taunts, "SetForcedTauntCam")
		// VScript created weapons are invisible if they were created while the player wasn't in third person
		// Changing their m_bInitialized state fixes this
			if ( ( WEPTAUNTFIX && player.InCond(7) )
			 || ( WEPTAUNTFIX && GetPropInt(player,"m_nForceTauntCam") ) ) {
				WEPTAUNTFIX = false;

				if ( IS_CUSTOM(wep) )
				{
					wepScope = wep;
					wepScope = wepScope.ValidateScriptScope();
					wepScope = wep.GetScriptScope();
                    if (wepScope != null && "worldModel" in wepScope)
                    {
					    local worldModel = wepScope.worldModel;
					    SetPropInt(wep, "m_nModelIndexOverrides", GetModelIndex(worldModel.GetModelName() ) );
					    worldModel.DisableDraw()
                    }
					wep = null
				}

				if ( GetPropInt(player,"m_nForceTauntCam") ) {
					WEPTAUNTFIX = true;
					return;
				}

			// These make the wearables reappear if they were invisible before.
				local item = player.FirstMoveChild()
		//		local plyModelScale = player.GetModelScale()

				for ( local i = 0; i < 21; i++ )	//21 is a random number; can be anything
				{
					if ( item && item.IsValid()
					 && item.GetClassname().find("weapon") == null ) {	//Fixes sappers crashing due to non-precached model
		//				item.SetModelScale(plyModelScale, 0)
						SetPropInt(item, "m_AttributeManager.m_Item.m_bInitialized", 0);
						EntFireByHandle(item, "RunScriptCode", "SetPropInt(self, \x22m_AttributeManager.m_Item.m_bInitialized\x22, 1)", 0.1, item, item);
					}

					if ( item && item.IsValid() ) {
						item = item.NextMovePeer();	//defines next child parented to the player. Repeats
					}
					else break;
				}
			}
		// updates weapons' visibility based on which one is being used
			else if ( !player.InCond(7)
			 && player.GetActiveWeapon()
			 && player.GetActiveWeapon() != wep
			 || ( HasProp(wep, "m_hObjectBeingBuilt") && GetPropEntity(wep, "m_hObjectBeingBuilt") != last_active_building ) )
			{
				wep = player.GetActiveWeapon();

				wepScope = wep;
				wepScope = wepScope.ValidateScriptScope();
				wepScope = wep.GetScriptScope();

				WEPTAUNTFIX = true;

			// Fixes Engineer's Toolbox by setting last building instead of last weapon
				if ( HasProp(wep, "m_hObjectBeingBuilt") )
					last_active_building = GetPropEntity(wep, "m_hObjectBeingBuilt");

			//Checks for custom weapon
			//Passing as a custom weapon means it updates the weapon visibility, disables the viewmodel (base classarms + base weapon)

				if ( IS_CUSTOM(wep)
				 && wep.GetClassname() != "tf_weapon_fists" )
				{
					main_viewmodel.DisableDraw()		//makes firstperson weapon invisible (as well as other's class arms from the other class)
					WEPTAUNTFIX = true

					SetPropInt(wep, "m_nModelIndexOverrides", 0 );

					local worldModel = wepScope.worldModel
					worldModel.EnableDraw()
					DoEntFire("!self", "RunScriptCode", "self.EnableDraw()", 0.01, null, worldModel)	//using delay here purposely. Won't update b/c thinks too fast!!
				}
			//Draws any models that were not rendered before by changing their m_bInitialized netprop
				local item = player.FirstMoveChild()
	//			local plyModelScale = player.GetModelScale()

				for ( local i = 0; i < 21; i++ )	//21 is a random number; can be anything
				{
					if ( item && item.IsValid()
					 && item.GetClassname().find("weapon") == null ) {	//Fixes sappers crashing due to non-precached model
	//					item.SetModelScale(plyModelScale, 0)
						SetPropInt(item, "m_AttributeManager.m_Item.m_bInitialized", 0);
						EntFireByHandle(item, "RunScriptCode", "SetPropInt(self, \x22m_AttributeManager.m_Item.m_bInitialized\x22, 1)", 0.0, item, item);
					}

					if ( item && item.IsValid() ) {
						item = item.NextMovePeer();	//defines next child parented to the player. Repeats
					}
					else break;
				}

			// grabs bonemerged class arms model if it exists
				if ( "classarms" in playerscope ) {
					local classarms = playerscope["classarms"];

					if ( classarms && classarms.IsValid() ) {
				// if ShortCircuit, disable the class arms' visibility
						if ( wep && wep.IsValid()
                            && (wep.GetClassname() == "tf_weapon_mechanical_arm" || ("hide_base_arms" in playerscope)))  { // Short Circuit
							classarms.DisableDraw();
						}
						else {
							classarms.EnableDraw();
						}
					}
				}
			}
			return THINK_VMFIX_DELAY;
		}
		AddThinkToEnt(main_viewmodel, entscriptname);	//adds think script
		GTFW.DevPrint(0,"AddThinkToViewModel", "Success! Added think script to "+main_viewmodel);
	}
}

