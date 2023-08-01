def extract_single_depth_properties(data: bytes, base_offset: int = 0):
	begin_brace = data.find(b'{', base_offset)

	if begin_brace < 0:
		return ([], 0)

	end_brace = data.find(b'}', begin_brace + 1)

	if end_brace < 0:
		raise ValueError(f"Unterminated keyvalues object encountered")

	kvobject = data[(begin_brace + 1):end_brace]

	# Each property is defined as: "key" "value"\n
	properties = kvobject.split(b'\n')
	out_list = []

	for prop in properties:
		prop = prop.strip()

		if not prop:
			continue

		first_quote = prop.find(b'"', 0)

		if first_quote < 0:
			continue

		second_quote = prop.find(b'"', first_quote + 1)

		if second_quote < 0:
			raise ValueError(f"Unterminated property key encountered")

		third_quote = prop.find(b'"', second_quote + 1)

		if third_quote < 0:
			raise ValueError(f"Property without value encountered")

		fourth_quote = prop.find(b'"', third_quote + 1)

		if fourth_quote < 0:
			raise ValueError(f"Unterminated property value encountered")

		key = prop[(first_quote + 1):second_quote].decode("latin-1")
		value = prop[(third_quote + 1):fourth_quote].decode("latin-1")

		out_list.append((key, value))

	return (out_list, end_brace + 1)

def serialise_single_depth_properties(kv_list, indent=0):
	indent_str = b"\t" * indent

	entry_strings = [(indent_str + b'"' + entry[0].encode("latin-1") + b'" "' + entry[1].encode("latin-1") + b'"') for entry in kv_list]

	return b"{\n" + b'\n'.join(entry_strings) + b"\n}"

def contains_key(props_list, key:str):
	return find(props_list, key) >= 0

def find(props_list, key:str, base: int = 0):
	for index in range(0 if base < 0 else base, len(props_list)):
		if props_list[index][0] == key:
			return index

	return -1

def get_first_value(props_list, key:str, default_val = None):
	index = find(props_list, key, 0)

	return props_list[index][1] if index >= 0 else default_val

def remove_duplicate_values(props_list):
	index = 0
	encountered_values = {}

	while index < len(props_list):
		prop = props_list[index]

		if prop[1] in encountered_values:
			del props_list[index]
		else:
			encountered_values[prop[1]] = True
			index += 1

def find_opening_and_closing_braces(data: bytes, offset: int = 0):
	opening_index = data.find(b'{', offset)

	if opening_index < 0:
		return (-1, -1)

	closing_index = opening_index + 1
	depth = 1

	while closing_index < len(data):
		value = data[closing_index]

		# This is not actually a character or a string - it's a number.
		# The easiest way to check it is just to index the byte strings
		# like below to retrieve the character value.
		if value == b'{'[0]:
			depth += 1
		elif value == b'}'[0]:
			depth -= 1

		if depth == 0:
			return (opening_index, closing_index)

		closing_index += 1

	return (-1, -1)

def find_root_key(data: bytes, offset: int = 0):
	first_quote = data.find(b'"', offset)

	if first_quote < 0:
		return (None, -1)

	second_quote = data.find(b'"', first_quote + 1)

	if second_quote < 0:
		raise ValueError("Unterminated quoted key encountered")

	return (data[(first_quote + 1):second_quote], second_quote + 1)

def find_root_object(data: bytes, offset: int):
	(key, continue_from) = find_root_key(data, offset)

	if key is None:
		return (None, -1, -1)

	(opening, closing) = find_opening_and_closing_braces(data, continue_from)

	if opening < 0:
		raise ValueError("Root key encountered without corresponding object")

	return (key, opening, closing)

def find_all_root_keys(data: bytes):
	key_list = []
	offset = 0

	while True:
		(key, _, closing_brace) = find_root_object(data, offset)

		if key is None:
			break

		key_list.append(key)
		offset = closing_brace + 1

	return key_list

def find_all_root_objects(data: bytes):
	object_list = []
	offset = 0

	while True:
		object = find_root_object(data, offset)

		if object[0] is None:
			break

		object_list.append(object)
		offset = object[2] + 1

	return object_list
