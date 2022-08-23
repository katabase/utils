# remove all suffixes from file to only keep `CAT_[0-9]+`

rgx="(^.+)_[^_]+\.xml$"

for f in *xml; do
	if [[ "$f" =~ $rgx ]]; then
		mv $f ${BASH_REMATCH[1]}".xml"
	fi;
done;
