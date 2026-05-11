# maj_commafeed
Commafeed update script

This script :
- makes an horodated archive of the running instance (jars + application.properties + this script itself),
- deletes the oldests backups,
- git pulls the Commafeed Github repo,
- builds the instance,
- installs the files,
- restarts the service.

Prerequisites :
- Commafeed prequisites (see https://github.com/Athou/commafeed#build-from-sources)
- One system account with sufficient rights :
  - write into the backup directory,
  - write into the instance directory,
  - stop and start the instance's system service,

I recommend a dedicated system account, distinct from the one used to launch the instance (so this one doesn't need write permissions). Note that, even if it can do everything, it's a very (very !) bad idea to use the root account.

