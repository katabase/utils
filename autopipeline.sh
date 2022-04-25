#!/bin/bash


# bash script to run the whole pipeline (1_OutputData, 2_CleanedData, 3_TaggedData, Application)
#
# HOW TO USE :
# - all the directories used must be at the root of the same folder (named $root afterwards)
# - the current file must be in a child of $root (the utils directory, for example)
# - 1_OutputData must contain the input files, at the root of that directory ; they
#   must match the pattern bash *0*
# - files in all the directories are matched using bash or regex patterns ;
#   when launching this script, the script checks which files could be overwritten
#   (the files that match the bash and regex patterns) ; the script offers you the
#   option to erase the files, or to interrupt the script in order to check the files
#   manually. BE SMART: directories that would be deleted will be listed ; if you see
#   anything you want to save, make backups.
#
# *basically* :
# - clone / pull all necessary repositories in a directory
# - `cd utils`
# - `bash autopipeline.sh`
#
# EXPECTED DIRECTORY STRUCTURE
# the script only works in a directory as follows (with extra files, obviously) :
# $root
# |_utils/
# |   |_autopipeline.sh
# |_1_OutputData/
# |   |_*0*/ directories (1-100, 101-200...)
# |   |_script/
# |       |_clean_xml.py (the first script to be ran)
# |_2_CleanedData/
# |   |_script/
# |       |_extractor_xml.py
# |_3_TaggedData/
# |   |_script/
# |      |_extractor_json.py
# |_Application/


root="$(readlink -e ..)"  # root / parent directory
rgx="^([0-9]+-[0-9]+)(_clean|_tagged)?/?$"  # regex to match the directories
paths=($root/1_OutputData/output $root/2_CleanedData/*0* $root/2_CleanedData/output $root/3_TaggedData/Catalogues/*0* $root/3_TaggedData/output $root/Application/APP/data/json $root/Application/APP/data)  # output directories
paths_todel=()  # array of output paths to delete in order to run the script


# ----- check if outputs aldeady exist ; if so, offer to delete them ----- #
# check if outputs aldeady exist ; if so, add them to $paths_todel
for path in "${paths[@]}" ; do
  if [[ -d $path ]] ; then
    echo "* output directory $path aldready exists and could be erased by the script *"
    paths_todel+=("${path}")
  fi
done
# offer to delete them ; if they don't get deleted, the script is ended and the paths should be
# deleted by hand
if (( ${#paths_todel[@]} > 0 )) ; then  # "#paths_todel[@]" : length of the array
  echo ""
  echo "* ${#paths_todel[@]} path(s) aldready exist and would be overwritten by the script. Would you like to delete them [Y/N] ? *
    * (WARNING : please check what is going to be deleted to avoid loosing important files) *"
  read input
  echo ""
  if [[ $input == "Y" ]] ; then
    for path in "${paths_todel[@]}" ; do
      rm -r $path
      echo "* $path removed. *"
    done
    echo ""
  else
    echo "You have chosen not to delete the paths. Please check and delete them by hand before running the script."
    exit 1
  fi
fi


# ----- STEP 1_OutputData ----- #
echo "* Beginning step 1_OutputData *"

# launching the python script
cd $root/1_OutputData
if (( $(ls -d -1q *0* | wc -l) > 0 )) ; then  # if directories match the input pattern in 1_OutputData, run the script ; else, exit
  for dir in *0* ; do
    echo "* working with directory $dir *"
    python script/clean_xml.py -d $dir
    if [ $? != 0 ]; then  # if there is an error, stop the script ; in that case, the xml files need to be corrected
      echo "* python error occured when working on $dir *"
      exit 1
    fi
  done
else
  echo "* No directories matching the pattern *0*. Exiting the script... *"
  exit 1
fi
echo "* Step 1 done ! *"
echo ""


# ----- moving the files from step 1 to 2 ----- #
# moving the files to 2_CleanedData and changing directory to 2_CLeanedData
cp -r output/*0*_clean/ $root/2_CleanedData
cd $root/2_CleanedData
# renaming the files properly
for dir in *0*_clean ; do
  if [[ $dir =~ $rgx ]] ; then
    mv $dir ${BASH_REMATCH[1]}
  else
    echo "* directory $dir name does not match pattern $rgx *"  # improbable
  fi
done


# ----- STEP 2_CleanedData ----- #
echo "* Beginning step 2_CleanedData *"
for dir in *0* ; do
  echo "* working with directory $dir *"
  cd ./script
  python extractor_xml.py ../$dir
  if [ $? != 0 ]; then  # if there is an error, stop the script ; in that case, the xml files need to be corrected
    echo "* python error occured when working on $dir *"
    exit 1
  fi
  cd ..
done
echo "* Step 2 done ! *"
echo ""


# ----- moving the files from step 2 to 3 ----- #
# moving the files to 3_TaggedData and changing directory to 3_TaggedData
cp -r output/*0*_tagged/ $root/3_TaggedData/Catalogues
cd $root/3_TaggedData/Catalogues
# renaming the files properly
for dir in *0* ; do
  if [[ $dir =~ $rgx ]] ; then
    mv $dir ${BASH_REMATCH[1]}
  else
    echo "* directory $dir name does not match pattern $rgx *"  # improbable
  fi
done


# ----- STEP 3_TaggedData ----- #
echo "* Beginning step 3_TaggedData *"
cd $root/3_TaggedData/script
python3 extractor_json.py
if [ $? != 0 ]; then  # if there is an error, stop the script ; in that case, the xml files need to be corrected
  echo "* python error occured when working on $dir *"
  exit 1
fi
echo "* Step 3 done ! *"


# ----- moving the final files to Application ----- #
echo "* Moving the files to Application *"
cd $root
data=$root/Application/APP/data
json=$root/Application/APP/data/json

# make the destination directories if they don't aldready exist
if [ ! -d $data ]; then
  mkdir $data
fi

if [ ! -d $json ]; then
  mkdir $json
fi

cp 3_TaggedData/Catalogues/*0*/*_tagged.xml Application/APP/data
cp 3_TaggedData/output/export.json Application/APP/data/json
echo "* Done ! *"