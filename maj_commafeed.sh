#!/bin/bash
set -uef -o pipefail

# À adapter selon les besoins
APP="commafeed"
CFD_CHEMIN="/var/local/${APP}"
CFD_GRP="${APP}"
CFD_FIC="${APP}.jar"
CFD_CONF="application.properties"
CFB_CHEMIN="/var/local/commabuild"
CFD_DB="postgresql"  # h2, postgresql, mysql or mariadb
SAV_GRP="backup"
SAV_CHEMIN="/var/backup/apps/${APP}"
SAV_REP="${SAV_CHEMIN}/${APP}.$(date +%Y%m%d%H%M)"
UNZIP_CMD="/usr/bin/unzip"
SVC_STOP="/usr/bin/sudo /sbin/rc-service ${APP} stop"
SVC_START="/usr/bin/sudo /sbin/rc-service ${APP} start"
TAR_CMD="/bin/tar"
GIT_CMD="/usr/bin/git"
GIT_REF="https://github.com/Athou/commafeed.git"
MVN_CMD="/usr/bin/mvn"

# Aide
# Arguments attendus : aucun
usage() {
	cat <<-FIN

	Usage : ${0} [OPTION]

	Options :
	-h|--help :       Show this help
	-c|--clean :      Clean all the caches before building
	-d|--debug :      Show the whole maven erro messages
	-s|--skiptests :  Skip the tests during building

	FIN
	exit 1
}

# Gestion des arguments
CLEAN=0
MAVEN_EXTRA_EXTRA=""
if [ ${#} -ne 0 ]
then
	while [ ${#} -gt 0 ]
	do
		case ${1} in
			-h|--help)
				usage
				;;
			-c|--clean)
				CLEAN=1
				shift
				;;
			-d|--debug)
				MAVEN_EXTRA_EXTRA="${MAVEN_EXTRA_EXTRA} -e"
				shift
				;;
			-s|--skiptests)
				MAVEN_EXTRA_EXTRA="${MAVEN_EXTRA_EXTRA} -DskipTests"
				shift
				;;
			*)	echo "Argument ${1} inconnu. Stop."
				usage
				;;
		esac
	done
fi

set -x

# si /tmp est monté en noexec, certains modules ne sont pas d'accord
export MAVEN_OPTS=-Djansi.tmpdir="${CFB_CHEMIN}/.tmp"
MAVEN_EXTRA_OPTS=-Dio.netty.native.workdir="${CFB_CHEMIN}/.tmp"

# c'est lourd, le javascript
# https://github.com/Athou/commafeed/issues/1971
export NODE_OPTIONS=--max_old_space_size=4096

# Gestion des sauvegardes
for rep in $(ls -1 "${SAV_CHEMIN}/" | head -n -5)
do
	rm -vrf "${SAV_CHEMIN}/${rep}"
done

FICCONF="${CFD_CHEMIN}/jar/current/config/${CFD_CONF}"
FICARCH="$(find "${CFD_CHEMIN}/jar/" -type f -name "commafeed*${CFD_DB}*.zip")"
if [ -f "${FICARCH}" ]
then
	mkdir -p "${SAV_REP}"
	cp -p "${FICARCH}" "${SAV_REP}/"
	[ -f "${FICCONF}" ] && cp -p "${FICCONF}" "${SAV_REP}/"
	cp -p "${0}" "${SAV_REP}/"
	chgrp -R "${SAV_GRP}" "${SAV_REP}"
	chmod -R u=rwX,g=rX,o= "${SAV_REP}"
fi

if [ ${CLEAN} -ne 0 ]
then
	# Nettoyage complet, au cas ou...
	cd "${CFB_CHEMIN}"
	rm -rf src/${APP}
	rm -rf .cache .config .local .m2 .npm
	cd src
	"${GIT_CMD}" clone "${GIT_REF}"
	cd "${APP}"
else
	# Mise a jour GIT
	cd "${CFB_CHEMIN}/src/${APP}"
	"${GIT_CMD}" pull
fi

# Construction
"${MVN_CMD}" clean package -P${CFD_DB} "${MAVEN_EXTRA_OPTS}" ${MAVEN_EXTRA_EXTRA}

FIC_ZIP="$(find "${CFB_CHEMIN}/src/${APP}/${APP}-server/target/" -type f -name "commafeed*postgresql*.zip")"

${SVC_STOP}

cd "${CFD_CHEMIN}/jar/"
find . -print -delete
mv "${FIC_ZIP}" ./
"${UNZIP_CMD}" "$(basename "${FIC_ZIP}")"
ln -s "$(find . -maxdepth 1 -type d -name "commafeed*")" current
mkdir current/config
cp -p "${CFB_CHEMIN}/${CFD_CONF}" current/config/
chgrp -R "${CFD_GRP}" .
chmod -R u=rwX,g=rX,o= .

${SVC_START}

