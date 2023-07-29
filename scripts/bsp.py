import struct

# Format info taken from https://developer.valvesoftware.com/wiki/BSP_(Source_1)

VBSP_IDENT = 0x50534256
VBSP_IDENT_FMT = "<i"
VBSP_IDENT_OFFSET = 0

VBSP_VERSION = 20
VBSP_VERSION_FMT = "<i"
VBSP_VERSION_OFFSET = 4

LUMP_TABLE_OFFSET = 8
LUMP_TABLE_NUM_ENTRIES = 64
LUMP_FMT = "<iiii"

LUMP_INDEX_ENTITIES = 0

def validate_bsp_file(bsp_file):
	bsp_file.seek(VBSP_IDENT_OFFSET)
	data = bsp_file.read(struct.calcsize(VBSP_IDENT_FMT))
	ident = struct.unpack(VBSP_IDENT_FMT, data)[0]

	if ident != VBSP_IDENT:
		raise RuntimeError("Main BSP identifier was incorrect. This may not be a valid BSP file.")

	bsp_file.seek(VBSP_VERSION_OFFSET)
	data = bsp_file.read(struct.calcsize(VBSP_VERSION_FMT))
	version = struct.unpack(VBSP_VERSION_FMT, data)[0]

	if version != VBSP_VERSION:
		raise RuntimeError(
			f"BSP version was incorrect (expected {VBSP_VERSION} but got {version}). " +
			"This is probably not a TF2 map.")

	lump = get_lump_descriptor(bsp_file, LUMP_INDEX_ENTITIES)

	# If this is not a zero string, it means compression is present.
	if lump[3] != 0:
		raise NotImplementedError("Support for maps with LZMA compressed entity lumps has not yet been added.")

def get_lump_descriptor(bsp_file, index: int):
	if index < 0 or index >= LUMP_TABLE_NUM_ENTRIES:
		raise IndexError(f"Lump index {index} was out of range")

	bsp_file.seek(LUMP_TABLE_OFFSET + (index * struct.calcsize(LUMP_FMT)))
	data = bsp_file.read(struct.calcsize(LUMP_FMT))
	return struct.unpack(LUMP_FMT, data)

def get_lump_data(bsp_file, index: int):
	(offset, length, _, _) = get_lump_descriptor(bsp_file, index)
	bsp_file.seek(offset)
	return bsp_file.read(length)
