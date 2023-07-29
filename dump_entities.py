import argparse
import os
import sys

from scripts import bsp, entities

def parse_args():
	parser = argparse.ArgumentParser(
		prog="dump_entities",
		description="Dumps details about entities present in the given map file.")

	parser.add_argument("map_file",
		nargs=1,
		help="Paths to map file.")

	parser.add_argument("-p", "--property",
		action="append",
		help="Only dump information about entities with a key=value property pair matching this. This option can be specified multiple times.")

	return parser.parse_args()

def main():
	args = parse_args()
	map_file = args.map_file[0]

	if not os.path.isfile(map_file):
		print(f"Map {map_file} does not exist")
		sys.exit(1)

	filter_properties = {}

	for item in args.property:
		(key, value) = item.split("=", maxsplit=1)

		if not key or not value:
			print(f'Invalid property filter "{item}", ignoring')
			continue

		filter_properties[key] = value

	with open(map_file, "rb") as bsp_file:
		bsp.validate_bsp_file(bsp_file)
		ent_list = entities.build_entity_list(bsp.get_lump_data(bsp_file, bsp.LUMP_INDEX_ENTITIES))

		have_printed = False

		for index in range(0, len(ent_list)):
			entity = ent_list[index]

			if "classname" not in entity:
				entity["classname"] = "<unknown>"

			should_print = True

			for key in filter_properties.keys():
				if key not in entity or entity[key] != filter_properties[key]:
					should_print = False
					break

			if not should_print:
				continue

			classname = entity["classname"]
			targetname = entity["targetname"] if "targetname" in entity else ""

			title = f"[{index}] {classname}"

			if targetname:
				title += f' "{targetname}"'

			if have_printed:
				# Add a newline
				print()

			print(title)

			for key in entity.keys():
				if key == "classname" or key == "targetname":
					continue

				print(f'  "{key}" = "{entity[key]}"')

			have_printed = True

if __name__ == "__main__":
	main()
