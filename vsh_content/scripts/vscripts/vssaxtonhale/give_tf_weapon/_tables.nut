//-----------------------------------------------------------------------------
// This file holds all the data tables for every weapon in TF2.
//-----------------------------------------------------------------------------

enum TF_WEAPONSLOTS
{
  PRIMARY = 0,
  SECONDARY = 1,
  MELEE = 2,
  PDA = 3,
  PDA2 = 4,
  INVIS_WATCH = 4,
  TOOLBOX = 5,
  MISC = 6,

  SLOT0 = 0.0,
  SLOT1 = 1,
  SLOT2 = 2,
  SLOT3 = 3,
  SLOT4 = 4,
  SLOT5 = 5,
  SLOT6 = 6,
}

enum TF_AMMO
{
	NONE = 0,
	PRIMARY = 1,
	SECONDARY = 2,
	METAL = 3,
	GRENADES1 = 4, // e.g. Sandman, Jarate, Sandvich
	GRENADES2 = 5, // e.g. Mad Milk, Bonk,
	GRENADES3 = 6, // e.g. Spells
}

enum GTFW_ARMS
{
	SCOUT	=	"models/weapons/c_models/c_scout_arms.mdl",
	SNIPER	=	"models/weapons/c_models/c_sniper_arms.mdl",
	SOLDIER	=	"models/weapons/c_models/c_soldier_arms.mdl",
	DEMO	=	"models/weapons/c_models/c_demo_arms.mdl",
	MEDIC	=	"models/weapons/c_models/c_medic_arms.mdl",
	HEAVY	=	"models/weapons/c_models/c_heavy_arms.mdl",
	PYRO	=	"models/weapons/c_models/c_pyro_arms.mdl",
	SPY		=	"models/weapons/c_models/c_spy_arms.mdl",
	ENGINEER=	"models/weapons/c_models/c_engineer_arms.mdl",
	CIVILIAN=	"models/weapons/c_models/c_engineer_gunslinger.mdl",
}

::GTFW_MODEL_ARMS <-
[
	"models/weapons/c_models/c_medic_arms.mdl", //dummy
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/weapons/c_models/c_soldier_arms.mdl",
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl",
	"models/weapons/c_models/c_engineer_gunslinger.mdl",	//CIVILIAN/Gunslinger
]

//Order based on internal constants of ETFClass
// Use: TF_AMMO_PER_CLASS_PRIMARY[hPlayer.GetPlayerClass()]
::TF_AMMO_PER_CLASS_PRIMARY <- [
	0,
	32,	//Scout
	25,	//Sniper
	20	//Soldier
	16,	//Demo
	150	//Medic
	200,	//Heavy
	200,	//Pyro
	20,	//Spy
	32,	//Engineer
	0,	//Civilian
]

//Order based on internal constants of ETFClass
// Use: TF_AMMO_PER_CLASS_SECONDARY[hPlayer.GetPlayerClass()]
::TF_AMMO_PER_CLASS_SECONDARY <- [
	0,
	36,	//Scout
	75,	//Sniper
	32,	//Soldier
	24,	//Demo
	150,	//Medic
	32,	//Heavy
	32,	//Pyro
	24,	//Spy
	200,	//Engineer
	0,	//Civilian
]


//Order based on internal constants of ETFClass
// Use: GTFW_Saxxy[hPlayer.GetPlayerClass()]
::GTFW_Saxxy <-
[
	"fireaxe",	//MULTI-CLASS
	"bat",		//SCOUT
	"club",		//SNIPER
	"shovel",	//SOLDIER
	"bottle",	//DEMO
	"bonesaw",	//MEDIC
	"fireaxe",	//HEAVY
	"fireaxe",	//PYRO
	"knife",	//SPY
	"wrench",	//ENGINEER
	"bat",		//CIVILIAN
]
//-----------------------------------------------------------------------------
//	Purpose: TF_WEAPONS_BASE is used for all weapons that are processed by `CTFPlayer.ReturnWeaponTable()`
//-----------------------------------------------------------------------------
class ::TF_WEAPONS_BASE
{
	tf_class	= null;
	slot		= null;
	classname	= null;
	itemID		= null;
	name		= null;
	ammoType	= null;
	clipSize	= null;
	clipSizeMax	= null;
	reserve		= null;
	reserveMax	= null;
	worldModel	= null;
	viewModel	= null;
	wearable	= null;
	wearable_vm	= null;
	gw_props	= null;
	func		= null;
	classArms	= null;
	PostWepFix	= null;
	announce_quality	= null;
	announce_prefix		= null;
	announce_has_string	= null;

	constructor(TF_class, TF_slot, weapon, id, itemString, ammoslot, prim, maxprim, resv, maxresv, world_model, view_model, extra_wearable, extra_wearable_vm, props_ex, Function, class_armz, postwepfix, Aquality, Aprefix, Ahas_string)
	{
		tf_class	= TF_class;
		slot		= TF_slot;
		classname	= weapon;
		itemID		= id;
		name		= itemString;
		ammoType	= ammoslot;
		clipSize	= prim;
		clipSizeMax	= maxprim;
		reserve		= resv;
		reserveMax	= maxresv;
		worldModel	= world_model;
		viewModel	= view_model;
		wearable	= extra_wearable;
		wearable_vm	= extra_wearable_vm;
		gw_props	= props_ex;
		func		= Function;
		classArms	= class_armz;
		PostWepFix	= postwepfix;

		announce_quality	= Aquality;
		announce_prefix		= Aprefix;
		announce_has_string	= Ahas_string;
	}
}
//-----------------------------------------------------------------------------
//	Purpose: Used for all weapons under `TF_WEAPONS_ALL` array.
//-----------------------------------------------------------------------------
class TF_WEAPONS
{
	tf_class	= null;
	slot		= null;
	classname	= null;
	itemID		= null;
	name		= null;
	name2		= null;
	ammoType	= null;
	clipSize	= null;
	reserve		= null;
	wearable	= null;

	constructor(TF_class, TF_slot, weapon, id, item=null, item2=null, ammoslot=-1, prim=-1, sec=-1, extra_wearable=null)
	{
		tf_class	= TF_class;
		slot		= TF_slot;
		classname	= weapon;
		itemID		= id;
		name		= item;
		name2		= item2;
		ammoType	= ammoslot;
		clipSize	= prim;
		reserve		= sec;
		wearable	= extra_wearable;
	}
}

//-----------------------------------------------------------------------------
//	Purpose: Used for all weapons under `TF_WEAPONS_ALL_WARPAINTSnBOTKILLERS` array.
//-----------------------------------------------------------------------------
class TF_WEAPONS_RESKIN
{
	tf_class	= null;
	slot		= null;
	classname	= null;
	name		= null;
	itemID		= null;
	itemID2 	= null;
	itemID3		= null;
	itemID4		= null;
	itemID5 	= null;
	itemID6 	= null;
	itemID7 	= null;
	itemID8 	= null;
	itemID9 	= null;
	itemID10 	= null;
	itemID11	= null;
	itemID12 	= null;
	itemID13 	= null;
	itemID14 	= null;
	itemID15 	= null;

