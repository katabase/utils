#!/bin/bash

# script to reorder files that match the pattern $rgx in the proper directories
#
# this script should be in one directory ; the files to be reordered / moved should
# either be :
# - at the root of the directory where the script is, as follows:
#
# currentdirectory
#  |_reorder.sh
#  |_filetomove1.xml
#  |_filetomove2.xml
#
# - in at the root of one or several children directories of the current directory,
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
# under the 1000s' ; be very careful that the $rgx pattern only matches what you want it
# to match.
#
# this script works on linux + bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)

# matching the XML files
rgx="^CAT_0+([1-9][0-9]*)(_clean|_tagged)?\.xml$"  # regex pattern to match for the xml files
currentdir="$(readlink -e .)"  # current directory

# looping through all the directories (matched with */)
for tgt in $currentdir/* ; do
  # if there are subdirectories in the current directory, move there
  if [[ -d $tgt ]]; then
    cd $tgt
  fi
  # looping though all files of a directory
  for f in *.xml; do
    # match all proper XML files
    if [[ $f =~ $rgx ]]; then
      nb="${BASH_REMATCH[1]}"
      lasttwo=10#${nb: -2}  # last 2 digits of nb ; 10#$var allows to calculate in base 10, not in octals
      lastthree=10#${nb: -3}  # last 3 digits of nb

      # calculate lowest ($floor) + largest ($roof) file number that should be
      # in the same directory as $f
      # if-elif criteria : length of $nb and if $nb is a multiple of 100 (100, 200..)
      if (( ${#nb} == 1 )); then  # if $nb < 10
        floor=1
        roof=100
      elif (( $lasttwo == 00 )); then  # if $nb is a multiple of 100
        floor=$(( $lastthree - 99 ))
        roof=$(( $lastthree ))
      elif (( ${#nb}  > 1 )) && (( $lasttwo <= 99 )); then  # if $nb is between 10 and 99
        floor=$(( 10#$nb + 1 - $lasttwo ))
        roof=$(( 10#$nb + (100 - $lasttwo) ))
      else
        echo "ERROR ON FILE - $f" # print the number name of the file that matches nothing
      fi

      # create a path to the directory the file should be in
      matchdir="$currentdir/$floor-$roof"
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
      echo "________________________________________________________________"

    fi
  done
  # if working on a child directory, move back to the parent directory after looping through all files of the child
  if [[ -d $tgt ]]; then
    cd ..
  fi
done
