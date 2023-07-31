import os

from . import bsp

# When adjusting offsets, the following data items need to be taken care of:
# - Each lump's offset in the lump table
# - The offset held in each directory entry in the game lump

def __aligned_offset(offset):
	return ((offset - 1) + (4 - ((offset - 1) % 4)))

def __compute_lump_ordering_by_offset(bsp_file):
	lumps = []

	for index in range(0, bsp.LUMP_TABLE_NUM_ENTRIES):
		offset = bsp.get_lump_descriptor(bsp_file, index)[0]
		lumps.append((offset, index))

	lumps.sort(key=lambda item: item[0])
	return [item[1] for item in lumps]

def __shift_lump(bsp_file, lump_index, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, lump_index)

	if size > 0:
		lump_data = bsp.get_lump_data(bsp_file, lump_index, auto_decompress=False)
		bsp_file.seek(offset + delta)
		bsp_file.write(lump_data)

	bsp.set_lump_descriptor(bsp_file, lump_index, offset + delta, size, version, lzma_flags)

def __shift_gamelumps(bsp_file, delta):
	# TODO
	print(bsp.get_gamelumps(bsp_file))

def adjust_offsets_after_lump(bsp_file, delta, lump_index: int):
	if delta == 0:
		return

	ordered_lumps = __compute_lump_ordering_by_offset(bsp_file)

	# After manual experimentation, the following seems to be true for TF2:
	# - The final two lumps by offset are 35 (gamelumps) and 40 (pakfile)
	# - Each gamelump is included immediately after the gamelumps listing,
	#   before the pakfile lump begins.

	delta = __aligned_offset(delta)

	print(f"Adjusting BSP lump offsets by {delta} bytes (with alignment) to accommodate new entities lump")

	if delta > 0:
		# Expanding a lump, so start from last lump and work backwards
		ordered_lumps.reverse()

	apply = delta > 0

	for index in ordered_lumps:
		if ordered_lumps[index] == lump_index:
			apply = not apply
			continue

		if not apply:
			continue

		if index == bsp.LUMP_INDEX_GAMELUMPS:
			__shift_gamelumps(bsp_file, delta)
		else:
			__shift_lump(bsp_file, index, delta)

	if delta < 0:
		bsp_file.seek(delta, os.SEEK_END)
		bsp_file.truncate()