	ammoType	= null;
	clipSize	= null;
	reserve		= null;
	wearable	= null;

	constructor(TF_class, TF_slot, weapon, namae, ammoslot, prim, sec, id=null,id2=null,id3=null,id4=null,id5=null,id6=null,id7=null,id8=null,id9=null,id10=null,id11=null,id12=null,id13=null,id14=null,id15=null)
	{
		tf_class	= TF_class;
		slot		= TF_slot;
		classname	= weapon;
		name		= namae;
		itemID		= id;
		itemID2		= id2;
		itemID3		= id3;
		itemID4		= id4;
		itemID5		= id5;
		itemID6		= id6;
		itemID7		= id7;
		itemID8		= id8;
		itemID9		= id9;
		itemID10	= id10;
		itemID11	= id11;
		itemID12	= id12;
		itemID13	= id13;
		itemID14	= id14;
		itemID15	= id15;

		ammoType	= ammoslot;
		clipSize		= prim;
		reserve		= sec;
	}
}

//-----------------------------------------------------------------------------
//	Purpose: Used for all weapons under `TF_CUSTOM_WEAPONS_REGISTRY` table.
//-----------------------------------------------------------------------------
::TF_CUSTOM_WEPS <- class
{
	name		= null;
	classname	= null;
	slot		= null;
	tf_class	= null;
	itemID		= null;
	gw_props	= null;
	func		= null;
	classArms	= null;
	ammoType	= null;
	clipSize	= null;
	clipSizeMax	= null;
	reserve		= null;
	reserveMax	= null;
	worldModel	= null;
	viewModel	= null;
	wearable	= null;
	wearable_vm	= null;
	PostWepFix	= null;
	announce_quality	= null;
	announce_prefix		= null;
	announce_has_string	= null;

	constructor(itemString, weapon, TF_class=0, Slot=2, id=65535, props_ex=null, Function=null, classarms=null, ammoslot=-1, prim=-1, maxprim=-1, sec=-1, maxsec=-1, world_model=null, view_model=null, extra_wearable=null, extra_wearable_vm=null, postwepfix=null, Aquality=20, Aprefix=null, Ahas_string=null)
	{
		name		= itemString;
		classname	= weapon;
		tf_class	= TF_class;
		slot		= Slot;
		itemID		= id;
		gw_props	= props_ex;
		func		= Function;
		classArms	= classarms;
		ammoType	= ammoslot;
		clipSize	= prim;
		clipSizeMax	= maxprim;
		reserve		= sec;
		reserveMax	= maxsec;
		worldModel	= world_model;
		viewModel	= view_model;
		wearable	= extra_wearable;
		wearable_vm	= extra_wearable_vm;
		PostWepFix	= postwepfix;

		announce_quality	= Aquality;
		announce_prefix		= Aprefix;
		announce_has_string	= Ahas_string;
	}
}



