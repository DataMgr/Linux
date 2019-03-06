#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

#only for debug
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SCRIPT_PATH=$( cd "$( dirname "$0" )" && pwd ) 
 
source $SCRIPT_PATH/base.sh 
 
#set -xv  



g_LOGFILE="a.log"
g_PROGRAM_NAME="mysqlMgr.sh"
g_SYSLOG=yes
# Logging function
function writeLog() 
{	  
    l_pName=${g_PROGRAM_NAME:=$0}
	l_logFile=${g_logFile:=syslog.log} 
	l_logFile=$SCRIPT_PATH/$l_logFile
	
	l_msgHeader="`date "+%C%y%m%d %H:%M:%S"`, `hostname`, `whoami`, ppid:$PPID, pid:$$" 
	  
    if [ "$g_VERBOSE" == "no" ] ; then
        printf "%s --> %s\n" "$l_msgHeader" "$l_pName, $*" >>"$l_logFile"
    else
        printf "%s --> %s\n" "$l_msgHeader" "$l_pName, $*" | tee -a "$l_logFile"
    fi
    if [ "$g_SYSLOG" = yes ] ; then
        logger -i -p local0.notice -t "$l_pName" "$*"
    fi
}

writeLog "TEST"


