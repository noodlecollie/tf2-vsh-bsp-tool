from . import keyvalues

def merge_level_sounds_txt_data(existing_data: bytes, new_data: bytes):
	# For level sounds, there is no root object. We can simply concatenate with a newline.
	return existing_data + b'\n' + new_data

def merge_particles_txt_data(existing_data: bytes, new_data: bytes):
	# For particles, we need to merge the two particles_manifest objects together.

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
		existing_particle_entries = keyvalues.extract_single_depth_properties(existing_data, existing_manifest + len(ENTRY_NAME))
	except RuntimeError as ex:
		raise RuntimeError(f"{ex} in map's existing particles.txt")

	try:
		new_particle_entries = keyvalues.extract_single_depth_properties(new_data, new_manifest + len(ENTRY_NAME))
	except RuntimeError as ex:
		raise RuntimeError(f"{ex} in the VSH game mode's particles.txt")

	combined_entries = existing_particle_entries + new_particle_entries
	entry_strings = [(b'\t"' + entry[0] + b'"\t"' + entry[1] + b'"') for entry in combined_entries]

	return b"particles_manifest\n{\n" + b'\n'.join(entry_strings) + b"\n}\n"
