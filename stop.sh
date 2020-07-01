env_path="../codeP71/_C/.env"
vagrant_env_path="../codeP71/_C/dot.env_vagrant"
rbs_conf_path="../rbsConf/rbs.conf"
vagrant_rbs_conf_path="../rbsConf/rbs.conf_vagrant"

# Same as switch_to_vagrant script
cp $vagrant_env_path $env_path
cp $vagrant_rbs_conf_path $rbs_conf_path
curl 10.11.12.13:7999/stop/RBSWRK_JAVA_0005_java8wrk-sq
curl 10.11.12.13:7999/start/RBSWRK_JAVA_0005_java8wrk-sq

docker-compose down
