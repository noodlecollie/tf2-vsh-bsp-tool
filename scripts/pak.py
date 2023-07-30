import zipfile

def contains_file(pakfile_zip, path: str):
	try:
		pakfile_zip.getinfo(path)
		return True
	except:
		return False

def get_file_data(pakfile_zip, path: str):
	if not contains_file(pakfile_zip, path):
		return bytes()

	with pakfile_zip.open(path, "r") as infile:
			return infile.read()

def try_write_disk_file(pakfile_zip, path_on_disk: str, path_in_pak: str):
	try:
		pakfile_zip.write(path_on_disk, path_in_pak)
	except OSError as ex:
		raise OSError(f"Could not add {path_in_pak} to BSP pakfile lump. {ex}")

def try_write_data(pakfile_zip, path_in_pak: str, data: bytes):
	try:
		pakfile_zip.writestr(path_in_pak, data)
	except OSError as ex:
		raise OSError(f"Could not add {path_in_pak} to BSP pakfile lump. {ex}")
