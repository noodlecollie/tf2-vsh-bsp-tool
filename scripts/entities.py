from . import keyvalues

def build_entity_list(ent_data: bytes):
	ent_list = []
	base_offset = 0

	while True:
		try:
			(property_list, next_offset) = keyvalues.extract_single_depth_properties(ent_data, base_offset)
		except RuntimeError as ex:
			raise RuntimeError(f"{ex} for entity {len(ent_list)}")

		if next_offset < 1:
			# We reached the end.
			break

		if not keyvalues.contains_key(property_list, "classname"):
			property_list.append(("classname", "unknown_class"))

		ent_list.append(property_list)
		base_offset = next_offset

	return ent_list

def serialise_entity_list(ent_list):
	serialised_ents = [keyvalues.serialise_single_depth_properties(entity) for entity in ent_list]
	return b'\n'.join(serialised_ents)

def find_entities_matching(ent_list: list, **kwargs):
	found_ents = []

	for index in range(0, len(ent_list)):
		entity = ent_list[index]

		for key in kwargs.keys():
			value = keyvalues.get_first_value(entity, key)

			if value is None or value != kwargs[key]:
				continue

			found_ents.append(index)

	return found_ents
