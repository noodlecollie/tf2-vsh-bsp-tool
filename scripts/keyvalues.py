def extract_single_depth_properties(data: bytes, base_offset: int = 0):
	begin_brace = data.find(b'{', base_offset)

	if begin_brace < 0:
		return ([], 0)

	end_brace = data.find(b'}', begin_brace + 1)

	if end_brace < 0:
		raise RuntimeError(f"Unterminated keyvalues object encountered")

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
			raise RuntimeError(f"Unterminated property key encountered")

		third_quote = prop.find(b'"', second_quote + 1)

		if third_quote < 0:
			raise RuntimeError(f"Property without value encountered")

		fourth_quote = prop.find(b'"', third_quote + 1)

		if fourth_quote < 0:
			raise RuntimeError(f"Unterminated property value encountered")

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
