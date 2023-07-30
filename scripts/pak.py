import zipfile

def prepare_path(path: str):
	return path.replace("\\", "/")

def contains_file(pakfile_zip, path: str):
	try:
		pakfile_zip.getinfo(prepare_path(path))
		return True
	except:
		return False

def get_file_data(pakfile_zip, path: str):
	if not contains_file(pakfile_zip, path):
		return bytes()

	with pakfile_zip.open(prepare_path(path), "r") as infile:
		return infile.read()

def try_write_disk_file(pakfile_zip, path_on_disk: str, path_in_pak: str):
	try:
		pakfile_zip.write(path_on_disk, prepare_path(path_in_pak))
	except OSError as ex:
		raise OSError(f"Could not add {path_in_pak} to BSP pakfile lump. {ex}")

def try_write_data(pakfile_zip, path_in_pak: str, data: bytes):
	try:
		pakfile_zip.writestr(prepare_path(path_in_pak), data)
	except OSError as ex:
		raise OSError(f"Could not add {path_in_pak} to BSP pakfile lump. {ex}")
