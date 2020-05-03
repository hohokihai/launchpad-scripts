#!/bin/zsh
#
#  launchpadsort.sh
#
#  Copyright (C) 2019-2020 hohokihai. All rights reserved.
#

COUNT_PER_PAGE=35
CURRENT_PAGE=0
ORDERING=0

DB="${TMPDIR}../0/com.apple.dock.launchpad/db/db"

#  what's this?
sqlite3 "$DB" "UPDATE dbinfo SET value = 1 WHERE key = 'ignore_items_update_triggers'"

killall com.apple.dock.extra && killall Dock
while [[ $( ps -A | grep -c com.apple.dock.extra$ ) == 0 ]]; do
	sleep 0.1
done

PAGES=($( sqlite3 "$DB" "SELECT rowid FROM items WHERE flags>=0 AND ordering>=1 AND type=3" ))
for PAGE in ${PAGES[@]}; do
	if [[ $CURRENT_PAGE < $PAGE ]]; then
		CURRENT_PAGE=$PAGE
		ORDERING=0
		break
	fi
done
ITEMS=($( sqlite3 "$DB" "SELECT title,item_id FROM apps" | sort -fV | sed -E 's/^.+\|([0-9]+)$/\1/' ))
for ITEM in ${ITEMS[@]}; do
	sqlite3 "$DB" "UPDATE items SET ordering=$ORDERING WHERE rowid=$ITEM"
	sqlite3 "$DB" "UPDATE items SET parent_id=$CURRENT_PAGE WHERE rowid=$ITEM"
	ORDERING=$(( $ORDERING + 1 ))
	if [[ $ORDERING == $COUNT_PER_PAGE ]]; then
		for PAGE in ${PAGES[@]}; do
			if [[ $CURRENT_PAGE < $PAGE ]]; then
				CURRENT_PAGE=$PAGE
				ORDERING=0
				break
			fi
		done
	fi
done
ITEMS=($( sqlite3 "$DB" "SELECT rowid FROM items WHERE flags>=0 AND ordering<=0 AND type=3" ))
for ITEM in ${ITEMS[@]}; do
	sqlite3 "$DB" "DELETE FROM items WHERE rowid=(SELECT parent_id FROM items WHERE rowid=$ITEM)"
	sqlite3 "$DB" "DELETE FROM items WHERE rowid=$ITEM"
done

killall com.apple.dock.extra && killall Dock
while [[ $( ps -A | grep -c com.apple.dock.extra$ ) == 0 ]]; do
	sleep 0.1
done
