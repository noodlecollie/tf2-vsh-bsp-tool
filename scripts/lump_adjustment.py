import os

from . import bsp

def __aligned_offset(offset):
	return ((offset - 1) + (4 - ((offset - 1) % 4))) if offset > 0 else 0

def __shift_lump(bsp_file, lump_index, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, lump_index)
	lump_data = bsp.get_lump_data(bsp_file, lump_index)

	bsp_file.seek(offset + delta)
	bsp_file.write(lump_data)

	bsp.set_lump_descriptor(bsp_file, lump_index, offset + delta, size, version, lzma_flags)

def adjust_non_entity_lump_locations(bsp_file, delta):
	if delta == 0:
		return

	if delta > 0:
		delta = __aligned_offset(delta)

		print(f"Adjusting BSP lump offsets by {delta} bytes (with alignment) to accommodate new entities lump")

		# From final lump down to lump 1 (lump 0 is ignored since it is the entity lump,
		# which we deal with later when we write it). This process is in reverse,
		# because I'm not sure we can easily insert into a byte stream, but we can begin
		# from the end, expand it to make it longer, and then shuffle everything down.
		for index in range(bsp.LUMP_TABLE_NUM_ENTRIES - 1, 0, -1):
			__shift_lump(bsp_file, index, delta)
	else:
		delta = -1 * __aligned_offset(-delta)

		print(f"Adjusting BSP lump offsets by {delta} bytes (with alignment) to accommodate new entities lump")

		for index in range(1, bsp.LUMP_TABLE_NUM_ENTRIES):
			__shift_lump(bsp_file, index, delta)

		bsp_file.seek(delta, os.SEEK_END)
		bsp_file.truncate()
