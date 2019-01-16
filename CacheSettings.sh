#!/bin/sh

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist AllowPersonalCaching -bool true

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist AllowSharedCaching -bool true

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist AutoActivation -bool true

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist CacheLimit -int 134217728000

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist DenyTetheredCaching -bool true

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist LocalSubnetsOnly -bool false

sudo -u _assetcache defaults write /Library/Preferences/com.apple.AssetCache.plist LogClientIdentity -bool true
