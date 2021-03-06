#!/bin/bash
#
clear
rp=`dirname $0`
. $rp/../../conf/ltfsarchiver.conf
outfile=$rp/../../conf/install.log
#	STEP 0	individuazione OS
unset FFiles
for FFile in `find -P /etc/*-release -type f`; do
        [ -L $FFile ] || FFiles=( ${FFiles[@]} $FFile )
done
OS=$(awk '/DISTRIB_ID=/'  ${FFiles[@]} | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
if [ -z "$OS" ]; then
    OS=$(awk '{print $1}' ${FFiles[@]} | tr '[:upper:]' '[:lower:]')
fi
case $OS in
	"ubuntu")
		WEBSRV="apache2"
	;;
	"centos")
		WEBSRV="httpd"
	;;
esac
echo "copying specific files for $OS"
#	STEP 1 check psql, mtx, etc
for command in psql mtx mt ltfs rsync $WEBSRV; do
	if [ -z `which $command` ]; then
		echo "$command missing"
		echo "$command missing" >> $outfile
		exit 3
	else
		echo "$command found"
		echo "$command found" >> $outfile
	fi
done
#	STEP 2	utente sistema
id -g $LTFSARCHIVER_USER 2>/dev/null
if [ $? == 0 ]; then
	echo "system user $LTFSARCHIVER_USER already existing..." >> $outfile
else
	echo "creating system user $LTFSARCHIVER_USER ..."
	useradd $LTFSARCHIVER_USER -p pprime09 >> $outfile 2>&1
fi

#	STEP 3	utente postgres
dbuserexist=`su - postgres -c 'psql template1 -c "\du"' | grep -c $LTFSARCHIVER_USER`
if [ $dbuserexist == 0 ]; then
	echo "creating postgresql user $LTFSARCHIVER_USER ..."
	su - postgres -c "createuser -S -d -R $LTFSARCHIVER_USER" >> $outfile 2>&1 
else
	echo "postgresql user $LTFSARCHIVER_USER already existing..."
	echo "postgresql user $LTFSARCHIVER_USER already existing..." >>$outfile
fi

#	STEP 4	creazione db
echo "creating ltfsarchiver db..."
su - pprime -c "createdb ltfsarchiver" >> $outfile 2>&1
echo "initializing ltfsarchiver db..."
su - pprime -c "psql -U pprime ltfsarchiver -f /opt/ltfsarchiver/sbin/utils/DB_pprimelto_schema.sql" > $outfile 2>&1

#	STEP 6	init.d e conf.d
echo "adding ltfsarchiver to automatic started services (run levels 3 and 5)"
		cp -p $rp/../../specific/ltfsarchiver.conf /etc/$WEBSRV/conf.d
		cp -p $rp/../../specific/ltfsarchiver.$OS /etc/init.d/ltfsarchiver
case $OS in
	"ubuntu")
		update-rc.d ltfsarchiver start 90 3 5 . stop 90 0 1 2 4 6 .
	;;
	"centos")
		chkconfig --add ltfsarchiver
	;;
esac
service $WEBSRV reload
#	STEP 6 (facoltativo): Guess config
echo -n "Would you like run guess_config script [y|N]> "
read answer
echo "You entered: $answer"
case $answer in
        "y"|"Y")
		. $rp/guess_conf.sh
        ;;
        *)
                echo "guess config skipped"
        ;;
esac

