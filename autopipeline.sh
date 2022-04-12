#!/bin/bash

root="$(readlink -e ..)"  # root / parent directory
rgx="^([0-9]+-[0-9]+)(_clean|_tagged)?/?$"

# étapes de vérification ; trucs à vérifier
# - qu'il y a des dossiers *0*/ dans 1_OutputData
# - qu'il n'y a de dossier output nulle part
# - qu'il n'y a pas de *0*(_clean|_tagged)/ dans les dépôts 2 et 3

# ----- STEP 1_OutputData ----- #
echo "* Beginning step 1_OutputData *"

# launching the python script
cd $root/1_OutputData
for dir in *0*/ ; do
  echo "* working with directory $dir *"
  python script/clean_xml.py -d $dir
done
echo "* Step 1 done ! *"

# ----- moving the files from step 1 to 2 ----- #
# moving the files to 2_CleanedData and moving back to $root
cp -r output/*0*_clean/ $root/2_CleanedData
cd $root
cd $root/2_CleanedData
# renaming the files properly
for dir in *0*_clean ; do
  if [[ $dir =~ $rgx ]] ; then
    mv $dir ${BASH_REMATCH[1]}
  else
    echo "* directory $dir name does not match pattern \$rgx *"
  fi
done

# ----- STEP 2_CleanedData ----- #
echo "Beginning step 2_CleanedData"
for dir in *0* ; do
  echo "* working with directory $dir *"
  cd ./script && python extractor_xml.py ../$dir && cd ..
done
echo "* Step 2 done ! *"

# ----- moving the files from step 2 to 3 ----- #
