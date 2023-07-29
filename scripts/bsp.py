import struct
import lzma

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

LZMA_LUMP_FMT = "<IIIBBBBB"
LZMA_TARGET_FMT = "<BBBBBQ"

LUMP_INDEX_ENTITIES = 0
LUMP_INDEX_PAKFILE = 40

def __index_of_lump_with_largest_offset(bsp_file):
	largest_offset = -1
	index_of_largest_offset = 0

	for index in range(0, LUMP_TABLE_NUM_ENTRIES):
		offset = get_lump_descriptor(bsp_file, index)[0]

		if offset > largest_offset:
			largest_offset = offset
			index_of_largest_offset = index

	return index_of_largest_offset

def __decompress_lzma_lump(data):
	(_, actual_size, _, prop0, prop1, prop2, prop3, prop4) = struct.unpack_from(LZMA_LUMP_FMT, data, 0)
	genuine_lzma_header = struct.pack(LZMA_TARGET_FMT, prop0, prop1, prop2, prop3, prop4, actual_size)

	return lzma.decompress(genuine_lzma_header + data[struct.calcsize(LZMA_LUMP_FMT):])

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

def validate_pakfile_lump(bsp_file):
	final_lump_index = __index_of_lump_with_largest_offset(bsp_file)

	# We only support BSPs where the Pakfile lump is the final lump
	# (according to the VDC wiki, this is normally the case).
	# Since we need to add new files to this lump, we wouldn't want
	# to go changing the offsets of any lumps after it.
	if final_lump_index != LUMP_INDEX_PAKFILE:
		raise NotImplementedError(
			"The Pakfile (embedded content) lump is not the final lump in the BSP file " +
			f" (lump {final_lump_index} is instead). " +
			"BSP files with this data layout are not currently supported.")

def get_lump_descriptor(bsp_file, index: int):
	if index < 0 or index >= LUMP_TABLE_NUM_ENTRIES:
		raise IndexError(f"Lump index {index} was out of range")

	bsp_file.seek(LUMP_TABLE_OFFSET + (index * struct.calcsize(LUMP_FMT)))
	data = bsp_file.read(struct.calcsize(LUMP_FMT))
	return struct.unpack(LUMP_FMT, data)

def get_lump_data(bsp_file, index: int):
	(offset, length, _, lzma_flags) = get_lump_descriptor(bsp_file, index)
	bsp_file.seek(offset)
	data = bsp_file.read(length)

	return __decompress_lzma_lump(data) if lzma_flags else data
