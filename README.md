# UTILS - general use tools for the katabase project

---

## Description of the tools
- `reorder.sh` : a bash script to move XML catalogues (`CAT_*.xml`) in the proper directories (`1-101`, `200-201`...) based on their id. 
The script is supposed to be usable in all steps of the Katabase pipeline
	- example : `CAT_000176.xml` will be moved in a directory named `1-100` and so on. 
	- he script checks if the destination directory exists ; if not, it creates it and moves the file there. 
	- it also the location of all `CAT_*.xml` files and moves them to the proper directory if needed.
- `jsontocsv.py` : a python script to transform `export.json` (the json file obtained at the end of step `3_TaggedData`) in CSV format. `export.json` 
needs to be in the same folder as this script to work.
