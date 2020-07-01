set -a
. ./env.txt
set +a

reg='^[0-9]+$'
if ! [[ $1 =~ $reg ]] ; then
   echo "Error: no delay number given"
   exit 1
fi

mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "FLUSH TABLES WITH READ LOCK;"
mysql -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT -e "STOP SLAVE; CHANGE MASTER TO MASTER_DELAY = $1; START SLAVE;"
mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "UNLOCK TABLES;"