//-----------------------------------------------------------------------------
//	Tables for all weapons in TF2 (excluding reskins/festives)
//-----------------------------------------------------------------------------
::TF_WEAPONS_ALL <- [
//-----------------------------------------------------------------------------
// Body slot
//-----------------------------------------------------------------------------
	TF_WEAPONS(0, 7, "parachute", 1101, "B.A.S.E. Jumper", "Parachute", TF_AMMO.NONE, -1, -1, "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_pack.mdl")
	TF_WEAPONS(0, 7, "tf_wearable", 65535)

//-----------------------------------------------------------------------------
// All-Class
//-----------------------------------------------------------------------------
	TF_WEAPONS(0, 1, "shotgun", 199, "Shotgun", null, TF_AMMO.SECONDARY, 6, 32)
	TF_WEAPONS(0, 1, "shotgun", 415, "Reserve Shooter", null, TF_AMMO.SECONDARY, 4, 32)
	TF_WEAPONS(0, 1, "shotgun", 1153, "Panic Attack", null, TF_AMMO.SECONDARY, 6, 32)
	TF_WEAPONS(0, 1, "shotgun", 425, "All-Class Family Business", null, TF_AMMO.SECONDARY, 8, 32)
	TF_WEAPONS(0, 1, "shotgun", 141, "All-Class Frontier Justice", "All-Class FJ", TF_AMMO.SECONDARY, 3, 32)
	TF_WEAPONS(0, 1, "shotgun", 527, "All-Class Widowmaker", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(0, 1, "pistol", 22, "Pistol", null, TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(0, 1, "pistol", 209, "Pistol", "Unique Pistol", TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(0, 1, "pistol", 30666, "C.A.P.P.E.R.", "CAPPER", TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(0, 1, "pistol", 160, "Lugermorph", "Luger", TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(0, 1, "pistol", 294, "Vintage Lugermorph", "Vintage Luger", TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(0, 1, "pistol", 449, "All-Class Winger", null, TF_AMMO.SECONDARY, 5, 36)
	TF_WEAPONS(0, 1, "pistol", 773, "All-Class Pretty Boy's Pocket Pistol", "All-Class PBPP", TF_AMMO.SECONDARY, 9, 36)
	TF_WEAPONS(0, 6, "spellbook", 1070, "Basic Spellbook", null, TF_AMMO.GRENADES3)
	TF_WEAPONS(0, 6, "spellbook", 1069, "Fancy Spellbook", "Halloween Spellbook", TF_AMMO.GRENADES3, -1, -1, "models/player/items/all_class/hwn_spellbook_complete.mdl")
	TF_WEAPONS(0, 6, "spellbook", 1132, "Spellbook Magazine", null, TF_AMMO.GRENADES3)
	TF_WEAPONS(0, 2, "saxxy", 264, "Frying Pan", "Pan")
	TF_WEAPONS(0, 2, "saxxy", 423, "Saxxy")
	TF_WEAPONS(0, 2, "saxxy", 474, "Conscientious Objector", "Sign")
	TF_WEAPONS(0, 2, "saxxy", 880, "Freedom Staff")
	TF_WEAPONS(0, 2, "saxxy", 939, "Bat Outta Hell")
	TF_WEAPONS(0, 2, "saxxy", 954, "Memory Maker")
	TF_WEAPONS(0, 2, "saxxy", 1013, "Ham Shank", "Ham")
	TF_WEAPONS(0, 2, "saxxy", 1071, "Gold Frying Pan", "Gold Pan")
	TF_WEAPONS(0, 2, "saxxy", 1127, "Crossing Guard")
	TF_WEAPONS(0, 2, "saxxy", 1123, "Necro Smasher", "Smasher")
	TF_WEAPONS(0, 2, "saxxy", 30758, "Prinny Machete", "Machete")
	TF_WEAPONS(0, 6, "grapplinghook", 1152, "Grappling Hook")

//-----------------------------------------------------------------------------
// Scout
//-----------------------------------------------------------------------------
	TF_WEAPONS(1, 0, "scattergun", 13, "Scattergun", "Scatter Gun", TF_AMMO.PRIMARY, 6, 32)
	TF_WEAPONS(1, 0, "scattergun", 200, "Scattergun", "Unique Scattergun", TF_AMMO.PRIMARY, 6, 32)
	TF_WEAPONS(1, 0, "scattergun", 45, "Force-A-Nature", "FAN", TF_AMMO.PRIMARY, 2, 32)
	TF_WEAPONS(1, 0, "handgun_scout_primary", 220, "Shortstop", null, TF_AMMO.PRIMARY, 4, 32)
	TF_WEAPONS(1, 0, "soda_popper", 448, "Soda Popper", null, TF_AMMO.PRIMARY, 2, 32)
	TF_WEAPONS(1, 0, "pep_brawler_blaster", 772, "Baby Face's Blaster", "BFB", TF_AMMO.PRIMARY, 4, 32)
	TF_WEAPONS(1, 0, "scattergun", 1103, "Back Scatter", null, TF_AMMO.PRIMARY, 4, 32)

	TF_WEAPONS(1, 1, "pistol_scout", 22, "Scout Pistol", null, TF_AMMO.SECONDARY, 12, 36)
	TF_WEAPONS(1, 1, "lunchbox_drink", 46, "Bonk! Atomic Punch", "Bonk", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 1, "lunchbox_drink", 163, "Crit-a-Cola", "CAC", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 1, "jar_milk", 222, "Mad Milk", "Milk", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 1, "handgun_scout_secondary", 449, "Winger", null, TF_AMMO.SECONDARY, 5, 36)
	TF_WEAPONS(1, 1, "handgun_scout_secondary", 773, "Pretty Boy's Pocket Pistol", "PBPP", TF_AMMO.SECONDARY, 9, 36)
	TF_WEAPONS(1, 1, "cleaver", 812, "Flying Guillotine", "Cleaver", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 1, "cleaver", 833, "Genuine Flying Guillotine", "Genuine Cleaver", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 1, "jar_milk", 1121, "Mutated Milk", null, TF_AMMO.GRENADES2, 1, -1)

	TF_WEAPONS(1, 2, "bat", 0, "Bat")
	TF_WEAPONS(1, 2, "bat", 190, "Bat", "Unique Bat")
	TF_WEAPONS(1, 2, "bat_wood", 44, "Sandman", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(1, 2, "bat_fish", 221, "Holy Mackerel", "Fish")
	TF_WEAPONS(1, 2, "bat", 317, "Candy Cane")
	TF_WEAPONS(1, 2, "bat", 325, "Boston Basher")
	TF_WEAPONS(1, 2, "bat", 349, "Sun-on-a-Stick", "SOAS")
	TF_WEAPONS(1, 2, "bat", 355, "Fan O'War", "FOW")
	TF_WEAPONS(1, 2, "bat", 450, "Atomizer")
	TF_WEAPONS(1, 2, "bat_giftwrap", 648, "Wrap Assassin", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(1, 2, "bat", 452, "Three-Rune Blade", "TRB")
	TF_WEAPONS(1, 2, "bat", 572, "Unarmed Combat", "Spy Arm")
	TF_WEAPONS(1, 2, "bat", 30667, "Batsaber")

//-----------------------------------------------------------------------------
// Solly
//-----------------------------------------------------------------------------
	TF_WEAPONS(3, 0, "rocketlauncher", 18, "Rocket Launcher", "RL", TF_AMMO.PRIMARY, 4, 20)
	TF_WEAPONS(3, 0, "rocketlauncher", 205, "Rocket Launcher", "Unique Rocket Launcher", TF_AMMO.PRIMARY, 4, 20)
	TF_WEAPONS(3, 0, "rocketlauncher_directhit", 127, "Direct Hit", "DH", TF_AMMO.PRIMARY, 4, 20)
	TF_WEAPONS(3, 0, "rocketlauncher", 228, "Black Box", null, TF_AMMO.PRIMARY, 3, 20)
	TF_WEAPONS(3, 0, "rocketlauncher", 237, "Rocket Jumper", "RJ", TF_AMMO.PRIMARY, 4, 60)
	TF_WEAPONS(3, 0, "rocketlauncher", 414, "Liberty Launcher", null, TF_AMMO.PRIMARY, 5, 20)
	TF_WEAPONS(3, 0, "particle_cannon", 441, "Cow Mangler 5000", "Cow Mangler", TF_AMMO.PRIMARY, 4, -1)
	TF_WEAPONS(3, 0, "rocketlauncher", 513, "Original", null, TF_AMMO.PRIMARY, 4, 20)
	TF_WEAPONS(3, 0, "rocketlauncher", 730, "Beggar's Bazooka", "Beggars", TF_AMMO.PRIMARY, 0, 20)
	TF_WEAPONS(3, 0, "rocketlauncher_airstrike", 1104, "Air Strike", "Airstrike", TF_AMMO.PRIMARY, 4, 20)

	TF_WEAPONS(3, 1, "shotgun_soldier", 10, "Soldier Shotgun", null, TF_AMMO.SECONDARY, 6, 32)
	TF_WEAPONS(3, 1, "buff_item", 129, "Buff Banner", "Buff", TF_AMMO.NONE, -1, -1, "models/weapons/c_models/c_buffpack/c_buffpack.mdl")
	TF_WEAPONS(3, 1, "tf_wearable", 133, "Gunboats", null, TF_AMMO.NONE, -1, -1, "models/weapons/c_models/c_rocketboots_soldier.mdl")
	TF_WEAPONS(3, 1, "buff_item", 226, "Battalion's Backup", "Backup", TF_AMMO.NONE, -1, -1, "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl")
	TF_WEAPONS(3, 1, "buff_item", 354, "Concheror", "Conch", TF_AMMO.NONE, -1, -1, "models/workshop_partner/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl")
	//TF_WEAPONS(3, 1, "shotgun", 415, "Reserve Shooter", null, TF_AMMO.SECONDARY, 4, 32)	//already at the top in all-class stuff
	TF_WEAPONS(3, 1, "raygun", 442, "Righteous Bison", "Bison", TF_AMMO.SECONDARY, 4, -1)
	TF_WEAPONS(3, 1, "tf_wearable", 444, "Mantreads", null,  TF_AMMO.NONE, -1, -1, "models/workshop/player/items/soldier/mantreads/mantreads.mdl")
	TF_WEAPONS(3, 1, "parachute_secondary", 1101, "B.A.S.E. Jumper Secondary", "Soldier Parachute", TF_AMMO.NONE, -1, -1, "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_pack.mdl")

	TF_WEAPONS(3, 2, "shovel", 6, "Shovel")
	TF_WEAPONS(3, 2, "shovel", 196, "Shovel", "Unique Shovel")
	TF_WEAPONS(3, 2, "shovel", 128, "Equalizer")
	TF_WEAPONS(3, 2, "shovel", 154, "Pain Train")
	TF_WEAPONS(3, 2, "katana", 357, "Half-Zatoichi", "Katana")
	TF_WEAPONS(3, 2, "shovel", 416, "Market Gardener")
	TF_WEAPONS(3, 2, "shovel", 447, "Disciplinary Action", "DA")
	TF_WEAPONS(3, 2, "shovel", 775, "Escape Plan")

//-----------------------------------------------------------------------------
// Pyro
//-----------------------------------------------------------------------------
	TF_WEAPONS(7, 0, "flamethrower", 21, "Flamethrower", "FT", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 208, "Flamethrower", "Unique FT", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 40, "Backburner", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 215, "Degreaser", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 594, "Phlogistinator", "Phlog", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 741, "Rainblower", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "rocketlauncher_fireball", 1178, "Dragon's Fury", "DF", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 30474, "Nostromo Napalmer", "Alien Flamethrower", TF_AMMO.PRIMARY, -1, 200)

	TF_WEAPONS(7, 1, "shotgun_pyro", 12, "Pyro Shotgun", null, TF_AMMO.SECONDARY, 6, 32)
	TF_WEAPONS(7, 1, "flaregun", 39, "Flare Gun", "Flaregun", TF_AMMO.SECONDARY, -1, 16)
	TF_WEAPONS(7, 1, "flaregun", 351, "Detonator", null, TF_AMMO.SECONDARY, -1, 16)
	TF_WEAPONS(7, 1, "flaregun_revenge", 595, "Manmelter", null, TF_AMMO.SECONDARY)
	TF_WEAPONS(7, 1, "flaregun", 740, "Scorch Shot", null, TF_AMMO.SECONDARY, -1, 16)
	TF_WEAPONS(7, 1, "rocketpack", 1179, "Thermal Thruster", "Rocketpack", TF_AMMO.GRENADES1, 2, -1, "models/weapons/c_models/c_rocketpack/c_rocketpack.mdl")
	TF_WEAPONS(7, 1, "jar_gas", 1180, "Gas Passer", null, TF_AMMO.GRENADES1, 1, -1)

	TF_WEAPONS(7, 2, "fireaxe", 2, "Fire Axe", "Fireaxe")
	TF_WEAPONS(7, 2, "fireaxe", 192, "Fire Axe", "Unique Fire Axe")
	TF_WEAPONS(7, 2, "fireaxe", 38, "Axtinguisher")
	TF_WEAPONS(7, 2, "fireaxe", 153, "Homewrecker")
	TF_WEAPONS(7, 2, "fireaxe", 214, "Powerjack")
	TF_WEAPONS(7, 2, "fireaxe", 326, "Back Scratcher", "Backscratcher")
	TF_WEAPONS(7, 2, "fireaxe", 348, "Sharpened Volcano Fragment", "SVF")
	TF_WEAPONS(7, 2, "fireaxe", 457, "Postal Plummeler", "Mailbox")
	TF_WEAPONS(7, 2, "fireaxe", 466, "Maul")
	TF_WEAPONS(7, 2, "fireaxe", 593, "Third-Degree", "Third Degree")
	TF_WEAPONS(7, 2, "fireaxe", 739, "Lollichop")
	TF_WEAPONS(7, 2, "breakable_sign", 813, "Neon Annihilator")
	TF_WEAPONS(7, 2, "breakable_sign",  834, "Genuine Neon Annihilator")
	TF_WEAPONS(7, 2, "slap", 1181, "Hot Hand", "Slap Glove")

//-----------------------------------------------------------------------------
// Demo
//-----------------------------------------------------------------------------
	TF_WEAPONS(4, 0, "grenadelauncher", 19, "Grenade Launcher", "GL", TF_AMMO.PRIMARY, 4, 16)
	TF_WEAPONS(4, 0, "grenadelauncher", 206, "Grenade Launcher", "Unique Grenade Launcher", TF_AMMO.PRIMARY, 4, 16)
	TF_WEAPONS(4, 0, "grenadelauncher", 308, "Loch-n-Load", "Loch", TF_AMMO.PRIMARY, 3, 16)
	TF_WEAPONS(4, 0, "tf_wearable", 405, "Ali Baba's Wee Booties", "Booties")
	TF_WEAPONS(4, 0, "tf_wearable", 608, "Bootlegger")
	TF_WEAPONS(4, 0, "cannon", 996, "Loose Cannon", null, TF_AMMO.PRIMARY, 4, 16)
	TF_WEAPONS(4, 0, "parachute_primary", 1101, "B.A.S.E. Jumper Primary", "Demo Parachute", TF_AMMO.NONE, -1, -1, "models/workshop/weapons/c_models/c_paratooper_pack/c_paratrooper_pack.mdl")
	TF_WEAPONS(4, 0, "grenadelauncher", 1151, "Iron Bomber", null, TF_AMMO.PRIMARY, 4, 16)

	TF_WEAPONS(4, 1, "pipebomblauncher", 20, "Stickybomb Launcher", "SBL", TF_AMMO.SECONDARY, 8, 24)
	TF_WEAPONS(4, 1, "pipebomblauncher", 207, "Stickbomb Launcher", "Unique Stickybomb Launcher", TF_AMMO.SECONDARY, 8, 24)
	TF_WEAPONS(4, 1, "pipebomblauncher", 130, "Scottish Resistance", "Resistance", TF_AMMO.SECONDARY, 8, 36)
	TF_WEAPONS(4, 1, "pipebomblauncher", 265, "Sticky Jumper", "SJ", TF_AMMO.SECONDARY, 8, 72)
	TF_WEAPONS(4, 1, "pipebomblauncher", 1150, "Quickiebomb Launcher", null, TF_AMMO.SECONDARY, 4, 24)
	TF_WEAPONS(4, 1, "demoshield", 131, "Chargin' Targe", "Targe")
	TF_WEAPONS(4, 1, "demoshield", 406, "Splendid Screen")
	TF_WEAPONS(4, 1, "demoshield", 1099, "Tide Turner")

	TF_WEAPONS(4, 2, "bottle", 1, "Bottle")
	TF_WEAPONS(4, 2, "bottle", 191, "Bottle", "Unique Bottle")
	TF_WEAPONS(4, 2, "sword", 132, "Eyelander")
	TF_WEAPONS(4, 2, "sword", 172, "Scotsman's Skullcutter", "Skullcutter")
	TF_WEAPONS(4, 2, "stickbomb", 307, "Ullapool Caber", "Caber")
	TF_WEAPONS(4, 2, "sword", 327, "Claidheamh Mor", "Claid")
	TF_WEAPONS(0, 2, "sword", 404, "Persian Persuader", "Persuader")
	TF_WEAPONS(4, 2, "sword", 266, "Horseless Headless Horseman's Headtaker", "HHHH")
	TF_WEAPONS(4, 2, "sword", 482, "Nessie's Nine Iron", "Golf Club")
	TF_WEAPONS(4, 2, "bottle", 609, "Scottish Handshake")


//-----------------------------------------------------------------------------
// Heavy
//-----------------------------------------------------------------------------
	TF_WEAPONS(6, 0, "minigun", 15, "Minigun", "Sasha", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 202, "Minigun", "Unique Minigun",TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 41, "Natascha", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 298, "Iron Curtain", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 312, "Brass Beast", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 424, "Tomislav", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 811, "Huo-Long Heater", "Heater", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 832, "Genuine Huo-Long Heater", "Genuine Heater", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 0, "minigun", 850, "Deflector", null, TF_AMMO.PRIMARY, -1, 200)

	TF_WEAPONS(6, 1, "shotgun_hwg", 11, "Heavy Shotgun", null, TF_AMMO.SECONDARY, 6, 32)
	TF_WEAPONS(6, 1, "lunchbox", 42, "Sandvich", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 1, "lunchbox", 159, "Dalokohs Bar", "Dalokohs", TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 1, "lunchbox", 311, "Buffalo Steak Sandvich", "Steak", TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 1, "shotgun", 425, "Family Business", null, TF_AMMO.SECONDARY, 8, 32)
	TF_WEAPONS(6, 1, "lunchbox", 433, "Fishcake", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 1, "lunchbox", 863, "Robo-Sandvich", "Robo Sandvich", TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 1, "lunchbox", 1190, "Second Banana", "Banana", TF_AMMO.GRENADES1, 1, -1)

	TF_WEAPONS(6, 2, "fists", 5, "Fists")
	TF_WEAPONS(6, 2, "fists", 195, "Fists", "Unique Fists")
	TF_WEAPONS(6, 2, "fists", 43, "Killing Gloves of Boxing", "KGB")
	TF_WEAPONS(6, 2, "fists", 239, "Gloves of Running Urgently", "GRU")
	TF_WEAPONS(6, 2, "fists", 310, "Warrior's Spirit", "WS")
	TF_WEAPONS(6, 2, "fists", 331, "Fists of Steel", "FOS")
	TF_WEAPONS(6, 2, "fists", 426, "Eviction Notice", "EN")
	TF_WEAPONS(6, 2, "fists", 587, "Apoco-Fists")
	TF_WEAPONS(6, 2, "fists", 656, "Holiday Punch")
	TF_WEAPONS(6, 2, "fists", 1100, "Bread Bite", "Bread GRU")
	TF_WEAPONS(6, 2, "fists", 1184, "Gloves of Running Urgently MvM", "GRU MVM")

//-----------------------------------------------------------------------------
// Engineer
//-----------------------------------------------------------------------------
	TF_WEAPONS(9, 0, "shotgun_primary", 9, "Shotgun Primary", "Engineer Shotgun", TF_AMMO.PRIMARY, 6, 32)
	TF_WEAPONS(9, 0, "sentry_revenge", 141, "Frontier Justice", "FJ", TF_AMMO.PRIMARY, 3, 32)
	TF_WEAPONS(9, 0, "shotgun_primary", 527, "Widowmaker", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 0, "drg_pomson", 588, "Pomson 6000", "Pomson", TF_AMMO.PRIMARY, 4, -1)
	TF_WEAPONS(9, 0, "shotgun_building_rescue", 997, "Rescue Ranger", null, TF_AMMO.PRIMARY, 4, 16)

	TF_WEAPONS(9, 1, "pistol_scout", 22, "Engineer Pistol", null, TF_AMMO.SECONDARY, 12, 200)	//purposely putting pistol_scout as classname because lazy to make more checks
	TF_WEAPONS(9, 1, "laser_pointer", 140, "Wrangler")
	TF_WEAPONS(9, 1, "mechanical_arm", 528, "Short Circuit", null, TF_AMMO.METAL, -1, 200)

	TF_WEAPONS(9, 2, "wrench", 7, "Wrench", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "wrench", 197, "Wrench", "Unique Wrench", TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "robot_arm", 142, "Gunslinger", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "wrench", 155, "Southern Hospitality", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "wrench", 329, "Jag", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "wrench", 589, "Eureka Effect", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 2, "wrench", 169, "Golden Wrench", null, TF_AMMO.METAL, -1, 200)

	TF_WEAPONS(9, 3, "pda_engineer_build", 25, "Build PDA", null, TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 3, "pda_engineer_build", 737, "Build PDA", "Unique Build PDA", TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 4, "pda_engineer_destroy", 26, "Destruction PDA", "Destroy PDA", TF_AMMO.METAL, -1, 200)
	TF_WEAPONS(9, 5, "builder", 28, "Toolbox", "Engineer Toolbox", TF_AMMO.METAL, -1, 200)

//-----------------------------------------------------------------------------
// Medic
//-----------------------------------------------------------------------------
	TF_WEAPONS(5, 0, "syringegun_medic", 17, "Syringe Gun", "Syringegun", TF_AMMO.PRIMARY, 40, 150)
	TF_WEAPONS(5, 0, "syringegun_medic", 204, "Syringe Gun", "Unique Syringe Gun", TF_AMMO.PRIMARY, 40, 150)
	TF_WEAPONS(5, 0, "syringegun_medic", 36, "Blutsauger", null, TF_AMMO.PRIMARY, 40, 150)
	TF_WEAPONS(5, 0, "crossbow", 305, "Crusader's Crossbow", "Crossbow", TF_AMMO.PRIMARY, 1, 38)
	TF_WEAPONS(5, 0, "syringegun_medic", 412, "Overdose", null, TF_AMMO.PRIMARY, 40, 150)

	TF_WEAPONS(5, 1, "medigun", 29, "Medigun", "Medi Gun")
	TF_WEAPONS(5, 1, "medigun", 211, "Medigun", "Unique Medigun")
	TF_WEAPONS(5, 1, "medigun", 35, "Kritzkrieg")
	TF_WEAPONS(5, 1, "medigun", 411, "Quick-Fix", "QF", TF_AMMO.NONE, -1, -1, "models/weapons/c_models/c_proto_backpack/c_proto_backpack.mdl")
	TF_WEAPONS(5, 1, "medigun", 998, "Vaccinator", null, TF_AMMO.NONE, -1, -1, "models/workshop/weapons/c_models/c_medigun_defense/c_medigun_defensepack.mdl")

	TF_WEAPONS(5, 2, "bonesaw", 8, "Bonesaw")
	TF_WEAPONS(5, 2, "bonesaw", 198, "Bonesaw", "Unique Bonesaw")
	TF_WEAPONS(5, 2, "bonesaw", 37, "Ubersaw")
	TF_WEAPONS(5, 2, "bonesaw", 173, "Vita-Saw")
	TF_WEAPONS(5, 2, "bonesaw", 304, "Amputator")
	TF_WEAPONS(0, 2, "bonesaw", 413, "Solemn Vow")

//-----------------------------------------------------------------------------
// Sniper
//-----------------------------------------------------------------------------
	TF_WEAPONS(2, 0, "sniperrifle", 14, "Sniper Rifle", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle", 201, "Sniper Rifle", "Unique Sniper Rifle", TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "compound_bow", 56, "Huntsman", null, TF_AMMO.PRIMARY, 1, 12)
	TF_WEAPONS(2, 0, "sniperrifle", 230, "Sydney Sleeper", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle_decap", 402, "Bazaar Bargain", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle", 526, "Machina", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle", 752, "Hitman's Heatmaker", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle", 851, "AWPer Hand", "AWP", TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "compound_bow", 1092, "Fortified Compound", null, TF_AMMO.PRIMARY, 1, 12)
	TF_WEAPONS(2, 0, "sniperrifle_classic", 1098, "Classic", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "sniperrifle", 30665, "Shooting Star", null, TF_AMMO.PRIMARY, -1, 25)

	TF_WEAPONS(2, 1, "smg", 16, "SMG", null, TF_AMMO.SECONDARY, 25, 75)
	TF_WEAPONS(2, 1, "smg", 203, "SMG", "Unique SMG", TF_AMMO.SECONDARY, 25, 75)
	TF_WEAPONS(2, 1, "razorback", 57, "Razorback", null, TF_AMMO.NONE, 1, -1)
	TF_WEAPONS(2, 1, "jar", 58, "Jarate", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(2, 1, "tf_wearable", 231, "Darwin's Danger Shield", "DDS")
	TF_WEAPONS(2, 1, "tf_wearable", 642, "Cozy Camper")
	TF_WEAPONS(2, 1, "charged_smg", 751, "Cleaner's Carbine")
	TF_WEAPONS(2, 1, "jar", 1105, "Self-Aware Beauty Mark", "Bread Jarate", TF_AMMO.GRENADES1, 1, -1)

	TF_WEAPONS(2, 2, "club", 3, "Kukri")
	TF_WEAPONS(2, 2, "club", 193, "Kukri", "Unique Kukri")
	TF_WEAPONS(2, 2, "club", 171, "Tribalman's Shiv")
	TF_WEAPONS(2, 2, "club", 232, "Bushwacka")
	TF_WEAPONS(2, 2, "club", 401, "Shahanshah")

//-----------------------------------------------------------------------------
// Spy
//-----------------------------------------------------------------------------
	TF_WEAPONS(8, 0, "revolver", 24, "Revolver", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 210, "Revolver", "Unique Revolver", TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 61, "Ambassador", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 161, "Big Kill", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 224, "L'Etranger", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 460, "Enforcer", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 525, "Diamondback", null, TF_AMMO.SECONDARY, 6, 24)

	TF_WEAPONS(8, 1, "sapper", 735, "Sapper")	//changing classname from "builder" to "sapper for QoL
	TF_WEAPONS(8, 1, "sapper", 736, "Sapper", "Unique Sapper")	//changing classname from "builder" to "sapper for QoL
	TF_WEAPONS(8, 1, "sapper", 810, "Red-Tape Recorder", "Red-Tape")
	TF_WEAPONS(8, 1, "sapper", 831, "Genuine Red-Tape Recorder", "Genuine Red-Tape")
	TF_WEAPONS(8, 1, "sapper", 933, "Ap-Sap")
	TF_WEAPONS(8, 1, "sapper", 1102, "Snack Attack", "Bread Sapper")

	TF_WEAPONS(8, 2, "knife", 4, "Knife")
	TF_WEAPONS(8, 2, "knife", 194, "Knife", "Unique Knife")
	TF_WEAPONS(8, 2, "knife", 225, "Your Eternal Reward", "YER")
	TF_WEAPONS(8, 2, "knife", 356, "Conniver's Kunai", "Kunai")
	TF_WEAPONS(8, 2, "knife", 461, "Big Earner")
	TF_WEAPONS(8, 2, "knife", 574, "Wanga Prick")
	TF_WEAPONS(8, 2, "knife", 638, "Sharp Dresser")
	TF_WEAPONS(8, 2, "knife", 649, "Spy-cicle")
	TF_WEAPONS(8, 2, "knife", 727, "Black Rose")

	TF_WEAPONS(8, 3, "pda_spy", 27, "Disguise Kit PDA", "Disguise Kit")

	TF_WEAPONS(8, 4, "invis", 30, "Invisibility Watch", "Invis Watch")
	TF_WEAPONS(8, 4, "invis", 212, "Invisibility Watch", "Unique Invisibility Watch")
	TF_WEAPONS(8, 4, "invis", 59, "Dead Ringer", "DR")
	TF_WEAPONS(8, 4, "invis", 60, "Cloak and Dagger", "CAD")
	TF_WEAPONS(8, 4, "invis", 297, "Enthusiast's Timepiece", "TTG Watch")
	TF_WEAPONS(8, 4, "invis", 947, "Quackenbirdt")

//-----------------------------------------------------------------------------
//	Festives
//-----------------------------------------------------------------------------
	TF_WEAPONS(0, 1, "shotgun", 1141, "Festive Shotgun", null, TF_AMMO.SECONDARY, 6, 32)

	TF_WEAPONS(1, 0, "scattergun", 669, "Festive Scattergun", "Festive Scatter Gun", TF_AMMO.PRIMARY, 6, 32)
	TF_WEAPONS(1, 0, "scattergun", 1078, "Festive Force-A-Nature", "Festive FAN", TF_AMMO.PRIMARY, 2, 32)
	TF_WEAPONS(1, 1, "lunchbox_drink", 46, "Festive Bonk!", "Festive Bonk", TF_AMMO.GRENADES2, 1, -1)
	TF_WEAPONS(1, 2, "bat", 660, "Festive Bat")
	TF_WEAPONS(1, 2, "bat_fish", 999, "Festive Holy Mackerel", "Festive Fish")

	TF_WEAPONS(3, 0, "rocketlauncher", 669, "Festive Rocketlauncher", "Festive RL", TF_AMMO.PRIMARY, 4, 20)
	TF_WEAPONS(3, 0, "rocketlauncher", 1085, "Festive Black Box", null, TF_AMMO.PRIMARY, 3, 20)
	TF_WEAPONS(3, 1, "buff_item", 1001, "Festive Buff Banner", "Festive Buff", TF_AMMO.NONE, -1, -1, "models/weapons/c_models/c_buffpack/c_buffpack_xmas.mdl")

	TF_WEAPONS(7, 0, "flamethrower", 669, "Festive Flame Thrower", "Festive Flamethrower", TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 0, "flamethrower", 1146, "Festive Backburner", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(7, 1, "flaregun", 1081, "Festive Flare Gun", "Festive Flaregun", TF_AMMO.SECONDARY, -1, 16)
	TF_WEAPONS(7, 2, "fireaxe", 1000, "Festive Axtinguisher")

	TF_WEAPONS(4, 2, "grenadelauncher", 1007, "Festive Grenade Launcher", null, TF_AMMO.PRIMARY, 4, 16)
	TF_WEAPONS(4, 1, "demoshield", 1144, "Festive Chargin' Targe", "Festive Targe")
	TF_WEAPONS(4, 2, "pipebomblauncher", 661, "Festive Stickybomb Launcher", null, TF_AMMO.SECONDARY, 8, 24)
	TF_WEAPONS(4, 2, "sword", 1082, "Festive Eyelander")

	TF_WEAPONS(6, 0, "minigun", 654, "Festive Minigun", null, TF_AMMO.PRIMARY, -1, 200)
	TF_WEAPONS(6, 1, "lunchbox", 1002, "Festive Sandvich", null, TF_AMMO.GRENADES1, 1, -1)
	TF_WEAPONS(6, 2, "fists", 1084, "Festive Gloves of Running Urgently", "Festive GRU")

	TF_WEAPONS(9, 0, "shotgun_primary", 1004, "Festive Frontier Justice", null, TF_AMMO.PRIMARY, 3, 32)
	TF_WEAPONS(9, 1, "laser_pointer", 1086, "Festive Wrangler")
	TF_WEAPONS(9, 2, "wrench", 662, "Festive Wrench", null, TF_AMMO.METAL, -1, 200)

	TF_WEAPONS(5, 0, "crossbow", 1079, "Festive Crusader's Crossbow", "Festive Crossbow", TF_AMMO.PRIMARY, 1, 38)
	TF_WEAPONS(5, 1, "medigun", 663, "Festive Medigun", "Festive Medi Gun")
	TF_WEAPONS(5, 2, "bonesaw", 1143, "Festive Bonesaw")
	TF_WEAPONS(5, 2, "bonesaw", 1003, "Festive Ubersaw")

	TF_WEAPONS(2, 0, "sniperrifle", 664, "Festive Sniper Rifle", null, TF_AMMO.PRIMARY, -1, 25)
	TF_WEAPONS(2, 0, "compound_bow", 1005, "Festive Huntsman", null, TF_AMMO.PRIMARY, 1, 12)
	TF_WEAPONS(2, 1, "smg", 1083, "Festive SMG", null, TF_AMMO.SECONDARY, 25, 75)
	TF_WEAPONS(2, 1, "jar", 1149, "Festive Jarate", null, TF_AMMO.GRENADES1, 1, -1)

	TF_WEAPONS(8, 0, "revolver", 1142, "Festive Revolver", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 0, "revolver", 1006, "Festive Ambassador", null, TF_AMMO.SECONDARY, 6, 24)
	TF_WEAPONS(8, 1, "builder", 1080, "Festive Sapper")
	TF_WEAPONS(8, 2, "knife", 665, "Festive Knife")
]


//-----------------------------------------------------------------------------
//	All Warpaints and Botkillers in TF2
//	Botkillers listed first, then warpaints
// NOTE: Warpainted weapons only work on the tfclass intended for them
//-----------------------------------------------------------------------------
::TF_WEAPONS_ALL_WARPAINTSnBOTKILLERS <- [
	TF_WEAPONS_RESKIN(0, 1, "shotgun", "Shotgun", TF_AMMO.SECONDARY, 6, 32, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152)
	TF_WEAPONS_RESKIN(0, 1, "pistol", "Pistol", TF_AMMO.SECONDARY, 12, 36, 15013, 15018, 15035, 15041, 15046, 15056, 15060, 15061, 15100, 15101, 15102, 15126, 15148)

	TF_WEAPONS_RESKIN(1, 0, "scattergun", "Scattergun", TF_AMMO.PRIMARY, 6, 32, 799, 808, 888, 897, 906, 915, 966, 973)
	TF_WEAPONS_RESKIN(1, 0, "scattergun", "Scattergun", TF_AMMO.PRIMARY, 6, 32, 15002, 15015, 15021, 15029, 15036, 15053, 15065, 15069, 15106, 15107, 15108, 15131, 15151, 15157)

	TF_WEAPONS_RESKIN(3, 0, "rocketlauncher", "Rocket Launcher", TF_AMMO.PRIMARY, 4, 20, 800, 809, 889, 898, 907, 916, 965, 974)
	TF_WEAPONS_RESKIN(3, 0, "rocketlauncher", "Rocket Launcher", TF_AMMO.PRIMARY, 4, 20, 15006, 15014, 15028, 15043, 15052, 15057, 15081, 15104, 15105, 15129, 15130, 15150)

	TF_WEAPONS_RESKIN(7, 0, "flamethrower", "Flamethrower", TF_AMMO.PRIMARY, -1, 200, 798, 807, 887, 896, 905, 914, 963, 972)
	TF_WEAPONS_RESKIN(7, 0, "flamethrower", "Flamethrower", TF_AMMO.PRIMARY, -1, 200, 15005, 15017, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141)

	TF_WEAPONS_RESKIN(4, 0, "grenadelauncher", "Grenade Launcher", TF_AMMO.PRIMARY, 4, 16, 15077, 15079, 15091, 15092, 15116, 15117, 15142, 15158)
	TF_WEAPONS_RESKIN(4, 1, "pipebomblauncher", "Stickybomb Launcher", TF_AMMO.SECONDARY, 8, 24, 797, 806, 886, 895, 904, 913, 962, 971)
	TF_WEAPONS_RESKIN(4, 1, "pipebomblauncher", "Stickybomb Launcher", TF_AMMO.SECONDARY, 8, 24, 15009, 15012, 15024, 15038, 15045, 15048, 15082, 15083, 15084, 15113, 15137, 15138, 15155)

	TF_WEAPONS_RESKIN(6, 0, "minigun", "Minigun", TF_AMMO.PRIMARY, -1, 200, 882, 891, 900, 909, 958, 967)
	TF_WEAPONS_RESKIN(6, 0, "minigun", "Minigun", TF_AMMO.PRIMARY, -1, 200, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147)

	TF_WEAPONS_RESKIN(9, 2, "wrench", "Wrench", TF_AMMO.METAL, -1, 200, 795, 804, 884, 893, 902, 911, 960, 969)
	TF_WEAPONS_RESKIN(9, 2, "wrench", "Wrench", TF_AMMO.METAL, -1, 200, 15073, 15074, 15075, 15139, 15140, 15114, 15156, 15158)

	TF_WEAPONS_RESKIN(5, 1, "medigun", "Medigun", TF_AMMO.NONE, -1, -1, 796, 805, 885, 894, 903, 912, 961, 970)
	TF_WEAPONS_RESKIN(5, 1, "medigun", "Medigun", TF_AMMO.NONE, -1, -1, 15008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15123, 15145, 15146)

	TF_WEAPONS_RESKIN(2, 0, "sniperrifle", "Sniper Rifle", TF_AMMO.PRIMARY, -1, 25, 792, 801, 851, 881, 890, 899, 908, 957, 966)
	TF_WEAPONS_RESKIN(2, 0, "sniperrifle", "Sniper Rifle", TF_AMMO.PRIMARY, -1, 25, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154)
	TF_WEAPONS_RESKIN(2, 1, "smg", "SMG", TF_AMMO.PRIMARY, 25, 75, 15001, 15022, 15032, 15037, 15058, 15076, 15110, 15134, 15153)

	TF_WEAPONS_RESKIN(8, 0, "revolver", "Revolver", TF_AMMO.SECONDARY, 6, 24, 15011, 15027, 15042, 15051, 15062, 15063, 15064, 15103, 15127, 15128, 15149)
	TF_WEAPONS_RESKIN(8, 2, "knife", "Knife", TF_AMMO.NONE, -1, -1, 794, 803, 883, 892, 901, 910, 959, 968)
	TF_WEAPONS_RESKIN(8, 2, "knife", "Knife", TF_AMMO.NONE, -1, -1, 15062, 15094, 15095, 15096, 15118, 15119, 15143, 15144)
]



//-----------------------------------------------------------------------------
//	All weapon classnames
//-----------------------------------------------------------------------------
::SearchAllWeapons <-
[
	0,
	"bat",
	"bat_fish",
	"bat_giftwrap",
	"bat_wood",
	"bonesaw",
	"bottle",
	"breakable_sign",
	"buff_item",
	"builder",
	"cannon",
	"charged_smg",
	"cleaver",
	"club",
	"compound_bow",
	"crossbow",
	"drg_pomson",
	"fireaxe",
	"fists",
	"flamethrower",
	"flaregun",
	"flaregun_revenge",
	"grapplinghook",
	"grenadelauncher",
	"handgun_scout_primary",
	"handgun_scout_secondary",
	"invis",
	"jar",
	"jar_milk",
	"jar_gas",
	"katana",
	"knife",
	"laser_pointer",
	"lunchbox",
	"lunchbox_drink",
	"mechanical_arm",
	"medigun",
	"minigun",
	"parachute",
	"parachute_primary",
	"parachute_secondary",
	"particle_cannon",
	"passtime_gun",
	"pda_engineer_build",
	"pda_engineer_destroy",
	"pda_spy",
	"pep_brawler_blaster",
	"pipebomblauncher",
	"pistol",
	"pistol_scout",
	"raygun",
	"revolver",
	"robot_arm",
	"rocketlauncher",
	"rocketlauncher_airstrike",
	"rocketlauncher_directhit",
	"rocketlauncher_fireball",
	"rocketpack",
	"sapper",
	"scattergun",
	"sentry_revenge",
	"shotgun_hwg",
	"shotgun_primary",
	"shotgun_pyro",
	"shotgun_building_rescue",
	"shotgun_soldier",
	"shovel",
	"slap",
	"smg",
	"sniperrifle",
	"sniperrifle_classic",
	"sniperrifle_decap",
	"soda_popper",
	"spellbook",
	"stickbomb",
	"sword",
	"syringegun_medic",
	"wrench",
]
::SearchPrimaryWeapons <-
[
	0,
	"cannon",
	"compound_bow",
	"crossbow",
	"drg_pomson",
	"flamethrower",
	"grenadelauncher",
	"handgun_scout_primary",
	"minigun",
	"parachute",
	"parachute_primary",
	"particle_cannon",
	"pep_brawler_blaster",
	"revolver",
	"rocketlauncher",
	"rocketlauncher_airstrike",
	"rocketlauncher_directhit",
	"rocketlauncher_fireball",
	"scattergun",
	"sentry_revenge",
	"shotgun_primary",
	"sniperrifle",
	"sniperrifle_classic",
	"sniperrifle_decap",
	"soda_popper",
	"syringegun_medic",
]
::SearchSecondaryWeapons <-
[
	0,
	"buff_item",
	"charged_smg",
	"cleaver",
	"flaregun",
	"flaregun_revenge",
	"handgun_scout_secondary",
	"jar",
	"jar_milk",
	"jar_gas",
	"laser_pointer",
	"lunchbox",
	"lunchbox_drink",
	"mechanical_arm",
	"medigun",
	"parachute",
	"parachute_secondary",
	"pipebomblauncher",
	"pistol",
	"pistol_scout",
	"raygun",
	"rocketpack",
	"shotgun_hwg",
	"shotgun_pyro",
	"shotgun_soldier",
	"smg",
]
::SearchMeleeWeapons <-
[
	0,
	"bat",
	"bat_fish",
	"bat_giftwrap",
	"bat_wood",
	"bonesaw",
	"bottle",
	"breakable_sign",
	"club",
	"fireaxe",
	"fists",
	"katana",
	"knife",
	"robot_arm",
	"shovel",
	"slap",
	"stickbomb",
	"sword",
	"wrench",
]
::SearchMiscWeapons <-
[
	0,
	"builder",
	"grapplinghook",
	"invis",
	"passtime_gun",
	"pda_engineer_build",
	"pda_engineer_destroy",
	"pda_spy",
	"sapper",
	"spellbook",
]
::SearchSlot3Weapons <-
[
	0,
	"pda_spy",
	"pda_engineer_build",
]
::SearchSlot4Weapons <-
[
	0,
	"invis",
	"pda_engineer_destroy",
]
::SearchSlot5Weapons <-
[
	0,
	"builder",
	"sapper",
]
::SearchSlot6Weapons <-
[
	0,
	"grapplinghook",
	//"passtime_gun",
	"spellbook",
]

::SearchPassiveItems <-
[
	0,
	"tf_wearable_demoshield",
	"tf_wearable",
	"tf_wearable_razorback",
	"tf_weapon_parachute",
	"tf_weapon_parachute_primary",
	"tf_weapon_parachute_secondary",
]

::MedievalBlacklist <-
[
	0,
	"cannon",
	"rocketpack",
	"jar",
	"jar_gas",
	"flaregun",
	"pda_engineer_build",
	"pda_engineer_destroy",
	"builder",
	"sapper",

	"drg_pomson",
	"flamethrower",
	"grenadelauncher",
	"handgun_scout_primary",
	"minigun",
	"particle_cannon",
	"pep_brawler_blaster",
	"revolver",
	"rocketlauncher",
	"rocketlauncher_airstrike",
	"rocketlauncher_directhit",
	"rocketlauncher_fireball",
	"scattergun",
	"sentry_revenge",
	"shotgun_primary",
	"sniperrifle",
	"sniperrifle_classic",
	"sniperrifle_decap",
	"soda_popper",
	"syringegun_medic",
	"charged_smg",
	"flaregun_revenge",
	"handgun_scout_secondary",
	"laser_pointer",
	"mechanical_arm",
	"medigun",
	"raygun",
	"pipebomblauncher",
	"pistol",
	"pistol_scout",
	"shotgun_hwg",
	"shotgun_pyro",
	"shotgun_soldier",
	"smg",
]