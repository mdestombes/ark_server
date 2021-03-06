# ARK: Survival Evolved - Docker

__*Take care, `Last` version is often in dev. Use stable version with TAG*__

Docker build for managing an ARK: Survival Evolved server.

This image is base on TuRz4m/Ark-docker functionnalities. Thanks for this good base of Dockerfile and existing structure.

This image uses [ARK Server Tools](https://github.com/FezVrasta/ark-server-tools) to manage an ARK server.

## Features
 - Easy install (no steamcmd / lib32... to install)
 - Use ARK Server Tools : update/install/start/backup/rcon/mods
 - Easy crontab configuration
 - Easy access to ARK config file
 - Mods handling (via ARK Server Tools)
 - `Docker stop` is a clean stop 

## Usage
Fast & Easy server setup:  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSIONNAME="myserver" -e ADMINPASSWORD="mypasswordadmin" --name ark_server mdestombes/ark_server:[last_version_available]`

You can map the ARK volume to access config files:  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -e SESSIONNAME="myserver" -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server:[last_version_available]`

You can manager your server with rcon if you map the rcon port (you can rebind the rcon port with docker):  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330 -e SESSIONNAME="myserver" -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server:[last_version_available]`

You use with multi instance:  
  `docker run -d -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330 -p 7779:7779 -p 7779:7779/udp -p 27025:27025 -p 27025:27025/udp -p 32331:32331 -e SESSIONNAME="myserver" -e NBINSTANCES=2 -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server:[last_version_available]`
Take care, in multi instance case, you need to open more communication port for Steam, Rcon and instance game like:
 - Add 1 to __STEAMPORT__ needed by each instance (Ex: 7778 for Main and 7779 for Sub1)
 - Add 10 to __SERVERPORT__ needed by each instance (Ex: 27015 for Main and 27025 for Sub1)
 - Add 1 to __RCONPORT__ needed by each instance (Ex: 32330 for Main and 32331 for Sub1)

You can change server and steam default port to allow multiple servers on same host *(You can't just rebind the port with docker. It won't work, you need to change STEAMPORT & SERVERPORT variable)*:  
  `docker run -d -p 7779:7779 -p 7779:7779/udp -p 27016:27016 -p 27016:27016/udp -p 32331:32330  -e SESSIONNAME="myserver2" -e SERVERPORT=27016 -e STEAMPORT=7779 --name ark_server mdestombes/ark_server:[last_version_available]`

Then you can edit:
 - */my/path/to/ark/template/[arkmanager.cfg/main.cgf/subX.cgf]* (The values override Game.ini and GameUserSetting.ini | `X` for each sub instance | In case of multi instance, first instance is main, others are subX | `X` start from `1` for instance `2`)
 - */my/path/to/ark/[GameUserSetting.ini/Game.ini]* (for more specific ARK server configurations)

You can check your server with:  
  `docker exec ark_server arkmanager status @all`

You can manually update your mods:  
  `docker exec ark_server arkmanager update --update-mods @all`

You can manually update your server:  
  `docker exec ark_server arkmanager update --force @all`

You can check upgrade Ark Server Tools:  
  `docker exec ark arkmanager upgrade-tools @all`

You can force save your server:  
  `docker exec ark_server arkmanager saveworld @all`

You can backup your server:  
  `docker exec ark_server arkmanager backup @all`

You can use rcon command via docker:  
  `docker exec ark_server arkmanager rconcmd ListPlayers @all`

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

To add mods, you only need to change the variable ark_GameModIds in */my/path/to/ark/template/[main.cgf/subX.cgf]* with a list of your modIds (like this `ark_GameModIds="987654321,1234568"`). If UPDATEONSTART is enable, just restart your docker or use:  
  `docker exec ark arkmanager update --update-mods`.

---

## Recommended Usage
 - First run  
  `docker run -it -p 7778:7778 -p 7778:7778/udp -p 27015:27015 -p 27015:27015/udp -p 32330:32330 -e SESSIONNAME="myserver" -e ADMINPASSWORD="mypasswordadmin" -v /my/path/to/ark:/home/steam/ARK:rw --name ark_server mdestombes/ark_server:[last_version_available]`
 - Wait for ARK to be downloaded installed. Server will stop after installation.
 - Edit */my/path/to/ark/template/[arkmanager.cfg/main.cgf]* (The values override Game.ini and GameUserSetting.ini | Only `main.cfg` is present because there is only one session)
 - Edit */my/path/to/ark/[GameUserSetting.ini/Game.ini]* (For more specific ARK server configurations)
 - Add auto update every day and autobackup by editing */my/path/to/ark/crontab* with this lines:  
  `0 0 * * * arkmanager update --warn --update-mods @all >> /home/steam/ARK/log/crontab.log 2>&1`  
  `0 0 * * * arkmanager backup @all >> /home/steam/ARK/log/crontab.log 2>&1`  
 - Launch the server:  
  `docker start ark_server`
 - Check your server with:  
  `docker exec ark_server arkmanager status @all`

---

## Variables
+ __SESSIONNAME__
Name of your ARK server (default : "ArkServer")
+ __SERVERMAP__
Map of your ARK server (default : "TheIsland")
+ __SERVERPASSWORD__
Password of your ARK server (default : "ServerPassword")
+ __ADMINPASSWORD__
Admin password of your ARK server (default : "AdminPassword")
+ __NBPLAYERS__
Number of players allowed of your ARK server (default : 20)
+ __SERVERPORT__
Main ARK server port (default : 27015)
+ __STEAMPORT__
Main steam server port (default : 7778)
+ __RCONPORT__
Main rcon port (default : 32330)
+ __BACKUPONSTART__
1 : Backup the server when the container is started. 0: no backup (default : 0)
+ __UPDATEPONSTART__
1 : Update the server when the container is started. 0: no update (default : 0)
+ __BACKUPONSTOP__
1 : Backup the server when the container is stopped. 0: no backup (default : 0)
+ __WARNONSTOP__
1 : Warn the players before the container is stopped. 0: no warning (default : 0)
+ __NBINSTANCES__
1 : Number of server instance. Take care multi instance requires as much resource as a server multiplied by the number of instances. (default : 1)
+ __TZ__
Time Zone : Set the container timezone (for crontab). (You can get your timezone posix format with the command `tzselect`. For example, France is "Europe/Paris").

---

## Volumes
+ __/home/steam/ARK__: Working directory wich contains:
  + /home/steam/ARK/backup: backups
  + /home/steam/ARK/crontab: crontab config file
  + /home/steam/ARK/Game.ini: ARK game.ini config file
  + /home/steam/ARK/GameUserSetting.ini: ARK gameusersetting.ini config file
  + /home/steam/ARK/log: logs
  + /home/steam/ARK/server: Server files and data.
  + /home/steam/ARK/staging: default directory if you use the --downloadonly option when updating.
  + /home/steam/ARK/template: Default config files
  + /home/steam/ARK/template/arkmanager.cfg: config file for ARK Server Tools
  + /home/steam/ARK/template/main.cfg: config file for first instance of ARK Server Tools (Prefere to set this instead of arkmanager.cfg)
  + /home/steam/ARK/template/subX.cfg: config file for others instances of ARK Server Tools (Prefere to set this instead of arkmanager.cfg)

---

## Expose
+ Port: __STEAMPORT__: Main steam port (default: 7778)
+ Port: __SERVERPORT__: Main server port (default: 27015)
+ Port: __RCONPORT__: Main rcon port (default : 32330)

---

## Known issues

---

## Changelog
+ 1.0:
  - Initial image: works with ARK Server tools 1.6.39
+ 1.1:
  - Works with ARK Server tools 1.6.40
+ 2.0:
  - Multi server instance
+ 2.1:
  - Works with ARK Server tools 1.6.41
+ 2.2:
  - Works with ARK Server tools 1.6.42
