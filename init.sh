set -a
. ./env.txt
set +a

docker-compose up -d

while ! mysqladmin ping -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT --silent; do
  echo "Waiting for master to start..."
  sleep 1
done

while ! mysqladmin ping -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT --silent; do
  echo "Waiting for slave to start..."
  sleep 1
done

echo "Importing database into master..."
mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT < dump.db

mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "FLUSH TABLES WITH READ LOCK;"

echo "Dumping master database..."
mysqldump -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT --column-statistics=0 --master-data --databases shiftcom_2010_new availability event_log employee_assignment_log > masterdump.db

echo "Importing master database into slave..."
mysql -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT < masterdump.db

echo "Done importing"

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "root"'
mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "$priv_stmt"

master_status=$(mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e 'SHOW MASTER STATUS' --silent --silent)
master_status_array=($master_status)
replication_file=${master_status_array[0]}
replication_position=${master_status_array[1]}

mysql -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT -e "CHANGE MASTER TO MASTER_HOST='$DB_HOST', MASTER_PORT=$MASTER_PORT, MASTER_USER='root', MASTER_PASSWORD='L0c@lhost', MASTER_LOG_FILE='$replication_file', MASTER_LOG_POS=$replication_position;"
mysql -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT -e "RESET SLAVE; START SLAVE;"

mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "UNLOCK TABLES;"
