#!/bin/bash

defaults write com.apple.dock ResetLaunchPad -bool TRUE
killall Dock
