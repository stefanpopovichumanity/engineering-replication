set -a
. ./env.txt
set +a

env_path="../codeP71/_C/.env"
vagrant_env_path="../codeP71/_C/dot.env_vagrant"
rbs_conf_path="../rbsConf/rbs.conf"
vagrant_rbs_conf_path="../rbsConf/rbs.conf_vagrant"

if [ ! -f $vagrant_env_path ]; then
    echo "dot.env_vagrant file not found"
    exit 1
fi

if [ ! -f $env_path ]; then
    echo ".env file not found"
    exit 1
fi

if [ ! -f $vagrant_rbs_conf_path ]; then
    echo "rbs.conf_vagrant file not found"
    exit 1
fi

if [ ! -f $rbs_conf_path ]; then
    echo "rbs.conf file not found"
    exit 1
fi

# Same as switch_to_vagrant script
cp $vagrant_env_path $env_path
cp $vagrant_rbs_conf_path $rbs_conf_path
curl 10.11.12.13:7999/stop/RBSWRK_JAVA_0005_java8wrk-sq
curl 10.11.12.13:7999/start/RBSWRK_JAVA_0005_java8wrk-sq

# Modify .env
sed -E -i "/^MYSQL_SHIFTCOM_MASTER_PORT = .+\$/c\MYSQL_SHIFTCOM_MASTER_PORT = $MASTER_PORT" $env_path
sed -E -i "/^MYSQL_SHIFTCOM_MASTER_USER = .+\$/c\MYSQL_SHIFTCOM_MASTER_USER = root" $env_path

sed -E -i "/^MYSQL_SHIFTCOM_SLAVE_PORT = .+\$/c\MYSQL_SHIFTCOM_SLAVE_PORT = $SLAVE_PORT" $env_path
sed -E -i "/^MYSQL_SHIFTCOM_SLAVE_USER = .+\$/c\MYSQL_SHIFTCOM_SLAVE_USER = root" $env_path

sed -E -i "/^MYSQL_CRON_MASTER_PORT = .+\$/c\MYSQL_CRON_MASTER_PORT = $MASTER_PORT" $env_path
sed -E -i "/^MYSQL_CRON_MASTER_USER = .+\$/c\MYSQL_CRON_MASTER_USER = root" $env_path

sed -E -i "/^MYSQL_CRON_SLAVE_PORT = .+\$/c\MYSQL_CRON_SLAVE_PORT = $SLAVE_PORT" $env_path
sed -E -i "/^MYSQL_CRON_SLAVE_USER = .+\$/c\MYSQL_CRON_SLAVE_USER = root" $env_path

# Modify rbs.conf
sed -i "/^db\.default\.url=\"jdbc:mysql:\/\/127\.0\.0\.1:3306\/shiftcom_2010_new\"/c\db.default.url=\"jdbc:mysql://127.0.0.1:$SLAVE_PORT/shiftcom_2010_new\"" $rbs_conf_path
sed -i "/^db\.default\.username=shift_u_r/c\db.default.username=root" $rbs_conf_path

echo "Done"
