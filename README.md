# maj_commafeed

This script :
- makes a horodated archive of the running instance (jars + application.properties + this script itself),
- deletes the oldests backups,
- git pulls the Commafeed Github repo,
- builds the instance,
- installs the files,
- restarts the service.

---

Prerequisites :
- Commafeed prerequisites (see https://github.com/Athou/commafeed#build-from-sources)
- tar, unzip, git commands,
- One system account with sufficient rights :
  - write into the backup directory,
  - write into the instance directory,
  - stop and start the instance system service,

I recommend a dedicated system account, distinct from the one used to launch the instance (so this last one doesn't need write permissions). Note that, even if it easily can do everything, it's a very (very !) bad idea to use the root account to do that.

---

You __must__ modify these variables to adapt the script to your system :

`CFD_PATH` = the Commafeed instance directory. The script will put the generated zip file and unzip it into a `jar` subdirectory.<br>
`CFD_GROUP` = the group of the system account which runs the Commafeed instance. The build system account should be a member of this group.<br>
`CFB_PATH` = the Commafeed building directory. The script will pull the Commafeed repo into a `src` subdirectory.<br>
`CFD_DB` = the database type (can be one of h2, postgresql, mysql or mariadb).<br>
`SAV_GRP` = the group of the system account which makes backups on your machine (you have one, don't you ?). The build system account should be a member of this group.<br>
`SAV_PATH` = the Commafeed backup directory. The script will put the generated backup file into a `${SAV_REP}` subdirectory.<br>
`SAV_NB` = the number of saves to keep.<br>
`SVC_STOP` = the command to stop the system service (if sudo is needed, be sure the build account have the permission to launch it).<br>
`SVC_START` = the command to start the system service (if sudo is needed, be sure the build account have the permission to launch it).<br>
