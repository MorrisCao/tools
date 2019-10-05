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
        *)
                command="";
esac
 
operate() {
    if [ "${command}" != "" ]; then
        echo "we will do ${command}"
         
        cd ${DIR}
        cd $1
        ./bin/solr "${command}" -cloud -m 28g -force
         
    fi
}
 
operate "./solr3"
