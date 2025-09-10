#!/bin/bash

# download and install the latest version of the script
latest_release=$(curl -s https://api.github.com/repos/Dr-Gigavolt/dbus-aggregate-batteries/releases/latest \
  | grep 'tag_name' \
  | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

echo "Downloading latest release: $latest_release"

# create /data/apps if it does not exist
if [ ! -d "/data/apps" ]; then
    mkdir -p /data/apps
fi

# backup settings.py
if [ -f "/data/apps/dbus-aggregate-batteries/settings.py" ]; then
    cp /data/apps/dbus-aggregate-batteries/settings.py /data/dbus-aggregate-batteries_settings.py.backup
elif [ -f "/data/dbus-aggregate-batteries/settings.py" ]; then
	# legacy installation folder
    cp /data/dbus-aggregate-batteries/settings.py /data/dbus-aggregate-batteries_settings.py.backup
fi

# backup charge file
if [ -f "/data/apps/dbus-aggregate-batteries/charge" ]; then
    cp /data/apps/dbus-aggregate-batteries/charge /data/dbus-aggregate-charge.backup
elif [ -f "/data/dbus-aggregate-batteries/charge" ]; then
	# legacy installation folder
    cp /data/dbus-aggregate-batteries/charge /data/dbus-aggregate-batteries_charge.backup
fi


# download driver
cd /tmp
wget -O dbus-aggregate-batteries_latest.zip https://github.com/Dr-Gigavolt/dbus-aggregate-batteries/archive/refs/tags/$latest_release.zip
if [ $? -ne 0 ]; then
    echo "Error during downloading the ZIP file. Please try again."
    # Delete settings.py backup
    if [ -f "/data/dbus-aggregate-batteries_settings.py.backup" ]; then
        rm /data/dbus-aggregate-batteries_settings.py.backup
    fi
    exit
fi

unzip -q /tmp/dbus-aggregate-batteries_latest.zip

# check if legacy installation folder exists and remove it
if [ -d "/data/dbus-aggregate-batteries" ]; then
    rm -rf /data/dbus-aggregate-batteries
fi

# check if destination folder exists and remove it
if [ -d "/data/apps/dbus-aggregate-batteries" ]; then
    rm -rf /data/apps/dbus-aggregate-batteries
fi

# move extracted files to destination
mv /tmp/dbus-aggregate-batteries-$latest_release /data/apps/dbus-aggregate-batteries

# restore settings.py
if [ -f "/data/dbus-aggregate-batteries_settings.py.backup" ]; then
    echo "Restore settings.py"
    mv /data/dbus-aggregate-batteries_settings.py.backup /data/apps/dbus-aggregate-batteries/settings.py
fi

# restore charge file
if [ -f "/data/dbus-aggregate-batteries_charge.backup" ]; then
    echo "Restore charge file"
    mv /data/dbus-aggregate-batteries_charge.backup /data/apps/dbus-aggregate-batteries/charge
fi

# initialize settings.py and charge file if not present

if ! [ -f "/data/apps/dbus-aggregate-batteries/settings.py" ]; then
    echo "A backup of settings.py was not found. A new settings.py has been created from example file."
    cp /data/apps/dbus-aggregate-batteries/settings.example.py /data/apps/dbus-aggregate-batteries/settings.py
fi

if ! [ -f "/data/apps/dbus-aggregate-batteries/charge" ]; then
    echo "A backup of charge file was not found. A new charge file has been created from example file."
    cp /data/apps/dbus-aggregate-batteries/charge.example /data/apps/dbus-aggregate-batteries/charge
fi

# start reinstall-local.sh
bash /data/apps/dbus-aggregate-batteries/reinstall-local.sh
