#!/bin/bash

# author: tianbaochao@bonc.com.cn
# desc:
# 脚本用于agent分发，
# 要求和目标机器之间配置免密

#调试开关
debug=false
cpPara=fr
rmPara=fr
untarPara=xzf
if [ $debug = true ]; then
  cpPara=fvr
  rmPara=fvr
  tarPara=xvzf
fi

if [ $# -lt 3 ] ; then
 echo "USAGE: $0 update packageFile behBasePath hostsFile "
 echo " e.g.: $0 false /Users/hadoop/Work/包管理/beh-manager-5.1.2.tar.gz /opt/beh2 /etc/hosts"
 echo " explain: update -false 新部署， true更新；更新只更新share部分;"
 echo " explain: packageFile -release包路径;"
 exit 1;
fi

update=$1
packageFile=$2
behBasePath=$3
#
hostsFile=$4
#release包名，如beh-manager-5.1.2.tar.gz
packageName=`echo $packageFile | awk -F "/" '{print $NF}'`
#release产品名，如beh-manager-5.1.2
packageReleaseName=`echo $packageName | sed "s/.tar.gz//"`
#文件md5编码
packageMd5=`md5sum $packageFile | awk '{print $1}'`


#集群密码
passwd=`grep "password" ../path.conf | awk -F "=" '{ if(NF>1) {print $2} }'| awk '{ sub("^ *",""); sub(" *$",""); print }'`

phoenix_path=`grep "phoenix_path" ../path.conf | awk -F "=" '{ if(NF>1) {print $2} }'| awk '{ sub("^ *",""); sub(" *$",""); print }'`


if [ $debug = true ]; then
  echo "packageFile:$packageFile"
  echo "behBasePath:$behBasePath"
  echo "hostsFile:$hostsFile"
  echo "packageName:$packageName"
  echo "packageReleaseName:$packageReleaseName"
  echo "packageMd5:$packageMd5"
fi

if [ ! -f $packageFile ]; then
 echo "!!!${packageFile}不存在，请检查"
 exit 1;
fi
if [ ! -f $hostsFile ]; then
 echo "!!!${hostsFile}不存在，请检查"
 exit 1;
fi

start_time=`date +%s`    #定义脚本运行的开始时间
echo "$start 开始安装包分发"
#解析主机，遍历处理

[ -e /tmp/fd8 ] || mkfifo /tmp/fd8
exec 8<>/tmp/fd8
rm -rf /tmp/fd8

for ((i=1;i<=10;i++))
do
echo >&8
done








for hostname in `cat $hostsFile | awk '{print $1}'`;
do
read -u8
{
    for_start_time=`date +%s`
    echo -e "\033[45;37m ${hostname}for循环开始时间：$for_start_time \033[0m"
    echo "开始处理主机$hostname"
    if [ $debug = true ]; then
      echo "sshpass -p "${passwd}" ssh -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1' hadoop@$hostname 'mkdir -p ${behBasePath}/core/beh-manager'"

      echo "sshpass -p "${passwd}" ssh -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1' hadoop@$hostname 'rm -$rmPara ${behBasePath}/core/${packageReleaseName}'"

      echo "sshpass -p "${passwd}" scp -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1' $packageFile hadoop@$hostname:${behBasePath}/core/"
      echo "sshpass -p "${passwd}" ssh -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1' hadoop@$hostname 'tar -$untarPara ${behBasePath}/core/${packageName} -C ${behBasePath}/core'"
      echo "sshpass -p "${passwd}" ssh -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1'  hadoop@$hostname 'rm -$rmPara ${behBasePath}/core/beh-manager/share/'"
      echo "sshpass -p "${passwd}" ssh -o 'StrictHostKeyChecking no' -o 'ConnectTimeout=8' -o 'ConnectionAttempts=3' -o 'ServerAliveInterval=1' hadoop@$hostname 'cp -$cpPara ${behBasePath}/core/${packageReleaseName}/* ${behBasePath}/core/beh-manager'"
    fi

    #判断是否已经有目录存在
    sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1" hadoop@$hostname "mkdir -p ${behBasePath}/core/beh-manager"
    echo "-----------"

    sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1" hadoop@$hostname "rm -$rmPara ${behBasePath}/core/${packageReleaseName}"

    #先判断安装包是否存在，且md5一致
    oldMd5=`sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "md5sum ${behBasePath}/core/${packageName}" | awk '{print $1}'` 
    if [ ! -n "$oldMd5" ]
    then
    oldMd5="00000000000"
    fi


    if [ $oldMd5 != $packageMd5 ]; then
        echo ".1 拷贝安装包, MD5不一致，${packageMd5}， ${oldMd5}，"
     	sshpass -p "${passwd}" scp -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  $packageFile hadoop@$hostname:${behBasePath}/core/
    else
        echo ".1 无需拷贝安装包，MD5一致，$oldMd5"
    fi
	
	 
 	echo ".2 解压安装包"
 	sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "tar -$untarPara ${behBasePath}/core/${packageName} -C ${behBasePath}/core"
	
	 
	
    if [ $update = false ]; then
        #新装删除原路径
        echo ".3 删除share目录"
        sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "rm -$rmPara ${behBasePath}/core/beh-manager"
        echo ".4 安装新包"
        sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"   hadoop@$hostname "mv ${behBasePath}/core/${packageReleaseName} ${behBasePath}/core/beh-manager"
        echo "主机${hostname}部署完毕。"
    else
     	#升级只处理share路径
     	echo ".3 删除share目录"
     	sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "rm -$rmPara ${behBasePath}/core/beh-manager/share/"
     	echo ".4 升级新包"
        sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "cp -$cpPara ${behBasePath}/core/${packageReleaseName}/share ${behBasePath}/core/beh-manager"
        sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  hadoop@$hostname "rm -$rmPara ${behBasePath}/core/${packageReleaseName}"
        echo "主机${hostname}升级完毕。"
    fi
        for_end_time=`date +%s`
        echo -e "\033[45;37m ${hostname}for循环结束时间：$for_start_time \033[0m"
	declare -i for_time=$for_end_time-$for_start_time
	echo -e "\033[42;37m ${hostname}for循环用时：$for_time \033[0m"


sshpass -p "${passwd}" scp -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1" ../3-phoenix-install/phoenix-server.jar $hostname:${phoenix_path}  2>&1 >/dev/null


echo >&8
}&
done

wait
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "$stop_time 所有主机处理完毕。"
declare -i total_time=$stop_time-$start_time
echo "耗时:${total_time}"
exec 8<&- 
exec 8>&-
