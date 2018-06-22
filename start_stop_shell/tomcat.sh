#!/bin/bash
DIR="$( cd "$( dirname "$0"  )" && pwd )"
cd "${DIR}"

LOGFILE="${DIR}/$(basename $0).log"

# 判断参数是否正确
if [ $# -ne 2 ] ; then
    echo "USAGE: $0 start/stop/status/restart tomcat_path"
    echo " e.g.: $0 start /home/apache-tomcat-8.5.23"
    exit 1;
fi

operation=$1
# 获取tomcat的绝对路径
tomcat_path=`readlink -f "$2"`
process_flag="Djava.util.logging.config.file=${tomcat_path}/conf/logging.properties"
isrun="yes";#yes表示进程存在，no表示进程不存在

# 判断tomcat目录是否存在
if [ ! -d "${tomcat_path}" ]; then
    echo " folder not exist: ${tomcat_path}"
    exit 1;
fi

# 判断是否有进程在执行
function check_process_isrun()
{
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} start"
	
	ps -ef | grep -w "${process_flag}"
	
    process_count=$(ps -ef | grep -w "${process_flag}" | grep -vw "grep -w ${process_flag}" | wc -l)
    echo "process_count:$process_count"
    if [ $process_count -eq 0 ];then
		isrun="no";
    else
		isrun="yes";
    fi
	
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} end"
}

# 启动进程
function start_process()
{
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} start"
	
    # 切换到tomcat目录
    cd "${tomcat_path}"

    echo "start: ${tomcat_path}"
    ./bin/startup.sh
	
	# 判断是否启动
	isrun="no";
    for((i=1;i<5;i++))
    do
		check_process_isrun
    	if [ "${isrun}" = "yes" ];then
            break;
    	fi
		sleep 3s
    done
	if [ "${isrun}" = "yes" ];then
        echo "  start success: ${tomcat_path}"
	else
		echo "  start fail,please check: ${tomcat_path}"
	fi
	
	
    # 切换到shell目录
    cd "${DIR}"
	
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} end"
}

# 停止进程
function stop_process()
{
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} start"
	
    # 切换到tomcat目录
    cd "${tomcat_path}"

    echo "stop: ${tomcat_path}"
    ./bin/shutdown.sh
	
	# 判断是否停止
	isrun="yes";
    for((i=1;i<5;i++))
    do
		check_process_isrun
    	if [ "${isrun}" = "no" ];then
            break;
    	fi
		sleep 3s
    done
	if [ "${isrun}" = "no" ];then
        echo "  stop success: ${tomcat_path}"
	else
		echo "  stop fail,please check: ${tomcat_path}"
	fi
	
	
    # 切换到shell目录
    cd "${DIR}"
	
    echo "  `date '+%Y/%m/%d %H:%M:%S'` ${FUNCNAME[@]} end"
}

# 根据各种指令进行操作
case "${operation}" in
"start")
    check_process_isrun
	# 启动程序
	if [ "${isrun}" = "yes" ];then
        echo "  The process is already running, please check: ${tomcat_path}"
		exit 1;
	else
		start_process
		if [ "${isrun}" = "no" ];then
			echo "  The process is start fail, please check: ${tomcat_path}"
	        exit 1;
		fi
	fi
;;
"stop")
    check_process_isrun
	# 停止程序
	if [ "${isrun}" = "yes" ];then
        stop_process
		if [ "${isrun}" = "yes" ];then
			echo "  The process is stop fail, please check: ${tomcat_path}"
	        exit 1;
		fi
	else
        echo "  The process is already stopped before this command, please check: ${tomcat_path}"
		#exit 1;
	fi
;;
"status")
    check_process_isrun
	if [ "${isrun}" = "yes" ];then
        echo "  The process is running: ${tomcat_path}"
	else
        echo "  The process is stopped: ${tomcat_path}"
	fi
;;
"restart")
    check_process_isrun
	# 停止程序
	if [ "${isrun}" = "yes" ];then
        stop_process
		if [ "${isrun}" = "yes" ];then
			echo "  The process can not stop, please check: ${tomcat_path}"
	        exit 1;
		fi
	else
        echo "  The process is stopped: ${tomcat_path}"
	fi
	# 启动程序
	start_process
	if [ "${isrun}" = "no" ];then
		echo "  The process can not start, please check: ${tomcat_path}"
        exit 1;
	fi
;;
*)
	# operation不正确
    echo " operation not allowed: ${operation}"
	exit 1;
esac
