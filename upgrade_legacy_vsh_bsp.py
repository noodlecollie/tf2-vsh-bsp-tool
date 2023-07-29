import argparse
import os
import sys
import traceback

from scripts import bsp, entities

def parse_args():
	parser = argparse.ArgumentParser(
		prog="upgrade_legacy_vsh_bsp",
		description="Updates a legacy VSH (Arena) map to use the new community VSH game mode.")

	parser.add_argument("map_files",
		nargs="+",
		help="Paths to one or more map files that should be updated.")

	parser.add_argument("-s", "--settings",
		required=False,
		help="Optional JSON file specifying VSH game mode setting overrides that should apply to this map.")

	return parser.parse_args()

def create_game_rules_entity():
	return \
	{
		"classname": "tf_gamerules",
		"targetname": "tf_gamerules",
		"ctf_overtime": 1,
		"hud_type": 0
	}

def create_logic_script_entity():
	return \
	{
		"classname": "logic_script",
		"targetname": "logic_script_vsh",
		"vscripts": "vssaxtonhale/vsh.nut"
	}

def remove_unneeded_entities(ent_list):
	index = 0
	while index < len(ent_list):
		if ent_list[index]["classname"] == "tf_logic_arena":
			print("Removing tf_logic_arena")
			del ent_list[index]
		else:
			index += 1

def add_required_entities(ent_list):
	if not entities.find_entities_matching(ent_list, classname="tf_gamerules"):
		ent_list.append(create_game_rules_entity())

	if not entities.find_entities_matching(ent_list, classname="logic_script", targetname="logic_script_vsh"):
		ent_list.append(create_logic_script_entity())

def process_bsp(bsp_file):
	bsp.validate_bsp_file(bsp_file)

	ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))

	remove_unneeded_entities(ent_list)
	add_required_entities(ent_list)

	# TODO: Continue from here

def main():
	args = parse_args()
	first_iteration = True
	all_succeeded = True

	for map_file in args.map_files:
		if not first_iteration:
			print()

		if not os.path.isfile(map_file):
			print(f"Map {map_file} does not exist")
			continue

		print(f"Patching {map_file}")

		with open(map_file, "rb") as bsp_file:
			try:
				process_bsp(bsp_file)
			except Exception as ex:
				print(f"An error occured while processing the file. {ex}")
				traceback.print_exception(ex)

				all_succeeded = false

		first_iteration = False

	sys.exit(0 if all_succeeded else 1)

if __name__ == "__main__":
	main()
