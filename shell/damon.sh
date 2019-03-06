#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

trap '' 1 2 3 6 15			# we shouldn't let anyone kill us 
#trap "interrupt" 1 2 3 6 15			# we shouldn't let anyone kill us 

interrupt() {
    echo
    echo "Aborting!"
    echo
    cleanup
    stty echo
    exit 1
}

#only for debug
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SHELL_LIB=./

source $SHELL_LIB/shellLib.sh
host=172.24.115.218
 
changePassword  $host root mysql3 root mysql3

print_default > a.out