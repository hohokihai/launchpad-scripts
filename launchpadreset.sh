#!/bin/bash

defaults write com.apple.dock ResetLaunchPad -bool TRUE
killall Dock

while [[ $( ps -A | grep -c com.apple.dock.extra$ ) = 0 ]]; do
	sleep 1.0
done
