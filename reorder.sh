#!/bin/bash

# script to reorder files that match the pattern $rgx in the proper directories
#
# this script should be in one directory ; the files to be reordered / moved should
# be in at the root of one or several children directories of the current directory,
# as follows:
#
# currentdirectory
#  |_dir1
#  |  |_filetomove1.xml
#  |  |_filetomove2.xml
#  |_dir2
#  |  |_filetomove3.xml
#  |_reorder.sh (the current script)
#
# **WARNING** --- this script hasn't been extensively tested ; please make backups
# of the directories you'll be using it in. it has only been tested with file numbers
# under the 1000s'
# this script has been works on linux + bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)

# matching the XML files
rgx="^CAT_0+([1-9][0-9]*)(_clean|_tagged)?\.xml$"

# looping through all the directories (matched with */)
for dir in */ ; do
  cd $dir
  # looping though all files of a directory
  for f in *.xml; do
    # match all proper XML files
    if [[ $f =~ $rgx ]]; then
      nb="${BASH_REMATCH[1]}"

      # calculate lowest ($floor) + largest ($roof) file number that should be
      # in the same directory as $f
      # if-elif criteria : length of $nb and if $nb is a multiple of 100 (100, 200..)
      if (( ${#nb} == 1 )); then  # if $nb < 10
        floor=1
        roof=100
      elif (( ${nb: -2} == 00 )); then  # if $nb is a multiple of 100
        dgts=(${nb: -3})  # last 3 digits of the file's number (100, 200)
        floor=$(( 10#$dgts - 99 ))  # 10#$var allows to calculate in base 10, not in octals
        roof=$(( 10#$dgts ))
      else  # if $nb is >= 10 but not a multiple of 100
        dgts=(${nb: -2})  # last 2 digits of the file's number
        floor=$(( 10#$nb + 1 - 10#$dgts ))
        roof=$(( 10#$nb + (100 - 10#$dgts) ))
      fi

      # create a path to the directory the file should be in
      matchdir="../$floor-$roof"
      # check if the directory exists ; if not, create it
      if [ ! -d $matchdir ]; then
  `      mkdir $matchdir`
      fi
      # try to locate the file in its destination directory ;
      # if it's not there (fmatch == 0), move it there
      fmatch=$(find "$matchdir" -name "$f" | wc -l)
      if (( $fmatch == 0 )); then
        echo "moving $f to $matchdir"
        mv $f $matchdir
      else
        echo "$f is aldready in the proper directory"
      fi

    fi
  done
  # move back to the parent directory after looping through all files of a child directory
  cd ..
done
