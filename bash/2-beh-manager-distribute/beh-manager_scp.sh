#!/usr/bin/env bash

#安装路径
install_path=$1
#ip文件
ipfile=$2
#主机密码
passwd=$3

if [ $# -lt 3 ]
then
echo "USAGE: sh $0 install_path  ipfile passwd"
echo " e.g.: sh $0 /opt/beh/core/  ip.txt bonc1234"
echo "/opt/beh/core/为要安装的目录"
echo "ip.txt为主机地址列表"
echo "password为集群密码"
echo "！！！！请把这个脚本放在/opt/beh/core/下，进行执行！！！"
exit 1;
fi

md5sum beh-manager-5.4.0.tar.gz

if [ $? != 0 ];then
echo "请先运行manager_tar.sh,manager_tar.sh可以把/opt/beh/core/下的beh-manager打包成beh-manager-5.4.0.tar.gz"
break
fi


packageMd5=`md5sum beh-manager-5.4.0.tar.gz | awk '{print $1}'`

start_time=`date +%s`    #定义脚本运行的开始时间
echo "$start 开始安装包分发"

[ -e /tmp/fd8 ] || mkfifo /tmp/fd8
exec 8<>/tmp/fd8
rm -rf /tmp/fd8

for ((i=1;i<=50;i++))
do
echo >&8
done



for i in `cat $ipfile | awk '{print $1}'`
do
read -u8
{
echo "--${i}开始传输--"


oldMd5=`sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  $i "md5sum ${install_path}/beh-manager-5.4.0.tar.gz" | awk '{print $1}'`
if [ ! -n "$oldMd5" ]
then
oldMd5="00000000000"
fi

if [ $oldMd5 != $packageMd5 ]; then
    echo ".1 拷贝安装包, MD5不一致，${packageMd5}， ${oldMd5}，"
    sshpass -p "${passwd}" scp -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  beh-manager-5.4.0.tar.gz $i:${install_path}/
else
    echo ".1 无需拷贝安装包，MD5一致，$oldMd5"
fi

echo ".2 解压安装包"
sshpass -p "${passwd}" ssh -o "StrictHostKeyChecking no" -o "ConnectTimeout=8" -o "ConnectionAttempts=3" -o "ServerAliveInterval=1"  $i "tar -zxf ${install_path}/beh-manager-5.4.0.tar.gz -C ${install_path}/"


echo "--${i}结束传输--"
echo >&8
}&
done
wait
stop_time=`date +%s`  #定义脚本运行的结束时间
echo "$stop_time 所有主机处理完毕。"
declare -i total_time=$stop_time-$start_time
echo "耗时:${total_time}"
echo "wancheng!!!!"
exec 8<&-
exec 8>&-

