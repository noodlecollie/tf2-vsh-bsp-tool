import os
import zipfile
import re

from . import keyvalues, pak

class PakFile:
	def __init__(self, out_path, disk_path=None):
		self.out_pak_path = out_path
		self.in_pak_path = out_path if disk_path is None else ""
		self.in_disk_path = disk_path if disk_path is not None else ""
		self.merge_function = None
		self.patch_function = None
		self.patch_replacements = {}

	def basename_matches_suffix(self, map_name: str, suffix: str):
		basename = os.path.splitext(os.path.basename(self.out_pak_path))[0]

		# If the name doesn't exactly match what we're looking for,
		# but the file is on disk, we accept a slightly weaker match.
		# This allows us to name things eg. MAP_NAME_level_sounds.txt
		# on disk and still have this resolve to the intended name.
		return basename == f"{map_name}{suffix}" or \
			self.in_disk_path and basename.endswith(suffix)

	def basename_matches_prefix(self, map_name: str, prefix: str):
		basename = os.path.splitext(os.path.basename(self.out_pak_path))[0]

		# If the name doesn't exactly match what we're looking for,
		# but the file is on disk, we accept a slightly weaker match.
		# This allows us to name things eg. soundscapes_MAP_NAME.txt
		# on disk and still have this resolve to the intended name.
		return basename == f"{prefix}{map_name}" or \
			self.in_disk_path and basename.startswith(prefix)

	def is_multi_source(self):
		return self.in_pak_path and self.in_disk_path

	def can_merge(self):
		return self.merge_function is not None

	def can_patch(self):
		return self.patch_function is not None

def __makepath(path):
	return path.replace("/", os.path.sep)

def __read_from_disk(path: str):
	if not os.path.isfile(path):
		return bytes()

	with open(path, "rb") as infile:
		return infile.read()

def __read_item(pakzip_in, item: PakFile):
	if item.in_disk_path:
		return __read_from_disk(item.in_disk_path)
	elif item.in_pak_path:
		return pak.get_file_data(pakzip_in, item.in_pak_path)
	else:
		return AssertionError(f"File {item.out_pak_path} had no source path")

def __create_multi_source_file(existing_file: PakFile, new_file: PakFile):
	if existing_file.in_disk_path and new_file.in_disk_path:
		raise ValueError(
			f"File {existing_file.out_pak_path} mapped to two locations on disk: " +
			f"{existing_file.in_disk_path} and {new_file.in_disk_path}")

	if existing_file.in_pak_path and new_file.in_pak_path:
		raise ValueError(
			f"File {existing_file.out_pak_path} mapped to two locations in input pakfile lump: " +
			f"{existing_file.in_pak_path} and {new_file.in_pak_path}")

	if not existing_file.in_disk_path:
		existing_file.in_disk_path = new_file.in_disk_path

	if not existing_file.in_pak_path:
		existing_file.in_pak_path = new_file.in_pak_path

def __merge_level_sounds_txt_data(existing_data: bytes, new_data: bytes):
	try:
		new_objects = { item[0]: item for item in keyvalues.find_all_root_objects(new_data) }
	except ValueError as ex:
		raise ValueError(f"{ex} in the VSH game mode's level_sounds.txt")

	offset = 0
	allowed_existing_objects = []

	while True:
		try:
			existing_object = keyvalues.find_root_object(existing_data, offset)
			print(existing_object)
		except ValueError as ex:
			raise ValueError(f"{ex} in the map's existing level_sounds.txt")

		if existing_object[0] is None:
			break

		# Ignore if this data exists in the incoming data - new data takes precedence.
		if existing_object[0] not in new_objects:
			allowed_existing_objects.append(existing_object)

		offset = existing_object[2] + 1

	output = []

	for (key, opening_brace, closing_brace) in allowed_existing_objects:
		output.append(b'"' + key + b'"\n' + existing_data[opening_brace:(closing_brace + 1)] + b'\n')

	for dictkey in new_objects.keys():
		(key, opening_brace, closing_brace) = new_objects[dictkey]
		output.append(b'"' + key + b'"\n' + new_data[opening_brace:(closing_brace + 1)] + b'\n')

	return b'\n'.join(output)

def __merge_particles_txt_data(existing_data: bytes, new_data: bytes):
	# For particles, we need to merge the two particles_manifest objects together.

	if not existing_data:
		return new_data

	if not new_data:
		return existing_data

	ENTRY_NAME = b"particles_manifest"

	existing_manifest = existing_data.find(ENTRY_NAME)

	if existing_manifest < 0:
		if not existing_data.strip():
			# Nothing to merge, so just return the new data.
			return new_data

		# Should never happen, and if it does, we have no idea what's going on.
		# Best not to nuke whatever is here.
		raise RuntimeError("No particles_manifest entry found in map's existing particles.txt")

	new_manifest = new_data.find(ENTRY_NAME)

	if new_manifest < 0:
		# This should never happen if the VSH mode is set up properly.
		raise RuntimeError("No particles_manifest entry found in the VSH game mode's particles.txt")

	try:
		(existing_particle_entries, _) = keyvalues.extract_single_depth_properties(existing_data, existing_manifest + len(ENTRY_NAME))
	except ValueError as ex:
		raise ValueError(f"{ex} in map's existing particles.txt")

	try:
		(new_particle_entries, _) = keyvalues.extract_single_depth_properties(new_data, new_manifest + len(ENTRY_NAME))
	except ValueError as ex:
		raise ValueError(f"{ex} in the VSH game mode's particles.txt")

	combined_entries = existing_particle_entries + new_particle_entries
	keyvalues.remove_duplicate_values(combined_entries)

	return b"particles_manifest\n" + keyvalues.serialise_single_depth_properties(combined_entries, indent=1) + b"\n"

