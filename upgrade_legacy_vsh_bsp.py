import argparse
import os
import sys
import traceback
import io
import zipfile

from scripts import bsp, entities, keyvalues, file_mgmt, pak, lump_adjustment

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

def parse_args():
	parser = argparse.ArgumentParser(
		prog="upgrade_legacy_vsh_bsp",
		description="Upgrades a legacy VSH (Arena) map to use the new community VSH game mode.",
		epilog='By default, the resulting map file name will be suffixed with "_cu" (Community Update).')

	parser.add_argument("map_file",
		nargs=1,
		help="Path to map file that should be upgraded.")

	parser.add_argument("-x", "--no-files",
		action="store_true",
		help="Don't add files, just update entities.")

	parser.add_argument("-s", "--suffix",
		default="_cu",
		help="Suffix to append to the output map name. Packaged files that depend on this name will be fixed up automatically.")

	return parser.parse_args()

def create_game_rules_entity():
	return \
	[
		("classname", "tf_gamerules"),
		("targetname", "tf_gamerules"),
		("ctf_overtime", "1"),
		("hud_type", "0"),
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
	removed = entities.remove_entities_matching_all(ent_list, classname="tf_logic_arena")

	if removed:
		print("Removed tf_logic_arena")

	return removed

def add_required_entities(ent_list):
	changed = False
	gamerules_ents = entities.find_entities_matching_all(ent_list, classname="tf_gamerules")

	if gamerules_ents:
		entity = ent_list[gamerules_ents[0]]
		targetname_index = keyvalues.find(entity, "targetname")

		if targetname_index < 0:
			print("Setting tf_gamerules targetname for VSH")
			entity.append(("targetname", "tf_gamerules"))
			changed = True
		elif entity[targetname_index][1] != "tf_gamerules":
			print(f'Updating tf_gamerules targetname for VSH from "{entity[targetname_index][1]}"')
			entity[targetname_index][1] = "tf_gamerules"
			changed = True
	else:
		print("Adding tf_gamerules for VSH")
		ent_list.append(create_game_rules_entity())
		changed = True

	if not entities.find_entities_matching_all(ent_list, classname="logic_script", vscripts="vssaxtonhale/vsh.nut"):
		print("Adding logic_script for VSH")
		ent_list.append(create_logic_script_entity())
		changed = True

	return changed

def replace_pak_lump(bsp_file, pakdata_out):
	(offset, _, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_PAKFILE)
	bsp.set_lump_descriptor(bsp_file, bsp.LUMP_INDEX_PAKFILE, offset, len(pakdata_out.getbuffer()), version, lzma_flags)

	bsp_file.seek(offset)
	bsp_file.write(pakdata_out.getbuffer())

def prepare_new_entities_lump(bsp_file, ent_list):
	# Null terminator here is important!
	serialised_entities = entities.serialise_entity_list(ent_list) + b'\x00'
	orig_length = len(serialised_entities)

	if bsp.lump_is_lzma_compressed(bsp_file, bsp.LUMP_INDEX_ENTITIES):
		serialised_entities = bsp.compress_lzma_lump(serialised_entities)

	return (serialised_entities, orig_length)

def calculcate_raw_ent_data_size_delta(bsp_file, new_lump_size):
	old_lump_size = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_ENTITIES)[1]
	return new_lump_size - old_lump_size

def write_new_entities_lump(bsp_file, ent_data, ent_orig_length):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_ENTITIES)

	size = len(ent_data)

	if lzma_flags:
		# Lump was LZMA compressed, so update this new length
		lzma_flags = ent_orig_length

	bsp_file.seek(offset)
	bsp_file.write(ent_data)

	bsp.set_lump_descriptor(bsp_file, bsp.LUMP_INDEX_ENTITIES, offset, size, version, lzma_flags)

def process_bsp(old_map_name: str, new_map_name: str, bsp_file, args):
	bsp.validate_bsp_file(bsp_file)
	bsp.validate_pakfile_lump(bsp_file)

	print("Adjusting entities")

	ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))

	removed = remove_unneeded_entities(ent_list)
	added = add_required_entities(ent_list)

	if removed or added:
		ent_data, ent_orig_length = prepare_new_entities_lump(bsp_file, ent_list)
		ent_data_size_delta = calculcate_raw_ent_data_size_delta(bsp_file, len(ent_data))

		print(f"Entities lump size changed by {'+' if ent_data_size_delta >= 0 else ''}{ent_data_size_delta} bytes")

		lump_adjustment.resize_lump(bsp_file, bsp.LUMP_INDEX_ENTITIES, ent_data_size_delta)

		print("Writing new entities lump")
		write_new_entities_lump(bsp_file, ent_data, ent_orig_length)

	if not args.no_files:
		pakdata_in = io.BytesIO(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_PAKFILE))
		pakdata_out = io.BytesIO(bytes())

		print("Compiling new list of embedded files")
		embedded_files = file_mgmt.find_files_in_pak(pakdata_in)
		disk_files = file_mgmt.find_content_files_on_disk(os.path.join(SCRIPT_DIR, "vsh_content"))
		resolved_files = file_mgmt.resolve_names(embedded_files + disk_files, old_map_name, new_map_name)

		print("Embedding files")
		file_mgmt.add_files_to_pak(resolved_files, pakdata_in, pakdata_out)
		replace_pak_lump(bsp_file, pakdata_out)

def process_file(args):
	map_file = args.map_file[0]

	if not os.path.isfile(map_file):
		print(f"Map {map_file} does not exist")
		return False

	print(f"Patching {map_file}")

	(old_map_name, map_ext) = os.path.splitext(os.path.basename(map_file))
	new_map_name = f"{old_map_name}{args.suffix}"

	with open(map_file, "rb") as bsp_file:
		data = bsp_file.read()

	try:
		bsp_file = io.BytesIO(data)
		process_bsp(old_map_name, new_map_name, bsp_file, args)

		output_name = os.path.join(os.path.dirname(map_file), f"{new_map_name}{map_ext}")

		print(f"Writing {output_name}")

		with open(output_name, "wb") as outfile:
			outfile.write(bsp_file.getbuffer())

	except Exception as ex:
		print(f"An error occured while processing the file. {ex}")
		traceback.print_exception(ex)
		return False

	return True

def main():
	args = parse_args()
	success = process_file(args)
	sys.exit(0 if success else 1)

if __name__ == "__main__":
	main()
