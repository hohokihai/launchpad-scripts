#
#  launchpadreset.sh
#
#  Copyright © 2019-2020 hohokihai. All rights reserved.
#

#!/bin/zsh

defaults write com.apple.dock ResetLaunchPad -bool TRUE
killall Dock
while [[ $( ps -A | grep -c com.apple.dock.extra$ ) == 0 ]]; do
	sleep 0.1
done
