#!/usr/bin/env sh

wait_for() {
    echo Waiting for $1 to listen on $2...
    while ! nc -z $1 $2; do echo waiting...; sleep 1s; done
}

startDolphinScheduler() {

   node_type=$1

   if [ "$node_type" = "master" ];then

        bash ${DolphinScheduler_HOME}/bin/dolphinscheduler-daemon.sh start master-server

        # 查看日志
        logfile=${DolphinScheduler_HOME}/master-server/logs/dolphinscheduler-master.log
        while [ ! -f $logfile ]; do echo waiting log file...; sleep 1s; done
        tail -f $logfile
		
   elif [ "$node_type" = "api" ];then

        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start api-server

        # 查看日志
        logfile=${DolphinScheduler_HOME}/api-server/logs/dolphinscheduler-api.log
        while [ ! -f $logfile ]; do echo waiting log file...; sleep 1s; done
        tail -f $logfile

   elif [ "$node_type" = "alert" ];then

        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start alert-server

        # 查看日志
        logfile=${DolphinScheduler_HOME}/alert-server/logs/dolphinscheduler-alert.log
        while [ ! -f $logfile ]; do echo waiting log file...; sleep 1s; done
        tail -f $logfile

   elif [ "$node_type" = "worker" ];then

        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start worker-server

        # 查看日志
        logfile=${DolphinScheduler_HOME}/worker-server/logs/dolphinscheduler-worker.log
        while [ ! -f $logfile ]; do echo waiting log file...; sleep 1s; done
        tail -f $logfile
        
   fi

}

# 初始化数据库
bash ${DolphinScheduler_HOME}/tools/bin/upgrade-schema.sh

startDolphinScheduler $@

