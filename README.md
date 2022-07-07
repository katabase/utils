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
	git clone https://github.com/katabase/Application.git
	python3 -m venv env  # create a python virtual environment
	source env/bin/activate  # activate the virtualenv
	cd utils  # move in the utils directory
	pip install -r req_full.txt  # install the necessary librairies
	bash autopipeline.sh  # launch the script
	```

---

**`reorder.sh`** : a bash script to move XML catalogues (`CAT_*.xml`) in the proper directories (`1-101`, `200-201`...) based on their id. 
The script is supposed to be usable in all steps of the Katabase pipeline
- *example* : `CAT_000176.xml` will be moved in a directory named `101-200` and so on.
- the script checks if the destination directory exists ; if not, it creates it and moves the file there. 
- it also the location of all `CAT_*.xml` files and moves them to the proper directory if needed.
- **how to**
	```shell
	cp utils/reorder.sh 1_OutputData  # copy the script to the directory you want to use it in (1_OutputData, 2_CleanData, 3_TaggedData)
	cd 1_OutputData  # move in the directory you'll be using the script in
	bash reorder.sh
	```
 
---

**`rename_escriptorium.sh`** : a bash script to rename `xml` and `png` 
files downloaded from eScriptorium. 
- **functionning** : the files downloaded from eScriptorium all 
follow this structure: `filename_of_file_uploaded_to_escriptorium_page_N.xml`.
we rename the files by changing the input filename to an identifier chosen
by the user and modifying the way a page number is written.
- **example**: `CAT_000432.pdf_page_1.xml` becomes `1890_01_16_CHA_001.xml`
- **how to**:
	```shell
	# be in a directory with all the escriptorium files and this script
	bash rename_escriptorium.sh
	```

---

**`validator.py`** : a python command line interface to validate
and correct the XML files in `New_OutputData`. Those files are
not clean; some of them aren't following the specifications of
the ODD and are this not valid. Two commands exist:
- `errlogger` checks the validity of the files against the ODD specification
in RNG format (`_schemas/odd_katabase.rng`)
- `corrector` prompts the user to give the missing information ; if
the files are "problematic" (they can't easily be corrected from the
CLI), they are moved to `out_a_corriger` ; if the files are valid from
the start and corrected by the user, they are moved to `out_clean`
- **before using this script, several enhancements are necessary** :
	- allow a `tei:item` to have more than one `tei:desc` : currently, if an
item has more than one `tei:desc`, it is moved to `out_a_corriger`, despite this
being a valid situation. instead, if a `tei:item//tei:name` has no `@type` 
attribute, all the `tei:desc`s should be printed before the user is prompted to give
an `@type` attribute (faulty line : `if len(name) != len(context):`)
	- if `tei:bibl//tei:date`` is empty, prompt the user to add a date 
using the `@when` or `@from` and `@to` of this element (no date causes an error 
when launching the website)
- **how to**
    ```shell
	cp utils/validator.py New_OutputData  # copy the script in the proper directory
    cd New_OutputData  # move to the directory
    python validator.py errlogger  # if you want to check the file's validity
    python validator.py corrector  # if you want to correct the files
    ```

---

**`jsontocsv.py`** : a python script to transform `export.json` (the json file obtained at the end of step `3_TaggedData`) in CSV format. `export.json` 
needs to be in the same folder as this script to work.
- **how to**
	```
        # have `jsontocsv.py` and `export.json` in the same directory
        python jsontocsv.py
	```

---

**`nametable.py`** : a python script to build a csv of names in the corpus in order to align names with a wikidata id.
- **tsv structure**: 
	- `xml id` : the `@xml:id` of the `tei:item` in which the name is found
	- `wikidata id` : the wikidata identifier of a person / subject
	- `name` : the `tei:name` in catalogue entries: the `tei:name` can be the name of a person, but also a historical period, a subject...
	- `trait` : the `tei:trait` element, used to describe the information in `tei:name`
	- the same names can and will be found several times in the different catalogues
- **how to**:
	- expected file structure:
	```
	root_directory/
	 |_utils/
	 |  |_nametable.py
	 |_1_OutputData/
	    |_*0*  # the catalogues folders: 1-100, 101-200...
	```
	- run the script:
	```shell
	cd utils
	python nametable.py
	```

---

**`full_requirements.txt`** : a list of python packages to be able to work 
on the whole pipeline (by creating a single python virutalenv for the 4 first steps,
the web application, all scripts on the utils and visualisation repositories).
