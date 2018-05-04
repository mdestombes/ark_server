#!/usr/bin/env bash
echo "###########################################################################"
echo "# Ark Server - " `date`
echo "###########################################################################"
[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

if [ $NBINSTANCES -lt 1 ]; then
	NBINSTANCES=1
fi

function stop {
	# Multi instance management
	for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do
		if [[ $CUR_INSTANCE -eq 1 ]]; then
			# Save world before stop
			echo "[Save before stop] for main"
			arkmanager saveworld @main

			# Backup if activated
			if [ ${BACKUPONSTOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
				echo "[Backup on stop] for main"
				arkmanager backup @main
			fi

		else
			# Sub number
			N_SUB=$(($CUR_INSTANCE - 1))

			# Save world before stop
			echo "[Save before stop] for sub"${N_SUB}
			arkmanager saveworld @sub${N_SUB}

			# Backup if activated
			if [ ${BACKUPONSTOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
				echo "[Backup on stop] for sub"${N_SUB}
				arkmanager backup @sub${N_SUB}
			fi

		fi

	done

	echo "[Stop] for all"
	# Stop with warning if activated
	if [ ${WARNONSTOP} -eq 1 ];then 
	    arkmanager stop --warn @all
	else
	    arkmanager stop @all
	fi

	exit
}

# Add a template directory to store the last version of config file
if [ ! -d /home/steam/ARK/template ]; then
	mkdir /home/steam/ARK/template

	NEW_CLUSTER_ID="${SESSIONNAME}_cluster"
	cat /tmp/arkmanager.cfg | sed \
	    -e "s:__CLUSTER_ID__:$NEW_CLUSTER_ID:g" \
	    > /etc/arkmanager/arkmanager.cfg
	cp /etc/arkmanager/arkmanager.cfg /home/steam/ARK/template/arkmanager.cfg

	# Multi instance management
	for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do

		if [[ $CUR_INSTANCE -eq 1 ]]; then
			NEW_SERVER_PORT=$(($SERVERPORT))
			NEW_STEAM_PORT=$(($STEAMPORT))
			NEW_RCON_PORT=$(($RCONPORT))
			NEW_SESSION_NAME="${SESSIONNAME}_${SERVERMAP}_Main"

			cat /tmp/main_instance.cfg | sed \
			    -e "s:__SERVERMAP__:$SERVERMAP:g" \
			    -e "s:__STEAMPORT__:$NEW_STEAM_PORT:g" \
			    -e "s:__RCONPORT__:$NEW_RCON_PORT:g" \
			    -e "s:__SESSIONNAME__:$NEW_SESSION_NAME:g" \
			    -e "s:__SERVERPASSWORD__:$SERVERPASSWORD:g" \
			    -e "s:__ADMINPASSWORD__:$ADMINPASSWORD:g" \
			    -e "s:__NBPLAYERS__:$NBPLAYERS:g" \
			    -e "s:__SERVERPORT__:$NEW_SERVER_PORT:g" \
			    > /etc/arkmanager/instances/main.cfg

			cp /etc/arkmanager/instances/main.cfg /home/steam/ARK/template/main.cfg
		else
			# Sub number
			N_SUB=$(($CUR_INSTANCE - 1))

			NEW_SERVER_PORT=$(($SERVERPORT + (${N_SUB} * 10)))
			NEW_STEAM_PORT=$(($STEAMPORT + ${N_SUB}))
			NEW_RCON_PORT=$(($RCONPORT + ${N_SUB}))
			NEW_SESSION_NAME="${SESSIONNAME}_${SERVERMAP}_Sub${N_SUB}"

			cat /tmp/main_instance.cfg | sed \
			    -e "s:__SERVERMAP__:$SERVERMAP:g" \
			    -e "s:__STEAMPORT__:$NEW_STEAM_PORT:g" \
			    -e "s:__RCONPORT__:$NEW_RCON_PORT:g" \
			    -e "s:__SESSIONNAME__:$NEW_SESSION_NAME:g" \
			    -e "s:__SERVERPASSWORD__:$SERVERPASSWORD:g" \
			    -e "s:__ADMINPASSWORD__:$ADMINPASSWORD:g" \
			    -e "s:__NBPLAYERS__:$NBPLAYERS:g" \
			    -e "s:__SERVERPORT__:$NEW_SERVER_PORT:g" \
			    > /etc/arkmanager/instances/sub${N_SUB}.cfg

			cp /etc/arkmanager/instances/sub${N_SUB}.cfg /home/steam/ARK/template/sub${N_SUB}.cfg
		fi
	done
fi

# Creating directory tree && symbolic link
[ ! -d /home/steam/ARK/log ] && mkdir /home/steam/ARK/log
[ ! -d /home/steam/ARK/backups ] && mkdir /home/steam/ARK/backups
# [ ! -d /home/steam/ARK/cluster_exchange ] && mkdir /home/steam/ARK/cluster_exchange
[ ! -d /home/steam/ARK/staging ] && mkdir /home/steam/ARK/staging
[ ! -f /home/steam/ARK/crontab ] && cp /home/steam/crontab /home/steam/ARK/crontab

# Put steam owner of directories (if the uid changed, then it's needed)
chown -R steam:steam /home/steam
chown -R steam:root /etc/arkmanager/
chmod -R +rw /home/steam

# Server configuration
# if [ ! -d /home/steam/ARK/server_Main  ] || [ ! -f /home/steam/ARK/server_Main/version.txt ]; then 
if [ ! -d /home/steam/ARK/server  ] || [ ! -f /home/steam/ARK/server/version.txt ]; then 
	# Multi instance management
	for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do
		if [[ $CUR_INSTANCE -eq 1 ]]; then
			echo -e "\n[Install] for main"
			arkmanager install @main

			# [ ! -L /home/steam/ARK/Game_Main.ini ] && ln -s server_Main/ShooterGame/Saved/Config/LinuxServer/Game.ini /home/steam/ARK/Game_Main.ini
			# [ ! -L /home/steam/ARK/GameUserSettings_Main.ini ] && ln -s server_Main/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /home/steam/ARK/GameUserSettings_Main.ini
			[ ! -L /home/steam/ARK/Game.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/Game.ini /home/steam/ARK/Game.ini
			[ ! -L /home/steam/ARK/GameUserSettings.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /home/steam/ARK/GameUserSettings.ini
		else
			# Sub number
			N_SUB=$(($CUR_INSTANCE - 1))

			echo -e "\n[Install] for sub"${N_SUB}
			arkmanager install @sub${N_SUB}

			# [ ! -L /home/steam/ARK/Game_Sub${N_SUB}.ini ] && ln -s server_Sub${N_SUB}/ShooterGame/Saved/Config/LinuxServer/Game.ini /home/steam/ARK/Game_Sub${N_SUB}.ini.ini
			# [ ! -L /home/steam/ARK/GameUserSettings_Sub${N_SUB}.ini ] && ln -s server_Sub${N_SUB}/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini /home/steam/ARK/GameUserSettings_Sub${N_SUB}.ini
		fi
	done

else
	# We overwrite the coniguration file each time
	cp /home/steam/ARK/template/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
	# Multi instance management
	for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do
		if [[ $CUR_INSTANCE -eq 1 ]]; then
			cp /home/steam/ARK/template/main.cfg /etc/arkmanager/instances/main.cfg
		else
			# Sub number
			N_SUB=$(($CUR_INSTANCE - 1))

			cp /home/steam/ARK/template/sub${N_SUB}.cfg /etc/arkmanager/instances/sub${N_SUB}.cfg
		fi
	done

	# Make backup if activated
	# if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server_Main/ShooterGame/Saved/SavedArks/)" ]; then 
	if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then 
		# Multi instance management
		for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do
			if [[ $CUR_INSTANCE -eq 1 ]]; then
				echo "[Backup on start] for main"
				arkmanager backup @main
			else
				# Sub number
				N_SUB=$(($CUR_INSTANCE - 1))

				echo "[Backup on start] for sub"${N_SUB}
				arkmanager backup @sub${N_SUB}
			fi
		done
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

	# Multi instance management
	for (( CUR_INSTANCE=1; CUR_INSTANCE<=$NBINSTANCES; CUR_INSTANCE++ )); do
		if [[ $CUR_INSTANCE -eq 1 ]]; then
			# Launching ark server
			if [ $UPDATEONSTART -eq 0 ]; then
				echo "[Start] for main"
				arkmanager start @main
			else
				echo "[Update] for main"
				arkmanager update @main
				arkmanager update --update-mods @main
				echo "[Start] for main"
				arkmanager start @main
			fi
		else
			# Sub number
			N_SUB=$(($CUR_INSTANCE - 1))

			# Launching ark server
			if [ $UPDATEONSTART -eq 0 ]; then
				echo "[Start] for sub"${N_SUB}
				arkmanager start @sub${N_SUB}
			else
				echo "[Update] for sub"${N_SUB}
				arkmanager update @sub${N_SUB}
				arkmanager update --update-mods @sub${N_SUB}
				echo "[Start] for sub"${N_SUB}
				arkmanager start @sub${N_SUB}
			fi
		fi
	done

	# Stop server in case of signal INT or TERM
	echo "Waiting..."
	trap stop INT
	trap stop TERM

	read < /tmp/FIFO &
	wait
fi
