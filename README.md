# UTILS - general use tools for the katabase project

---

## Description of the tools
**`autopipeline.sh`** : a bash script to run the whole pipeline. The script checks if the directories used as inputs and outputs exists ; if
output directories exist, a message informs the user that data might be overwritten and offers to delete those directories. Be careful not
to delete anything too important, however.
- **how to use it**
	```shell
	mkdir katabase  # create a folder to contain all repositories
	cd katabase  # move in the proper directory
	# clone all necessary repositories
	git clone https://github.com/katabase/utils
	git clone https://github.com/katabase/1_OutputData.git
	git clone https://github.com/katabase/2_CleanedData.git
	git clone https://github.com/katabase/3_TaggedData.git
	cd utils  # move in the utils directory
	bash autopipeline.sh  # launch the script
	```

**`reorder.sh`** : a bash script to move XML catalogues (`CAT_*.xml`) in the proper directories (`1-101`, `200-201`...) based on their id. 
The script is supposed to be usable in all steps of the Katabase pipeline
- *example* : `CAT_000176.xml` will be moved in a directory named `1-100` and so on.
- the script checks if the destination directory exists ; if not, it creates it and moves the file there. 
- it also the location of all `CAT_*.xml` files and moves them to the proper directory if needed.
- **how to**
	```shell
	cp utils/reorder.sh 1_OutputData  # copy the script to the directory you want to use it in (1_OutputData, 2_CleanData, 3_TaggedData)
	cd 1_OutputData  # move in the directory you'll be using the script in
	bash reorder.sh
	```

**`jsontocsv.py`** : a python script to transform `export.json` (the json file obtained at the end of step `3_TaggedData`) in CSV format. `export.json` 
needs to be in the same folder as this script to work.
- **how to**
	```
        # have `jsontocsv.py` and `export.json` in the same directory
        python jsontocsv.py
	```
