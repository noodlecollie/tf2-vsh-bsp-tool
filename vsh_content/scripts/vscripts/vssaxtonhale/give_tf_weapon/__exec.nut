::TF_CUSTOM_WEAPONS_REGISTRY <- {};
PrecacheModel("models/weapons/c_models/c_engineer_gunslinger.mdl");
::worldspawn <- Entities.First();

const GLOBAL_WEAPON_COUNT = 7

gtfw_exec_code <- [
"_tables",
"_util",
"CreateCustomWearable()",
"GetWeaponTable()",
"SwitchToBest()",
"GiveWeapon()",
"GetWeapon()",
"CustomWeaponRegistration",
"zz_BotFix"
]

foreach ( file in gtfw_exec_code )
{
	Include( "give_tf_weapon/" + file + ".nut" );
}