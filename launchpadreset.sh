#!/bin/zsh
#
#  launchpadreset.sh
#
#  Copyright (C) 2019-2020 hohokihai. All rights reserved.
#

defaults write com.apple.dock ResetLaunchPad -bool TRUE
killall Dock
while [[ $( ps -A | grep -c com.apple.dock.extra$ ) == 0 ]]; do
	sleep 0.2
done
