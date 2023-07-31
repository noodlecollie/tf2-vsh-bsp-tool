import os
import struct

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

def __compute_gamelump_ordering_by_offset(gamelump_data, num_gamelumps):
	lumps = []

	for index in range(0, num_gamelumps):
		offset = struct.unpack_from(
			bsp.LUMP_GAMELUMPS_DIRENT_FMT,
			gamelump_data,
			index * struct.calcsize(bsp.LUMP_GAMELUMPS_DIRENT_FMT))[3]

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

def __shift_gamelump_data(bsp_file, delta, gamelump_data, num_gamelumps):
	ordered_lumps = __compute_gamelump_ordering_by_offset(gamelump_data, num_gamelumps)

	if delta > 0:
		# Expanding a lump, so start from last lump and work backwards
		ordered_lumps.reverse()

	updated_gamelump_data = [b""] * num_gamelumps

	for index in ordered_lumps:
		(id, flags, version, offset, length) = struct.unpack_from(
			bsp.LUMP_GAMELUMPS_DIRENT_FMT,
			gamelump_data,
			index * struct.calcsize(bsp.LUMP_GAMELUMPS_DIRENT_FMT))

		bsp_file.seek(offset)
		data = bsp_file.read(length)

		bsp_file.seek(offset + delta)
		bsp_file.write(data)

		updated_gamelump_data[index] = struct.pack(
			bsp.LUMP_GAMELUMPS_DIRENT_FMT,
			id,
			flags,
			version,
			offset + delta,
			length)

	return b"".join(updated_gamelump_data)

def __shift_gamelumps(bsp_file, delta):
	(offset, size, version, lzma_flags) = bsp.get_lump_descriptor(bsp_file, bsp.LUMP_INDEX_GAMELUMPS)

	if lzma_flags:
		raise NotImplementedError("LZMA-compressed gamelump data is not currently supported")

	if size > 0:
		bsp_file.seek(offset)
		num_gamelumps = struct.unpack(bsp.LUMP_GAMELUMPS_FMT, bsp_file.read(struct.calcsize(bsp.LUMP_GAMELUMPS_FMT)))[0]
		gamelump_data = bsp_file.read(num_gamelumps * struct.calcsize(bsp.LUMP_GAMELUMPS_DIRENT_FMT))

		new_gamelump_data = __shift_gamelump_data(bsp_file, delta, gamelump_data, num_gamelumps)

		if len(new_gamelump_data) != len(gamelump_data):
			raise AssertionError(
				f"Expected new gamelump data to be {len(gamelump_data)} bytes in size, " +
				f"but it was {len(new_gamelump_data)} bytes")

		new_lump_data = struct.pack(bsp.LUMP_GAMELUMPS_FMT, num_gamelumps) + new_gamelump_data

		bsp_file.seek(offset + delta)
		bsp_file.write(new_lump_data)

	bsp.set_lump_descriptor(bsp_file, bsp.LUMP_INDEX_GAMELUMPS, offset + delta, size, version, lzma_flags)

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