def __patch_cubemap_vmt_data(item: PakFile, data: bytes):
	lines = data.split(b'\n')

	for index in range(0, len(lines)):
		line = lines[index]

		for key in item.patch_replacements.keys():
			value = item.patch_replacements[key]

			key_bytes = b'"' + key.encode("latin-1") + b'"'
			find_bytes = value[0].encode("latin-1")
			replace_bytes = value[1].encode("latin-1")

			if line.find(key_bytes) >= 0:
				lines[index] = line.replace(find_bytes, replace_bytes)

	return b'\n'.join(lines)

def find_content_files_on_disk(content_path: str):
	out_list = []

	for (dirpath, _, filenames) in os.walk(content_path):
		dir_in_pak = os.path.relpath(dirpath, content_path)

		for filename in filenames:
			file_path_on_disk = os.path.join(dirpath, filename)
			file_path_in_pak = os.path.join(dir_in_pak, filename)

			out_list.append(PakFile(file_path_in_pak, disk_path=file_path_on_disk))

	return out_list

def find_files_in_pak(pakdata_in):
	with zipfile.ZipFile(pakdata_in, mode="r") as pakzip_in:
		return [ PakFile(item.replace("/", os.path.sep)) for item in pakzip_in.namelist() ]

def resolve_names(file_list, old_map_name, new_map_name):
	cubemap_path_prefix = __makepath(f"materials/maps/{old_map_name}")
	new_cubemap_path_prefix = __makepath(f"materials/maps/{new_map_name}")
	soundscape_path_prefix = __makepath("scripts")
	map_manifest_path_prefix = __makepath("maps")
	particles_path_prefix = __makepath("particles")

	# Catches files with <number>_<number>_<number> at the end of their name
	re_cubemap = re.compile(r".+-?\d+_-?\d+_-?\d+(\.hdr)?$")

	encountered_files = {}

	for item in file_list:
		(basename, extension) = os.path.splitext(os.path.basename(item.out_pak_path))
		dirname = os.path.dirname(item.out_pak_path)

		new_path = None

		if extension == ".txt":
			# maps/
			if dirname.startswith(map_manifest_path_prefix):
				if item.basename_matches_suffix(old_map_name, "_level_sounds"):
					new_path = os.path.join(dirname, f"{new_map_name}_level_sounds{extension}")
					item.merge_function = __merge_level_sounds_txt_data
				elif item.basename_matches_suffix(old_map_name, "_particles"):
					new_path = os.path.join(dirname, f"{new_map_name}_particles{extension}")
					item.merge_function = __merge_particles_txt_data
			# particles/
			elif dirname.startswith(particles_path_prefix):
				if item.basename_matches_suffix(old_map_name, "_manifest"):
					new_path = os.path.join(dirname, f"{new_map_name}_manifest{extension}")
					item.merge_function = __merge_particles_txt_data
			# scripts/
			elif dirname.startswith(soundscape_path_prefix):
				if item.basename_matches_prefix(old_map_name, "soundscapes_"):
					new_path = os.path.join(dirname, f"soundscapes_{new_map_name}{extension}")
		elif extension in [".vtf", ".vmt"]:
			# materials/maps/map_name/
			if dirname.startswith(cubemap_path_prefix):
				if re_cubemap.match(basename):
					if extension == ".vmt":
						item.patch_function = __patch_cubemap_vmt_data

						# Replace the map name in the expected paths only (ie. match the surrounding separators too)
						item.patch_replacements = {"$envmap": (f"/{old_map_name}/", f"/{new_map_name}/")}
					else:
						new_path = new_cubemap_path_prefix + item.out_pak_path[len(cubemap_path_prefix):]

		if new_path is not None:
			item.out_pak_path = new_path

		if item.out_pak_path in encountered_files:
			__create_multi_source_file(encountered_files[item.out_pak_path], item)
		else:
			encountered_files[item.out_pak_path] = item

	return [encountered_files[key] for key in encountered_files.keys()]

def add_files_to_pak(file_list, pakdata_in, pakdata_out):
	with zipfile.ZipFile(pakdata_out, mode="w") as pakzip_out:
		with zipfile.ZipFile(pakdata_in, mode="r") as pakzip_in:
			for item in file_list:
				if item.can_merge() and item.is_multi_source():
					# These will provide empty byte arrays if the files are not found.
					existing_data = pak.get_file_data(pakzip_in, item.in_pak_path)
					new_data = __read_from_disk(item.in_disk_path)

					print(f"Merging {item.out_pak_path}:")
					print(f"  + {item.in_pak_path}")
					print(f"  + {item.in_disk_path}")

					pak.try_write_data(pakzip_out, item.out_pak_path, item.merge_function(existing_data, new_data))

					continue

				data = __read_item(pakzip_in, item)

				if item.can_patch():
					if item.in_disk_path or item.out_pak_path == item.in_pak_path:
						print(f"Patching {item.out_pak_path}")
					else:
						print(f"Patching and renaming {item.in_pak_path} -> {item.out_pak_path}")
				elif item.in_disk_path:
					print(f"Embedding {item.out_pak_path}")
				else:
					if item.out_pak_path != item.in_pak_path:
						print(f"Renaming {item.in_pak_path} -> {item.out_pak_path}")
					else:
						print(f"Retaining {item.out_pak_path}")

				if item.can_patch():
					data = item.patch_function(item, data)

				pak.try_write_data(pakzip_out, item.out_pak_path, data)
