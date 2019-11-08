#!/bin/bash

COUNT_PER_PAGE=35
DB="${TMPDIR}../0/com.apple.dock.launchpad/db/db"
TMP_FILE="${HOME}/Library/Caches/TemporaryItems/resetlaunchpad.tmp"

if [[ ! -e $( dirname $TMP_FILE ) ]]; then
	mkdir $( dirname $TMP_FILE )
fi

PARENT_IDS=($( sqlite3 "$DB" "SELECT rowid FROM items WHERE flags>=0 AND ordering>=1 AND type=3" ))
for PARENT_ID in ${PARENT_IDS[@]}; do
	CURRENT_ID=$PARENT_ID
	break
done

PARENT_IDS=($( sqlite3 "$DB" "SELECT rowid FROM items WHERE flags>=0 AND ordering<=0 AND type=3" ))
for PARENT_ID in ${PARENT_IDS[@]}; do
	sqlite3 "$DB" "SELECT rowid FROM items WHERE parent_id=$PARENT_ID" | while read; do
		NAME=$( sqlite3 "$DB" "SELECT title FROM apps WHERE item_id=$REPLY" )
		echo "$NAME $REPLY" >> "$TMP_FILE"
	done
	ORDERING=0
	cat "$TMP_FILE" | sort -Vf | sed -E 's/^.* ([0-9]*)$/\1/' | while read; do
		sqlite3 "$DB" "UPDATE items SET parent_id=$CURRENT_ID WHERE rowid=$REPLY"
		ORDERING=$(( $ORDERING + 1 ))
	done
	sqlite3 "$DB" "DELETE FROM items WHERE rowid=(SELECT parent_id FROM items WHERE rowid=$PARENT_ID)"
	sqlite3 "$DB" "DELETE FROM items WHERE rowid=$PARENT_ID"
	rm "$TMP_FILE"
done

PARENT_IDS=($( sqlite3 "$DB" "SELECT rowid FROM items WHERE flags>=0 AND ordering>=1 AND type=3" ))
for PARENT_ID in ${PARENT_IDS[@]}; do
	sqlite3 "$DB" "SELECT rowid FROM items WHERE parent_id=$PARENT_ID" | while read; do
		NAME=$( sqlite3 "$DB" "SELECT title FROM apps WHERE item_id=$REPLY" )
		echo "$NAME $REPLY" >> "$TMP_FILE"
	done
done
if [[ -f "$TMP_FILE" ]]; then
	for PARENT_ID in ${PARENT_IDS[@]}; do
		CURRENT_ID=$PARENT_ID
		break
	done
	ORDERING=0
	cat "$TMP_FILE" | sort -Vf | sed -E 's/^.* ([0-9]*)$/\1/' | while read; do
		sqlite3 "$DB" "UPDATE items SET ordering=$ORDERING WHERE rowid=$REPLY"
		sqlite3 "$DB" "UPDATE items SET parent_id=$CURRENT_ID WHERE rowid=$REPLY"
		ORDERING=$(( $ORDERING + 1 ))
		if [[ $ORDERING = $COUNT_PER_PAGE ]]; then
			for PARENT_ID in ${PARENT_IDS[@]}; do
				if [[ $CURRENT_ID < $PARENT_ID ]]; then
					CURRENT_ID=$PARENT_ID
					break
				fi
			done
			ORDERING=0
		fi
	done
	rm "$TMP_FILE"
fi

killall Dock

while [[ $( ps -A | grep -c com.apple.dock.extra$ ) = 0 ]]; do
	sleep 1.0
done
