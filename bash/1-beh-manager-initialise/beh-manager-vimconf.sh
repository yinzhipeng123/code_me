#!/bin/bash


if [ $# -lt 3 ] ; then
 echo " USAGE: $0 config.conf pack_current_path packName "
 echo "  e.g.: $0 beh-manager-config.conf /***/***/beh-manager-script/1-beh-manager-initialis/ beh-manager-5.1.0"
 echo " explain: conf_path是配置文件名字，提前编写好规则"
 echo " explain: current_path是安装包的当前路径，末尾添加/"
 echo " explain: ReleaseName是安装包名字"
 exit 1;
fi

conf_name=$1
current_path=$2
ReleaseName=$3

declare -A Confinfo=()

for e in `grep "" ${conf_name}`
do
key=`echo $e | awk -F "=" '{ if(NF>1) {print $1} }'`

  if [ ! -n "$key"  ]
  then
  continue
  else
  Confinfo[${key}]=`echo $e | awk -F "=" '{ if(NF>1) {print $2} }'`
  fi

echo "$key:${Confinfo[$key]}"

#sed -i "s#--$key--#${Confinfo[$key]}#" ${current_path}${ReleaseName}/conf/agent/agent-conf.properties


find ${current_path}${ReleaseName}/conf/ -type f | xargs sed -i "s#--$key--#${Confinfo[$key]}#" 

find ${current_path}${ReleaseName}/config/ -type f | xargs sed -i "s#--$key--#${Confinfo[$key]}#"


done
