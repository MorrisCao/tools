#!/bin/sh
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
cd ${DIR}
 
command="";
 
case $1 in
        start)
                command="start";
                ;;
        status)
                command="status";
                ;;
        stop)
                command="stop";
                ;;
        restart)
                command="restart";
                ;;
        clearlog)
                command="clearlog";
                ;;
        *)
                command="";
esac
 
operate() {
    if [ "${command}" != "" ]; then
        echo "we will do ${command}"
         
        if [ "${command}" = "clearlog" ]; then
            cd ${DIR}
            cd $1
            echo "" > ./zookeeper.out
        else
            cd ${DIR}
            cd $1
            ./bin/zkServer.sh "${command}"
        fi
         
    fi
}
 
operate "./zookeeper3"
