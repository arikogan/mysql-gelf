#!/bin/sh

#
# For variables description, see
# https://dev.mysql.com/doc/refman/5.1/en/server-status-variables.html
#
# TODO
# * Chunk messages to allow more variables as part of the payload

VERSION="1.1"
HOST=`hostname --long`
MESSAGE="MySQL Status"
TIMESTAMP=`date +%s`
LEVEL=1

MYSQL_USER=root
MYSQL_PASS=admin

GRAYLOG_SERVER=graylog.fxempiredev.com
GRAYLOG_PORT=12305

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
STATUS_CMD="echo 'SHOW GLOBAL STATUS;' | mysql -u $MYSQL_USER -p$MYSQL_PASS"

cd $DIR

if [ ! -e status.last ]; then
	eval $STATUS_CMD > status.last
else
	eval $STATUS_CMD > status.current

	MSG="{\"version\": \"$VERSION\""
	MSG="$MSG,\"host\":\"$HOST\""
	MSG="$MSG,\"short_message\":\"$MESSAGE\""
	# MSG="$MSG,\"full_message\":\"\""
	MSG="$MSG,\"timestamp\":$TIMESTAMP"
	MSG="$MSG,\"level\":$LEVEL"

	UPTIME_LAST=`grep "Uptime\s" status.last | cut -f 2`
	UPTIME_CURR=`grep "Uptime\s" status.current | cut -f 2`
	SECONDS=$((UPTIME_CURR - UPTIME_LAST))

	for variable in `cat variables-diff`; do
		LAST=`grep "$variable\s" status.last | cut -f 2`
		CURRENT=`grep "$variable\s" status.current | cut -f 2`

		DIFF=$((CURRENT - LAST))
		DIFF_PER_SECOND=`printf "%0.5f\n" $(bc <<< "scale=5; $DIFF/$SECONDS")`
		MSG="$MSG,\"_${variable}_per_second\":$DIFF_PER_SECOND"
	done

	for variable in `cat variables-abs`; do
		VALUE=`grep "$variable\s" status.current | cut -f 2`
		MSG="$MSG,\"_$variable\":$VALUE"
	done

	MSG="$MSG}"

	# echo $MSG
	echo $MSG | gzip -cf | nc -w 1 -u $GRAYLOG_SERVER $GRAYLOG_PORT

	mv status.current status.last
fi

cd -