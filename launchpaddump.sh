#!/bin/zsh
#
#  launchpaddump.sh
#
#  Copyright (C) 2019-2020 hohokihai. All rights reserved.
#

DB="${TMPDIR}../0/com.apple.dock.launchpad/db/db"

TABLES=($( sqlite3 "$DB" ".tables" ))
for TABLE in ${TABLES[@]}; do
	if [[ $TABLE != ${TABLES[@]:0:1} ]]; then
		echo ""
	fi
	echo "[$TABLE]"
	sqlite3 "$DB" ".schema $TABLE" | head -n 1
	sqlite3 "$DB" "SELECT * FROM $TABLE"
done
