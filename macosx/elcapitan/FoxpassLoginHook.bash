#!/bin/bash
LOGFILE=/var/log/loginhook.log
echo "$(date) Login hook executed for user $1" >> $LOGFILE

if [ ! -z "$1" ] && [ "_mbsetupuser" != "$1" ] && [ ! -d /Users/$1 ]; then
  echo "$(date) Adding user $1" >> $LOGFILE
  mkdir -p /Users/$1
  /usr/sbin/chown $1:staff /Users/$1
  /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n $1 -v >> $LOGFILE
fi

# Display sleep after 10 minutes
sudo pmset -a displaysleep 10

## Set software update defaults (must be global preferences)
# Enable the automatic update check
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool TRUE

# Check for software updates daily, not just once per week
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency AutomaticDownload -bool TRUE

# Install System data files & security updates
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool TRUE

# Allow the App Store to reboot machine on macOS updates
# sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE

# Turn on app auto-update
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutoUpdate -bool TRUE

# Set screen saver preferences (must be preferences of the current user)
# Require password immediately after sleep or screen saver begins
sudo -u $1 osascript -e 'do shell script "defaults write com.apple.screensaver askForPassword -int 1"'
sudo -u $1 osascript -e 'do shell script "defaults write com.apple.screensaver askForPasswordDelay -int 0"'

# Auto-update ourselves
curl --fail -o /tmp/FoxpassLoginHook.bash https://raw.githubusercontent.com/mes/foxpass-setup/master/macosx/elcapitan/FoxpassLoginHook.bash && sudo mv /tmp/FoxpassLoginHook.bash /Library/Management/FoxpassLoginHook.bash && sudo chmod a+x /Library/Management/FoxpassLoginHook.bash
