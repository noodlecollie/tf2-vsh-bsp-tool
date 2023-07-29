//-----------------------------------------------------------------------------
// Purpose: Creates a tf_wearable
//-----------------------------------------------------------------------------
::CTFPlayer.CreateCustomWearable <- function(wearable_classname="tf_wearable",item_modelindex=null,itemID=null,weapon=null)
{
	GTFW.DevPrint(0,"CreateCustomWearable", "Making \x22"+wearable_classname+"\x22 for "+weapon);

	local ply = this;
	local item_modelstring;
	local main_viewmodel = GetPropEntity(ply, "m_hViewModel");
	
// Defining which entity should be created
	//Only these classnames are valid:
	switch ( wearable_classname ) {
		case "tf_wearable_vm" : break;
		case "tf_wearable_demoshield" : break;
		case "tf_wearable_razorback" : break;
		case "tf_weapon_parachute" : break;
		case "tf_weapon_parachute_primary" : break;
		case "tf_weapon_parachute_secondary" : break;
		default : wearable_classname = "tf_wearable"; break;
	}
	if ( item_modelindex == null && type( itemID ) == "integer" ) {
		local dummyID = itemID;
		for ( local bit = 16; bit <= 21; bit++ ) {
			dummyID = dummyID & ~( 1 << bit );
		}
		switch ( dummyID ) {
			case 131 : item_modelindex = "models/weapons/c_models/c_targe/c_targe.mdl"; break;	//Chargin' Targe
			case 406 : item_modelindex = "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield.mdl"; break;	//Splendid Screen
			case 1099 : item_modelindex = "models/workshop/weapons/c_models/c_wheel_shield/c_wheel_shield.mdl"; break;	//Tide Turner
			case 1144 : item_modelindex = "models/weapons/c_models/c_targe/c_targe_xmas.mdl"; break;	//Festive Chargin' Targe
		}
	}

// Precaches weapon if string
	if ( type( item_modelindex ) == "string" )
	{
		PrecacheModel(item_modelindex);
		item_modelstring = item_modelindex
		item_modelindex = GetModelIndex(item_modelindex);
	}
	if ( ply.HasGunslinger() && wearable_classname == "tf_wearable_vm" && weapon == main_viewmodel ) {
		
		GTFW.DevPrint(0,"CreateCustomWearable", "Creating VM Gunslinger arms.");
		
		PrecacheModel(GTFW_MODEL_ARMS[10])
		item_modelindex = GetModelIndex(GTFW_MODEL_ARMS[10]);
	}
	
	
	local hWearable = Entities.CreateByClassname(wearable_classname);

// our properties. Taken from source code for Super Zombie Fortress + SCP Secret Fortress
	hWearable.SetAbsOrigin(ply.GetLocalOrigin());
	hWearable.SetAbsAngles(ply.GetLocalAngles());
	SetPropBool(hWearable, "m_bClientSideAnimation", true);
	SetPropInt(hWearable, "m_iTeamNum", ply.GetTeam());
	SetPropInt(hWearable, "m_Collision.m_usSolidFlags", Constants.FSolid.FSOLID_NOT_SOLID);
	SetPropInt(hWearable, "m_CollisionGroup", 11);
	SetPropInt(hWearable, "m_fEffects", 129);	//1 and 128 bitmasks both bone merge to player model
	
	SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 65535);
	if ( type( itemID ) == "integer" ) {
		SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID);
	}
	else if ( type( item_modelindex ) == "integer" ) {
		SetPropInt(hWearable, "m_nModelIndex", item_modelindex);
	}
	
	//SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iEntityQuality", 0);	//doesn't work due to vscript security reasons
	SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iEntityLevel", 1);
	
	SetPropBool(hWearable, "m_bValidatedAttachedEntity", true);
	SetPropInt(hWearable, "m_AttributeManager.m_iReapplyProvisionParity", 3);
	SetPropBool(hWearable, "m_AttributeManager.m_Item.m_bInitialized", true)	//Seems to bug with upgrades stations / MvM
	SetPropBool(hWearable, "m_AttributeManager.m_Item.m_bOnlyIterateItemViewAttributes", false);
	
	SetPropEntity(hWearable, "m_hOwnerEntity", ply);
	hWearable.SetOwner(ply);
	
//We associate the weapon via netprops "m_hExtraWearableViewModel" and "m_hExtraWearable" for cleanup using KillWepAll()
	if ( weapon && weapon != main_viewmodel ) {
		if ( wearable_classname == "tf_wearable_vm" ) {
			SetPropEntity(hWearable, "m_hWeaponAssociatedWith", weapon);
			SetPropEntity(weapon, "m_hExtraWearableViewModel", hWearable);
		}
		else if ( wearable_classname == "tf_wearable" )
			SetPropEntity(weapon, "m_hExtraWearable", hWearable);
	}
	
//Dispatch Spawn && stats reapply
	Entities.DispatchSpawn(hWearable);	//Spawns ent into world
	hWearable.ReapplyProvision();		//reapplies any attributes from weapon onto the player
	
	if ( wearable_classname == "tf_wearable_vm" ) {
	//This ent relies on being parented to the viewmodel of the player. Otherwise it won't show up!
	//However, it shows for all weapons. For some reason it can't show up for just one...? Needs more testing.
		DoEntFire("!self", "SetParent", "!activator", 0, main_viewmodel, hWearable);	
		ply.EquipWearableViewModel(hWearable);
	}
	else {
		DoEntFire("!self", "SetParent", "!activator", 0, ply, hWearable);
	}
	
	if ( item_modelstring )
		hWearable.SetModelSimple(item_modelstring);
	
	hWearable.KeyValueFromString("targetname",format("tf_wearable_vs_%d_%d",ply.entindex(),GetItemID(hWearable)));
	
	GTFW.DevPrint(0,"CreateCustomWearable", "Created "+"\x22"+hWearable.GetClassname()+"\x22 ("+hWearable.GetModelName()+")");

	return hWearable;
}

/*
// Yaki is trying to fix viewmodel anim seq from breaking -may11,23
::CTFPlayer.superFunc <- function(wearable_classname="tf_wearable",item_modelindex=null,itemID=null,weapon=null)
{
	if ( type( item_modelindex ) == "string" )
	{
		PrecacheModel(item_modelindex);
		item_modelindex = GetModelIndex(item_modelindex);
	}
	local hWearable = Entities.CreateByClassname(wearable_classname);
	NetProps.SetPropInt(hWearable, "m_nModelIndex", item_modelindex);
	NetProps.SetPropBool(hWearable, "m_bValidatedAttachedEntity", true);
	NetProps.SetPropEntity(hWearable, "m_hWeaponAssociatedWith", weapon);
	NetProps.SetPropEntity(weapon, "m_hExtraWearableViewModel", hWearable);
	Entities.DispatchSpawn(hWearable);	//Spawns ent into world
	this.EquipWearableViewModel(hWearable);
	return hWearable;
}*/