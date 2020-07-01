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

mysqldump -uroot -pL0c@lhost --port 3307 --host 10.11.12.13 --databases shiftcom_2010_new availability event_log employee_assignment_log > dump.db
