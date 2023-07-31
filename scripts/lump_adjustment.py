import os
import struct

from . import bsp

# When adjusting offsets, the following data items need to be taken care of:
# - Each lump's offset in the lump table
# - The offset held in each directory entry in the game lump

def __aligned_offset(offset):
	return ((offset - 1) + (4 - ((offset - 1) % 4)))

def __compute_lump_ordering_by_offset(bsp_file, base_lump_index):
	lumps = []

	for index in range(0, bsp.LUMP_TABLE_NUM_ENTRIES):
		offset = bsp.get_lump_descriptor(bsp_file, index)[0]
		lumps.append((offset, index))

	lumps.sort(key=lambda item: item[0])
	lumps = [item[1] for item in lumps]

	index_of_base_lump = lumps.index(base_lump_index)

	if index_of_base_lump >= 0:
		# Return everything after this lump
		return lumps[(index_of_base_lump + 1):]
	else:
		return lumps

def __adjust_lump_offset(bsp_file, lump_index, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, lump_index)
	bsp.set_lump_descriptor(bsp_file, lump_index, offset + delta, size, version, lzma_flags)

def __adjust_gamelump_offsets(bsp_file, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_GAMELUMPS)

	if lzma_flags:
		raise NotImplementedError("LZMA-compressed gamelump data is not currently supported")

	if size > 0:
		bsp_file.seek(offset)
		num_gamelumps = struct.unpack(bsp.LUMP_GAMELUMPS_FMT, bsp_file.read(struct.calcsize(bsp.LUMP_GAMELUMPS_FMT)))[0]

		for _ in range(0, num_gamelumps):
			current_pos = bsp_file.tell()

			gl_data = bsp_file.read(struct.calcsize(bsp.LUMP_GAMELUMPS_DIRENT_FMT))
			(gl_id, gl_flags, gl_version, gl_offset, gl_length) =  struct.unpack(bsp.LUMP_GAMELUMPS_DIRENT_FMT, gl_data)

			bsp_file.seek(current_pos)

			bsp_file.write(
				struct.pack(bsp.LUMP_GAMELUMPS_DIRENT_FMT, gl_id, gl_flags, gl_version, gl_offset + delta, gl_length))

	bsp.set_lump_descriptor(bsp_file, bsp.LUMP_INDEX_GAMELUMPS, offset + delta, size, version, lzma_flags)

def __adjust_offsets_after_lump(bsp_file, base_lump_index: int, delta: int):
	# After manual experimentation, the following seems to be true for TF2:
	# - The final two lumps by offset are 35 (gamelumps) and 40 (pakfile)
	# - Each gamelump is included immediately after the gamelumps listing,
	#   before the pakfile lump begins.
	# This means no special case behavious is required for gamelumps.

	ordered_lumps = __compute_lump_ordering_by_offset(bsp_file, base_lump_index)

	for index in ordered_lumps:
		if index == bsp.LUMP_INDEX_GAMELUMPS:
			__adjust_gamelump_offsets(bsp_file, delta)
		else:
			__adjust_lump_offset(bsp_file, index, delta)

def resize_lump(bsp_file, lump_index: int, delta: int):
	if delta == 0:
		return

	(offset, length, version, flags) = bsp.get_lump_descriptor(bsp_file, lump_index)

	if length + delta < 0:
		raise ValueError(f"Cannot reduce a lump of length {length} by a delta of {delta}")

	actual_delta = __aligned_offset(delta)

	print(f"Adjusting BSP lump offsets by {actual_delta} bytes (with alignment) to accommodate new entities lump")
	__adjust_offsets_after_lump(bsp_file, lump_index, actual_delta)

	bsp_file.seek(offset + length)
	rest_of_data = bsp_file.read()

	length += actual_delta

	bsp_file.seek(offset + length)
	bsp_file.write(rest_of_data)

	if actual_delta < 0:
		# The file got shorter, so trim it.
		bsp_file.seek(actual_delta, os.SEEK_END)
		bsp_file.truncate()

	bsp.set_lump_descriptor(bsp_file, lump_index, offset, length, version, flags)
