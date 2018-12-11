#!/bin/sh

defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool FALSE
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool FALSE
defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool FALSE
defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool FALSE