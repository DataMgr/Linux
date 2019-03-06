#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

runSQL()
{
  if [ $# -ne 2 ]
  then
    return 1
  fi

  local l_connectString="${1}"
  shift 1
  local l_sql="$@"
  
  l_ret=`sqlplus -S ${l_connectString} << EOF
  SET HEADING OFF
  SET PAGESIZE 0;
  SET FEEDBACK OFF;
  SET VERIFY OFF;
  SET ECHO OFF;
  WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
  WHENEVER OSERROR  EXIT SQL.OSCODE  ROLLBACK;
  ${l_sql};
  QUIT;
EOF`

  if [ "$?" -ne 0 ]
  then
    echo "`echo "${l_ret}" | grep '^ORA\-'`"
    echo "Error:sqlplus connect string:(${l_connectString}), SQL: (${l_sql})!"
    return 1
  else
    echo "${l_ret}"
  fi
}

getAllOracleSID()
{
	declare -i G_ORACLE_CNT=0
	if [ "x$TMP_DIR" = "x" ]
	then
	  TMP_DIR=/tmp/lever
	fi

	mkdir -p $TMP_DIR
	tmpFile=$TMP_DIR/ALL_ORACLE_SID_$$
	ps -ef | grep ora_pmon_ | grep -v grep | awk '{print $8}' > $tmpFile

	while read  tmp_oracle_sid check
	do
	  if [ "x$check" != "x" ]
	  then
		echo "The format of ORACLE_SID is wrong"
		break
	  else
		 G_ARR_ORACLE_SID[$G_ORACLE_CNT]=$tmp_oracle_sid
		 let G_ORACLE_CNT+=1      
	  fi
	done < $tmpFile
	rm -f $tmpFile

	#for ((i=0;i<${#G_ARR_ORACLE_SID[@]};i+=1))
	#do
	#	 echo ${G_ARR_ORACLE_SID[i]}
	#done
}