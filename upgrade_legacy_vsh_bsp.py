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

def shift_lump(bsp_file, lump_index, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, lump_index)
	lump_data = bsp.get_lump_data(bsp_file, lump_index)

	bsp_file.seek(offset + delta)
	bsp_file.write(lump_data)

	bsp.set_lump_descriptor(bsp_file, lump_index, offset + delta, size, version, lzma_flags)

def aligned_offset(offset):
	return ((offset - 1) + (4 - ((offset - 1) % 4))) if offset > 0 else 0

def adjust_lump_locations(bsp_file, delta):
	if delta == 0:
		return

	if delta > 0:
		delta = aligned_offset(delta)

		print(f"Adjusting BSP lump offsets by {delta} bytes (with alignment) to accommodate new entities lump")

		# From final lump down to lump 1 (lump 0 is ignored since it is the entity lump,
		# which we deal with later when we write it). This process is in reverse,
		# because I'm not sure we can easily insert into a byte stream, but we can begin
		# from the end, expand it to make it longer, and then shuffle everything down.
		for index in range(bsp.LUMP_TABLE_NUM_ENTRIES - 1, 0, -1):
			shift_lump(bsp_file, index, delta)
	else:
		delta = -1 * aligned_offset(-delta)

		print(f"Adjusting BSP lump offsets by {delta} bytes (with alignment) to accommodate new entities lump")

		for index in range(1, bsp.LUMP_TABLE_NUM_ENTRIES):
			shift_lump(bsp_file, index, delta)

		bsp_file.seek(delta, os.SEEK_END)
		bsp_file.truncate()

def write_new_entities_lump(bsp_file, ent_data, ent_orig_length):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_ENTITIES)

	size = len(ent_data)

	if lzma_flags:
		# Lump was LZMA compressed, so update this new length
		lzma_flags = ent_orig_length

	bsp_file.seek(offset)
	bsp_file.write(ent_data)

	bsp.set_lump_descriptor(bsp_file, bsp.LUMP_INDEX_ENTITIES, offset, size, version, lzma_flags)

def process_bsp(map_name: str, bsp_file):
	bsp.validate_bsp_file(bsp_file)
	bsp.validate_pakfile_lump(bsp_file)

	pakdata_in = io.BytesIO(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_PAKFILE))
	pakdata_out = io.BytesIO(bytes())

	print("Compiling new list of embedded files")
	embedded_file_list = generate_file_list(find_files_in_pak(pakdata_in), find_content_files_on_disk())

	print("Embedding files")
	add_files_to_pak(embedded_file_list, pakdata_in, pakdata_out, map_name)
	replace_pak_lump(bsp_file, pakdata_out)

	print("Adjusting entities")

	ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))
	remove_unneeded_entities(ent_list)
	add_required_entities(ent_list)

	ent_data, ent_orig_length = prepare_new_entities_lump(bsp_file, ent_list)
	ent_data_size_delta = calculcate_raw_ent_data_size_delta(bsp_file, len(ent_data))

	print(f"Entities lump size changed by {'+' if ent_data_size_delta >= 0 else ''}{ent_data_size_delta} bytes")

	adjust_lump_locations(bsp_file, ent_data_size_delta)

	print("Writing new entities lump")
	write_new_entities_lump(bsp_file, ent_data, ent_orig_length)

	# TODO: Remove after testing
	with open("test.bsp", "wb") as outfile:
		outfile.write(bsp_file.getbuffer())

def process_file(map_file: str):
	if not os.path.isfile(map_file):
		print(f"Map {map_file} does not exist")
		return False

	print(f"Patching {map_file}")

	map_name = os.path.splitext(os.path.basename(map_file))[0]

	with open(map_file, "rb") as bsp_file:
		data = bsp_file.read()

	try:
		process_bsp(map_name, io.BytesIO(data))
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
