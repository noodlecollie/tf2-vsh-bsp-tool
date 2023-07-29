def build_entity_list(ent_data: bytes):
	ent_list = []
	base_offset = 0

	while True:
		begin_brace = ent_data.find(b'{', base_offset)

		if begin_brace < 0:
			break

		end_brace = ent_data.find(b'}', begin_brace + 1)

		if end_brace < 0:
			raise RuntimeError(f"Unterminated definition encountered for entity {len(ent_list)}")

		entity = ent_data[(begin_brace + 1):end_brace]

		# Each property is defined as: "key" "value"\n
		properties = entity.split(b'\n')
		property_dict = {}

		for prop in properties:
			prop = prop.strip()

			if not prop:
				continue

			first_quote = prop.find(b'"', 0)

			if first_quote < 0:
				continue

			second_quote = prop.find(b'"', first_quote + 1)

			if second_quote < 0:
				raise RuntimeError(f"Unterminated property key encountered for entity {len(ent_list)}")

			third_quote = prop.find(b'"', second_quote + 1)

			if third_quote < 0:
				raise RuntimeError(f"Property without value encountered for entity {len(ent_list)}")

			fourth_quote = prop.find(b'"', third_quote + 1)

			if fourth_quote < 0:
				raise RuntimeError(f"Unterminated property value encountered for entity {len(ent_list)}")

			key = prop[(first_quote + 1):second_quote].decode("latin-1")
			value = prop[(third_quote + 1):fourth_quote].decode("latin-1")

			property_dict[key] = value

		if "classname" not in property_dict:
			property_dict["classname"] = "unknown_class"

		ent_list.append(property_dict)
		base_offset = end_brace + 1

	return ent_list

def find_entities_matching(ent_list: list, **kwargs):
	found_ents = []

	for index in range(0, len(ent_list)):
		entity = ent_list[index]

		for key in kwargs.keys():
			if key not in entity:
				continue

			if entity[key] != kwargs[key]:
				continue

			found_ents.append(index)

	return found_ents
