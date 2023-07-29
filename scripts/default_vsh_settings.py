import json

DEFAULT_VSH_SETTINGS = \
{
	boss_scale: 1.2,
	round_time: 240,
	jump_force: 700,
	health_factor: 40,
	setup_length: 16,
	setup_lines: True,
	beer_lines: False,
	long_setup_lines: True,
	setup_countdown_lines: True,
	spawn_protection: False,
	ability_hud_folder: "vgui/vssaxtonhale/"
}

def write_default_settings(filePath: str):
	with open(filePath, "w") as outFile:
		json.dump(DEFAULT_VSH_SETTINGS, outFile, indent=4)
