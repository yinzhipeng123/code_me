#!/bin/bash
#判断参数
usage="Usage: cloud-deamon.sh (start|stop|status) role [youlog|nolog] [produce|dev]"

# if no args specified, show usage
if [ $# -le 1 ]; then
  echo $usage
  exit 1
fi
echo "-----------------"

#调试开关
debug=true

action=$1
role=$2
logstatus=youlog
if [ -n "$3" ];then
logstatus=$3
fi
echo $logstatus


config=produce
if [ -n "$4" ];then
config=$4
fi
echo $config




jarSuffix=`echo $role | sed 's/^\w\|\s\w/\U&/g'`

if [ $role = web ];then
jarName=BEH-Manager-$jarSuffix.war
else
jarName=BEH-Manager-$jarSuffix.jar
fi

if [ $debug = true ]; then
  echo "action:$action"
  echo "role:$role"
  echo "jarSuffix:$jarSuffix"
  echo "jarName:$jarName"
fi

BM_HOME=$(dirname $(readlink -f "$0"))/../
confDir=$BM_HOME/conf/$role/
logDir=$BM_HOME/logs/
shareDir=$BM_HOME/share/$role
outFile=$BM_HOME/logs/$role-running.out
if [ "$config" == "produce" ];then
JAVA_OPTS="-server -Xms512m -Xms4096m -XX:PermSize=256M -XX:MaxPermSize=512M\
        -Dspring.config.location=$confDir/"
echo $JAVA_OPTS
else
JAVA_OPTS="-server -Xms512m -Xms4096m -XX:PermSize=256M -XX:MaxPermSize=512M"
echo $JAVA_OPTS
fi

PROGRAM_PARAS="--logging.config=$confDir/logback-spring.xml"

startmanager(){
   echo "action:$action"
   echo "role:$role"
   ps -ef | grep $jarName  | grep -v grep > /dev/null 2>&1
   jieguo=$?
   if [ $jieguo == "0" ]
   then
   echo "进程已经存在"
   exit 1;
   fi


    echo "starting $role"

    if [ $debug = true ]; then
      echo "BM_HOME:$BM_HOME"
      echo "confDir:$confDir"
      echo "logDir:$logDir"
      echo "shareDir:$shareDir"
      echo "outFile:$outFile"
      echo "JAVA_OPTS:$JAVA_OPTS"
      echo "PROGRAM_PARAS:$PROGRAM_PARAS"
    fi

    #正常启动使用后台方式运行
    cd $shareDir
    if [ "$logstatus" == "youlog" ];then
    nohup java $JAVA_OPTS -jar $shareDir/$jarName $PROGRAM_PARAS > $outFile 2>&1 &
    #调试时使用前台方式运行
    #java $JAVA_OPTS -jar BEH-Manager-Rest.jar $PROGRAM_PARAS
    echo "logging to $outFile"
    else
    nohup java $JAVA_OPTS -jar $shareDir/$jarName $PROGRAM_PARAS > /dev/null 2>&1 &
    echo "logging to /dev/null"
    fi
}



stopmanager(){
    echo "stopping $role"
    pid=`ps -ef | grep $jarName | grep -v grep | awk '{print $2}'`
    if [ -z $pid ]; then
      echo "$role角色没有运行!"
    else
    i=$(( $i + 1 ))
    echo ---$i---
    if [ $i -gt 5 ];then
    kill -9 $pid
    echo "qiangxing shasi"
    else
    kill $pid
    fi
    echo "杀死$role对应进程$pid."
    #睡眠3s判断是否杀死
    sleep 3s
    pid=`ps -ef | grep $jarName | grep -v grep|awk '{print $2}'`
    if [ -z $pid ]; then
      echo "$role停止成功."
    else
      stopmanager
    fi
    fi
}





case $action in
  (start)
   rm -rf ${logDir}/spring*
   startmanager
    ;;

  (stop)
   stopmanager
    ;;
  (restart)
   stopmanager
   rm -rf ${logDir}/spring*
   startmanager
    ;;

  (status)
   pid=`ps -ef | grep $jarName | grep -v grep | awk '{print $2}'`
    if [ -z $pid ]; then
      echo "$role角色没有运行!"
      exit 1
    else
      echo "${role}正在运行 pid为${pid}"
      exit 1
    fi


  (*)
    echo $usage
    exit 1
    ;;
esac
echo "-----------------"
