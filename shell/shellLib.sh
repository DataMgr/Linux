#!/bin/bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

#only for debug
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SCRIPT_PATH=$( cd "$( dirname "$0" )" && pwd )

SHELL_LIB=$SCRIPT_PATH

source $SHELL_LIB/base.sh
source $SHELL_LIB/mysql_comm.sh
source $SHELL_LIB/oracle_comm.sh