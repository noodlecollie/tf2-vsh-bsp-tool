import argparse
import os
import sys
import traceback
import io
import zipfile

from scripts import bsp, entities, keyvalues, file_merge, pak, lump_adjustment

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

def parse_args():
	parser = argparse.ArgumentParser(
		prog="upgrade_legacy_vsh_bsp",
		description="Updates a legacy VSH (Arena) map to use the new community VSH game mode.")

	parser.add_argument("map_file",
		nargs=1,
		help="Paths to more map file that should be updated.")

	parser.add_argument("-x", "--no-files",
		action="store_true",
		help="Don't add files, just update entities")

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

def merge_level_sounds_txt(pakzip_in, archive_file_path: str, disk_file_path: str):
	existing_data = pak.get_file_data(pakzip_in, archive_file_path)
	new_data = bytes()

	if os.path.isfile(disk_file_path):
		with open(disk_file_path, "rb") as infile:
			new_data = infile.read()

	return file_merge.merge_level_sounds_txt_data(existing_data, new_data)

def merge_particles_txt(pakzip_in, archive_file_path: str, disk_file_path: str):
	existing_data = pak.get_file_data(pakzip_in, archive_file_path.replace("\\", "/"))
	new_data = bytes()

	if os.path.isfile(disk_file_path):
		with open(disk_file_path, "rb") as infile:
			new_data = infile.read()

	return file_merge.merge_particles_txt_data(existing_data, new_data)

def merge_files(pakzip_in, pakzip_out, map_name: str, path_on_disk: str, path_in_pak: str):
	filename = os.path.basename(path_on_disk)
	dir_in_pak = os.path.dirname(path_in_pak)

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
	return target_path

def file_requires_merge(pak_path: str):
	return os.path.dirname(pak_path) == "maps" and \
		(pak_path.endswith("level_sounds.txt") or pak_path.endswith("particles.txt"))

def find_content_files_on_disk():
	content_path = os.path.join(SCRIPT_DIR, "vsh_content")
	out_dict = {}

	for (dirpath, dirnames, filenames) in os.walk(content_path):
		dir_in_pak = os.path.relpath(dirpath, content_path)

		for filename in filenames:
			file_path_on_disk = os.path.join(dirpath, filename)
			file_path_in_pak = os.path.join(dir_in_pak, filename)

			out_dict[file_path_in_pak] = file_path_on_disk

	return out_dict

def find_files_in_pak(pakdata_in):
	with zipfile.ZipFile(pakdata_in, mode="r") as pakzip_in:
		# The disk path here is just an empty string, so that we
		# know later on that this file came from the BSP's existing pakfile lump.
		return { item.replace("/", os.path.sep): "" for item in pakzip_in.namelist() }

def generate_file_list(pak_dict, disk_dict):
	merged_dict = dict(pak_dict)

	for pak_path in disk_dict.keys():
		if pak_path in merged_dict:
			print(f"Overriding {pak_path} in BSP with {disk_dict[pak_path]} on disk")

		merged_dict[pak_path] = disk_dict[pak_path]

	return [(key, merged_dict[key]) for key in merged_dict.keys()]

def add_files_to_pak(file_list, pakdata_in, pakdata_out, map_name: str):
	with zipfile.ZipFile(pakdata_out, mode="w") as pakzip_out:
		with zipfile.ZipFile(pakdata_in, mode="r") as pakzip_in:
			requires_merge = {}

			for (pak_path, disk_path) in file_list:
				if file_requires_merge(pak_path):
					# Requires a merge - deal with this later.
					# Record if we haven't yet recorded this file, or if we did
					# record it from the BSP rather than from disk.
					if pak_path not in requires_merge or disk_path:
						requires_merge[pak_path] = disk_path

					continue

				if disk_path:
					print(f"Embedding {pak_path}")
					pak.try_write_disk_file(pakzip_out, disk_path, pak_path)
				else:
					# This file existed in the original BSP - copy it across.
					print(f"Retaining {pak_path}")
					pak.try_write_data(pakzip_out, pak_path, pak.get_file_data(pakzip_in, pak_path))

			computed_paths = []

			# First pass: deal with files we know we have on disk.
			for pak_path in requires_merge.keys():
				disk_path = requires_merge[pak_path]

				if not disk_path:
					continue

				computed_paths.append(merge_files(pakzip_in, pakzip_out, map_name, disk_path, pak_path))

			for path in computed_paths:
				if path in requires_merge:
					del requires_merge[path]

			# Second pass: copy any remaining files from BSP.
			# These are files which *could* have been required to be merged,
			# but we actually didn't have anything on disk to merge with.
			for pak_path in requires_merge.keys():
				disk_path = requires_merge[pak_path]

				if disk_path:
					continue

				print(f"Retaining {pak_path}")
				pak.try_write_data(pakzip_out, pak_path, pak.get_file_data(pakzip_in, pak_path))

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

def process_bsp(map_name: str, bsp_file, args):
	bsp.validate_bsp_file(bsp_file)
	bsp.validate_pakfile_lump(bsp_file)

	pakdata_in = io.BytesIO(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_PAKFILE))
	pakdata_out = io.BytesIO(bytes())

	if not args.no_files:
		print("Compiling new list of embedded files")
		embedded_file_list = generate_file_list(find_files_in_pak(pakdata_in), find_content_files_on_disk())

		print("Embedding files")
		add_files_to_pak(embedded_file_list, pakdata_in, pakdata_out, map_name)
		replace_pak_lump(bsp_file, pakdata_out)

	print("Adjusting entities")

	ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))

	removed = remove_unneeded_entities(ent_list)
	added = add_required_entities(ent_list)

	if removed or added:
		ent_data, ent_orig_length = prepare_new_entities_lump(bsp_file, ent_list)
		ent_data_size_delta = calculcate_raw_ent_data_size_delta(bsp_file, len(ent_data))

		print(f"Entities lump size changed by {'+' if ent_data_size_delta >= 0 else ''}{ent_data_size_delta} bytes")

		lump_adjustment.adjust_offsets_after_lump(bsp_file, ent_data_size_delta, bsp.LUMP_INDEX_ENTITIES)

		print("Writing new entities lump")
		write_new_entities_lump(bsp_file, ent_data, ent_orig_length)

def process_file(args):
	map_file = args.map_file[0]

	if not os.path.isfile(map_file):
		print(f"Map {map_file} does not exist")
		return False

	print(f"Patching {map_file}")

	map_name = os.path.splitext(os.path.basename(map_file))[0]

	with open(map_file, "rb") as bsp_file:
		data = bsp_file.read()

	try:
		bsp_file = io.BytesIO(data)
		process_bsp(map_name, bsp_file, args)

		output_name = os.path.join(os.path.dirname(map_file), f"{map_name}_cu.bsp")

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
