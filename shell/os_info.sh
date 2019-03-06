#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

#only for debug
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SCRIPT_PATH=$( cd "$( dirname "$0" )" && pwd ) 
 
source $SCRIPT_PATH/common.sh 
 
set -xv 
getAllOracleSID
status=$?
echo $status
 
for ((i=0;i<${#G_ARR_ORACLE_SID[@]};i+=1))
do
	 echo ${G_ARR_ORACLE_SID[i]}
done 


passwd root <<EOF
hadoophdp
hadoophdp
EOF
