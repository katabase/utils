#!/bin/bash

# script to rename the xml and png files downloaded from escriptorium

echo "script to batch rename xml and png files downloaded from eScriptorium"

cwd=$(pwd)
old="$cwd/old"
rgx="^(CAT_[0-9]{6})\.pdf_page_([0-9]+)\.(xml|png)$"  # regex to match escr output files
cats=()  # list to store catalogue identifiers
declare -A newids  # associative array (bash equivalent to dict) to store new ids

# get catalogue ids
for f in * ; do
  if [[ $f =~ $rgx ]]; then
    id="${BASH_REMATCH[1]}"
    if ! [[ "${cats[*]}" =~ "${id}" ]]; then  # it's not an error
      cats+=("$id")
    fi
  fi
done

# build associative array mapping to old catalogue ids new ids
for c in ${cats[*]} ; do
  echo "new name for $c ?"
  read -r input
  newids[$c]="$input"
done

# check that the proper identifiers were submitted
echo "do you confirm using ${newids[*]} as new identifiers ? [Y/N]"
read -r input
if [[ $input != "Y" ]]; then
  echo "you chose to terminate the script."
  exit 1
fi

# build "old" directory for the files and add it to gitignore
if [ ! -d $old ]; then
  mkdir $old
fi
if [ ! -f ./.gitignore ]; then
  echo -e "old/*\nrename_escriptorium.sh" > .gitignore
fi

# rename files
for f in *; do
  # match filenames with k id and rename them
  for k in "${!newids[@]}"; do
    rgx="^$k\.pdf_page_([0-9]+)\.(xml|png)$"
    if [[ $f =~ $rgx ]]; then

      # add 0 before page numbers so that all numbers have the same length
      pnum=${BASH_REMATCH[1]}
      numz=$((3 - 10#${#pnum}))
      pagenum=""
      for i in $(seq 1 $numz); do
        pagenum+="0"
      done
      pagenum+=$pnum

      # define new name and move files
      new="${newids[$k]}_$pagenum.${BASH_REMATCH[2]}"
      cp $f $old
      mv $f $new
    fi
  done
done

echo "files renamed. copies of the files with old filenames are stored in old/"

# rename files

# for k in "${!newids[@]}"; do
#   echo "$k - ${newids[$k]}"
# done