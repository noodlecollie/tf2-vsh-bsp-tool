//-----------------------------------------------------------------------------
//	Purpose: Fixes bots using this script
//-----------------------------------------------------------------------------
::CTFBot.GiveWeapon <- CTFPlayer.GiveWeapon
::CTFBot.CreateCustomWearable <- CTFPlayer.CreateCustomWearable

::CTFBot.GTFW_Cleanup <- CTFPlayer.GTFW_Cleanup
::CTFBot.SwitchToBest <- CTFPlayer.SwitchToBest

::CTFBot.GetWeapon <- CTFPlayer.GetWeapon
::CTFBot.GetWeaponBySlot <- CTFPlayer.GetWeaponBySlot
::CTFBot.GetPassiveWeaponBySlot <- CTFPlayer.GetPassiveWeaponBySlot

::CTFBot.GetWeaponTable <- CTFPlayer.GetWeaponTable
::CTFBot.GetWeaponTableBySlot <- CTFPlayer.GetWeaponTableBySlot
::CTFBot.GetWeaponTableByClassname <- CTFPlayer.GetWeaponTableByClassname
::CTFBot.GetWeaponTableByString <- CTFPlayer.GetWeaponTableByString
::CTFBot.GetWeaponTableByID <- CTFPlayer.GetWeaponTableByID

::CTFBot.HasGunslinger <- CTFPlayer.HasGunslinger
::CTFBot.AddWeapon <- CTFPlayer.AddWeapon

//-----------------------------------------------------------------------------
//	Purpose: Renames in case someone else was using these function names before
//-----------------------------------------------------------------------------

//SwitchToBest
::CTFPlayer.SwitchToActive <- CTFPlayer.SwitchToBest
::CTFBot.SwitchToActive <- CTFPlayer.SwitchToBest

//GetWeapon
::CTFPlayer.ReturnWeapon <- CTFPlayer.GetWeapon
::CTFBot.ReturnWeapon <- CTFPlayer.GetWeapon

//GetWeaponBySlot
::CTFPlayer.ReturnWeaponBySlot <- CTFPlayer.GetWeaponBySlot
::CTFBot.ReturnWeaponBySlot <- CTFPlayer.GetWeaponBySlot

//GetWeaponTable
::CTFPlayer.ReturnWeaponTable <- CTFPlayer.GetWeaponTable
::CTFBot.ReturnWeaponTable <- CTFPlayer.GetWeaponTable