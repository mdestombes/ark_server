# ARK: Survival Evolved - Docker

Docker build for managing an ARK: Survival Evolved server.

This image is base on TuRz4m/Ark-docker functionnalities. Thanks for this good base of Dockerfile and existing structure.

This image uses [Ark Server Tools](https://github.com/FezVrasta/ark-server-tools) to manage an ark server.

## Features
 - Easy install (no steamcmd / lib32... to install)
 - Use Ark Server Tools : update/install/start/backup/rcon/mods
 - Easy crontab configuration
 - Easy access to ark config file
 - Mods handling (via Ark Server Tools)
 - `Docker stop` is a clean stop 

## Usage
Fast & Easy server setup:  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSIONNAME=myserver -e ADMINPASSWORD="mypasswordadmin" --name ark_server mdestombes/ark_server`

You can map the ark volume to access config files:  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSIONNAME=myserver -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server`

Then you can edit:
 - */my/path/to/ark/template/[arkmanager.cfg/main.cgf]* (the values override Game.ini and GameUserSetting.ini)
 - */my/path/to/ark/[GameUserSetting.ini/Game.ini]* (for more specific ark server configurations)

You can manager your server with rcon if you map the rcon port (you can rebind the rcon port with docker):  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330  -e SESSIONNAME=myserver --name ark_server mdestombes/ark_server`

You can change server and steam port to allow multiple servers on same host *(You can't just rebind the port with docker. It won't work, you need to change STEAMPORT & SERVERPORT variable)*:  
  `docker run -d -p 7779:7779 -p 7779:7779/udp -p 27016:27016 -p 27016:27016/udp -p 32331:32330  -e SESSIONNAME=myserver2 -e SERVERPORT=27016 -e STEAMPORT=7779 --name ark_server mdestombes/ark_server`

You can check your server with:  
  `docker exec ark_server arkmanager status`

You can manually update your mods:  
  `docker exec ark_server arkmanager update --update-mods`

You can manually update your server:  
  `docker exec ark_server arkmanager update --force`

You can force save your server:  
  `docker exec ark_server arkmanager saveworld`

You can backup your server:  
  `docker exec ark_server arkmanager backup`

You can check upgrade Ark Server Tools:  
  `docker exec ark_server arkmanager upgrade-tools`

You can use rcon command via docker:  
  `docker exec ark_server arkmanager rconcmd ListPlayers`

*Full list of available command [here](http://steamcommunity.com/sharedfiles/filedetails/?id=454529617&searchtext=admin)*

__You can check all available command for arkmanager__ [here](https://github.com/FezVrasta/ark-server-tools/blob/master/README.md)

You can easily configure automatic update and backup.
If you edit the file `/my/path/to/ark/crontab` you can add your crontab job.
For example:  
  `# Update the server every hours`  
  `0 * * * * arkmanager update --warn --update-mods >> /home/steam/ARK/log/crontab.log 2>&1`  
  `# Backup the server each day at 00:00`  
  `0 0 * * * arkmanager backup >> /home/steam/ARK/log/crontab.log 2>&1`  

*You can check [this website](http://www.unix.com/man-page/linux/5/crontab/) for more information on cron.*

To add mods, you only need to change the variable ark_GameModIds in *arkmanager.cfg* with a list of your modIds (like this `ark_GameModIds="987654321,1234568"`). If UPDATEONSTART is enable, just restart your docker or use:  
  `docker exec ark arkmanager update --update-mods`.

---

## Recommended Usage
 - First run  
  `docker run -it -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330 -e SESSIONNAME=myserver -e ADMINPASSWORD="mypasswordadmin" -e AUTOUPDATE=120 -e AUTOBACKUP=60 -e WARNMINUTE=30 -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server`
 - Wait for ark to be downloaded installed. Server will stop after installation.
 - Edit */my/path/to/ark/template/[arkmanager.cfg/main.cgf]* (the values override Game.ini and GameUserSetting.ini)
 - Edit */my/path/to/ark/[GameUserSetting.ini/Game.ini]* (for more specific ark server configurations)
 - Add auto update every day and autobackup by editing */my/path/to/ark/crontab* with this lines:  
  `0 0 * * * arkmanager update --warn --update-mods >> /home/steam/ARK/log/crontab.log 2>&1`  
  `0 0 * * * arkmanager backup >> /home/steam/ARK/log/crontab.log 2>&1`  
 - Launch the server:  
  `docker start ark_server`
 - Check your server with:  
  `docker exec ark_server arkmanager status`

---

## Variables
+ __SESSIONNAME__
Name of your ark server (default : "ArkServer")
+ __SERVERMAP__
Map of your ark server (default : "TheIsland")
+ __SERVERPASSWORD__
Password of your ark server (default : "ServerPassword")
+ __ADMINPASSWORD__
Admin password of your ark server (default : "AdminPassword")
+ __NBPLAYERS__
Number of playyers allowed of your ark server (default : 20)
+ __SERVERPORT__
Ark server port (can't rebind with docker, it doesn't work) (default : 27015)
+ __STEAMPORT__
Steam server port (can't rebind with docker, it doesn't work) (default : 7778)
+ __BACKUPONSTART__
1 : Backup the server when the container is started. 0: no backup (default : 0)
+ __UPDATEPONSTART__
1 : Update the server when the container is started. 0: no update (default : 0)
+ __BACKUPONSTOP__
1 : Backup the server when the container is stopped. 0: no backup (default : 0)
+ __WARNONSTOP__
1 : Warn the players before the container is stopped. 0: no warning (default : 0)
+ __TZ__
Time Zone : Set the container timezone (for crontab). (You can get your timezone posix format with the command `tzselect`. For example, France is "Europe/Paris").

---

## Volumes
+ __/home/steam/ARK__: Working directory wich contains:
  + /home/steam/ARK/backup: backups
  + /home/steam/ARK/crontab: crontab config file
  + /home/steam/ARK/Game.ini: ark game.ini config file
  + /home/steam/ARK/GameUserSetting.ini: ark gameusersetting.ini config file
  + /home/steam/ARK/log: logs
  + /home/steam/ARK/server: Server files and data.
  + /home/steam/ARK/staging: default directory if you use the --downloadonly option when updating.
  + /home/steam/ARK/template: Default config files
  + /home/steam/ARK/template/arkmanager.cfg: config file for Ark Server Tools
  + /home/steam/ARK/template/main.cfg: config file for main instance of Ark Server Tools (Prefere to set this instead of arkmanager.cfg)

---

## Expose
+ Port: __STEAMPORT__: Steam port (default: 7778)
+ Port: __SERVERPORT__: server port (default: 27015)
+ Port: __32330__: rcon port

---

## Known issues

---

## Changelog
+ 1.0:
  - Initial image: works with Ark Server tools 1.6.38
