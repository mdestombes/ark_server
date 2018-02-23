#!/usr/bin/env bash
echo "###########################################################################"
echo "# Ark Server - " `date`
echo "###########################################################################"
[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

function stop {
	# Save world before stop
	arkmanager saveworld

	# Backup if activated
	if [ ${BACKUPONSTOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
		echo "[Backup on stop]"
		arkmanager backup
	fi

	# Stop with warning if activated
	if [ ${WARNONSTOP} -eq 1 ];then 
	    arkmanager stop --warn
	else
	    arkmanager stop
	fi
	exit
}

# Add a template directory to store the last version of config file
if [ ! -d /home/steam/ARK/template ]; then
	mkdir /home/steam/ARK/template
	cp /etc/arkmanager/arkmanager.cfg /home/steam/ARK/template/arkmanager.cfg
	cp /etc/arkmanager/instances/main.cfg /home/steam/ARK/template/main.cfg
fi

# Creating directory tree && symbolic link
[ ! -d /home/steam/ARK/log ] && mkdir /home/steam/ARK/log
[ ! -d /home/steam/ARK/backups ] && mkdir /home/steam/ARK/backups
[ ! -d /home/steam/ARK/staging ] && mkdir /home/steam/ARK/staging
[ ! -f /home/steam/ARK/crontab ] && cp /home/steam/crontab /home/steam/ARK/crontab

# Put steam owner of directories (if the uid changed, then it's needed)
chown -R steam:steam /home/steam
chown -R steam:root /etc/arkmanager/
chmod -R +rw /home/steam

# Server configuration
if [ ! -d /home/steam/ARK/server  ] || [ ! -f /home/steam/ARK/server/version.txt ]; then 
	arkmanager install
	[ ! -L /home/steam/ARK/Game.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/Game.ini /home/steam/ARK/Game.ini
	[ ! -L /home/steam/ARK/GameUserSettings.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /home/steam/ARK/GameUserSettings.ini
else
	# We overwrite the coniguration file each time
	cp /home/steam/ARK/template/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
	cp /home/steam/ARK/template/main.cfg /etc/arkmanager/instances/main.cfg

	# Make backup if activated
	if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then 
		echo "[Backup]"
		arkmanager backup
	fi

	# If there is uncommented line in the file
	CRONNUMBER=`grep -v "^#" /home/steam/ARK/crontab | wc -l`
	if [ $CRONNUMBER -gt 0 ]; then
		echo "Loading crontab..."
		# We load the crontab file if it exist.
		crontab /home/steam/ARK/crontab
		# Cron is attached to this process
		sudo cron -f &
	else
		echo "No crontab set."
	fi

	# Launching ark server
	if [ $UPDATEONSTART -eq 0 ]; then
		arkmanager start
	else
		arkmanager update
		arkmanager update --update-mods
		arkmanager start
	fi

	# Stop server in case of signal INT or TERM
	echo "Waiting..."
	trap stop INT
	trap stop TERM

	read < /tmp/FIFO &
	wait
fi
