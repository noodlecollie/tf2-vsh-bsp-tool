import argparse
import os
import sys
import traceback
import io
import zipfile

from scripts import bsp, entities, keyvalues, file_merge, pak

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

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
	[
		("classname", "tf_gamerules"),
		("targetname", "tf_gamerules"),
		("ctf_overtime", 1),
		("hud_type", 0),
		("origin", "0 0 0")
	]

def create_logic_script_entity():
	return \
	[
		("classname", "logic_script"),
		("targetname", "logic_script_vsh"),
		("vscripts", "vssaxtonhale/vsh.nut"),
		("origin", "0 0 0")
	]

def remove_unneeded_entities(ent_list):
	index = 0
	while index < len(ent_list):
		if keyvalues.get_first_value(ent_list[index], "classname") == "tf_logic_arena":
			print("Removing tf_logic_arena")
			del ent_list[index]
		else:
			index += 1

def add_required_entities(ent_list):
	if not entities.find_entities_matching(ent_list, classname="tf_gamerules"):
		ent_list.append(create_game_rules_entity())

	if not entities.find_entities_matching(ent_list, classname="logic_script", vscripts="vssaxtonhale/vsh.nut"):
		ent_list.append(create_logic_script_entity())

def merge_level_sounds_txt(pakzip_in, archive_file_path: str, disk_file_path: str):
	existing_data = pak.get_file_data(pakzip_in, archive_file_path)

	with open(disk_file_path, "rb") as infile:
		new_data = infile.read()

	return file_merge.merge_level_sounds_txt_data(existing_data, new_data)

def merge_particles_txt(pakzip_in, archive_file_path: str, disk_file_path: str):
	existing_data = pak.get_file_data(pakzip_in, archive_file_path.replace("\\", "/"))

	with open(disk_file_path, "rb") as infile:
		new_data = infile.read()

	return file_merge.merge_particles_txt_data(existing_data, new_data)

def merge_files(pakzip_in, pakzip_out, map_name: str, path_on_disk: str, dir_in_pak: str):
	filename = os.path.basename(path_on_disk)

	if filename.endswith("level_sounds.txt"):
		target_path = os.path.join(dir_in_pak, f"{map_name}_level_sounds.txt")

		print(f"Merging VSH level sounds into {target_path}")
		data = merge_level_sounds_txt(pakzip_in, target_path, path_on_disk)
	elif filename.endswith("particles.txt"):
		target_path = os.path.join(dir_in_pak, f"{map_name}_particles.txt")

		print(f"Merging VSH particle references into {target_path}")
		data = merge_particles_txt(pakzip_in, target_path, path_on_disk)
	else:
		raise NotImplementedError(f"Unsupported request to merge data for file {path_on_disk}")

	pak.try_write_data(pakzip_out, target_path, data)

def file_requires_merge(path_in_archive: str, filename: str):
	return path_in_archive == "maps" and (filename.endswith("level_sounds.txt") or filename.endswith("particles.txt"))

def add_files_to_pak(pakdata_in, pakdata_out, map_name: str):
	with zipfile.ZipFile(pakdata_out, mode="w") as pakzip_out:
		with zipfile.ZipFile(pakdata_in, mode="r") as pakzip_in:
			content_path = os.path.join(SCRIPT_DIR, "vsh_content")

			for (dirpath, dirnames, filenames) in os.walk(content_path):
				dir_in_pak = os.path.relpath(dirpath, content_path)

				for filename in filenames:
					file_path_on_disk = os.path.join(dirpath, filename)
					file_path_in_bsp = os.path.join(dir_in_pak, filename)

					if file_requires_merge(dir_in_pak, filename):
						merge_files(pakzip_in, pakzip_out, map_name, file_path_on_disk, dir_in_pak)
					else:
						pak.try_write_disk_file(pakzip_out, file_path_on_disk, file_path_in_bsp)

def process_bsp(map_name: str, bsp_file):
	bsp.validate_bsp_file(bsp_file)
	bsp.validate_pakfile_lump(bsp_file)

	ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))

	remove_unneeded_entities(ent_list)
	add_required_entities(ent_list)

	pakdata_in = io.BytesIO(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_PAKFILE))
	pakdata_out = io.BytesIO(bytes())

	add_files_to_pak(pakdata_in, pakdata_out, map_name)

	# REMOVE ME once testing is complete:
	with open("temp.zip", "wb") as outfile:
		outfile.write(pakdata_out.getbuffer())

def process_file(map_file: str):
	if not os.path.isfile(map_file):
		print(f"Map {map_file} does not exist")
		return False

	print(f"Patching {map_file}")

	map_name = os.path.splitext(os.path.basename(map_file))[0]

	with open(map_file, "rb") as bsp_file:
		try:
			process_bsp(map_name, bsp_file)
		except Exception as ex:
			print(f"An error occured while processing the file. {ex}")
			traceback.print_exception(ex)
			return False

	return True

def main():
	args = parse_args()
	first_iteration = True
	all_succeeded = True

	for map_file in args.map_files:
		if not first_iteration:
			print()

		if not process_file(map_file):
			all_succeeded = False

		first_iteration = False

	sys.exit(0 if all_succeeded else 1)

if __name__ == "__main__":
	main()
