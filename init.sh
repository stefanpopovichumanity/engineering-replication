set -a
. ./env.txt
set +a

if [ ! -f "./dump.db" ]; then
    echo "dump.db file not found"
    echo "Run the create_dump.sh script first"
    exit 1
fi

docker-compose up -d

while ! mysqladmin ping -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT --silent; do
  echo "Waiting for master to start..."
  sleep 1
done

while ! mysqladmin ping -uroot -pL0c@lhost --host $DB_HOST --port $SLAVE_PORT --silent; do
  echo "Waiting for slave to start..."
  sleep 1
done

# Remove inserts to entity_integrations since generated_salesforce_id causes problems
awk '!/INSERT INTO `entity_integrations` VALUES/' dump.db > temp.db && mv temp.db dump.db

echo "Importing database into master..."
mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT < dump.db

mysql -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT -e "FLUSH TABLES WITH READ LOCK;"

echo "Dumping master database..."
# Use column statistics flag on newer db versions
#mysqldump -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT --column-statistics=0 --master-data --databases shiftcom_2010_new availability event_log employee_assignment_log > masterdump.db
mysqldump -uroot -pL0c@lhost --host $DB_HOST --port $MASTER_PORT --master-data --databases shiftcom_2010_new availability event_log employee_assignment_log > masterdump.db

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
