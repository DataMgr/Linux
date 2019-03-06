#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell


function maxString()
{
  l_retVal=$(echo "$1 $2" | awk '{if ($1"" > $2"") print "yes"; else print "no"}')
  if [ "$l_retVal" = "yes" ];then
    echo $1
  else
    echo $2
  fi
}

function minString()
{
  l_retVal=$(echo "$1 $2" | awk '{if ($1"" > $2"") print "yes"; else print "no"}')
  if [ "$l_retVal" = "yes" ];then
    echo $2
  else
    echo $1
  fi
}

#AssertEqual UserName xMySQL x$UserName
AssertEqual()
{
  local l_varName="$1"
  local l_varExpectedValue="$2"
  local l_varValue="$3"

  if [ "x$l_varValue" != "x$l_varExpectedValue" ]
  then
    echo "The value[$l_varValue] of a variable[$l_varName] is not what we expect[$l_varExpectedValue]";
	exit 1
  fi
}

#AssertNotNull UserName $UserName
AssertNotNull()
{
  local l_varName="$1" 
  local l_varValue="$2"

  if [ "x$l_varValue" = "x" ]
  then
    echo "The value of a variable[$l_varName] is required";
	exit 1
  fi
}

traceShell()
{
  case $TRACE_SHELL in
    1) set -x ;;
    2) set -xv ;;
    *) ;;
   esac
}

unTraceShell()
{
  case $TRACE_SHELL in
    1) set +x ;;
    2) set +xv ;;
    *) ;;
   esac
}

printError()
{
  local l_msg="$*"
  if [ "$l_msg" != "" ]
  then
    echo -e "\033[1;5;31m $l_msg. \033[0m"
  fi
}

printWarning()
{
  local l_msg="$*"
  if [ "$l_msg" != "" ]
  then
    echo -e "\033[0;33;1m $l_msg. \033[0m"
  fi
}

echoMsg()
{
  local i_level=$1
  shift 1
  
  local l_msg="$*"
  
  #显示日志 -------{
  if [ $i_level -eq $WARNING ]
  then
    printWarning "$l_msg"
  elif  [ $i_level -eq $ERROR ]
  then
    printError  "$l_msg"
  else
    echo  "${g_logLevel[$i_level]}, $l_msg"
  fi
  #显示日志 -------}
}

#usage: writeLog
#                 -l(默认值:1) 日志的输出级别：0: DEBUG 1:INFO 2:WARNING 3:ERROR
#                 -s(默认值:s) 日志的输出方式：(1)日志在屏幕显示(e),(2)只记录到日志文件(s),(3)做(1)、(2)的事情(t)
#                 -g(默认值:noLogGroup) 日志组
#                 -p(默认值:$$) 进程号，建议使用 -p $$
#                 -u(默认值:noUserName) 是否指定用哪个用户来输出日志，即在日志信息中记录 userName:$userName
#                 \? 显示帮助信息
#                 content 日志的描述信息
#用法案例:
#      (1)unset g_dba_shell_elapse
#      (2)g_logLevelSetting=1
#      (3)g_logFile=alert.csv
#         writeLog -l 3 -s s -g model -p $$ -u liu.cs  test hello world!
#         style(E,S,T) level(D,I,W,E)
#         组合 (EDLOG EILOG EWLOG EELOG)(SDLOG SILOG SWLOG SELOG)(TDLOG TILOG TWLOG TELOG)
writeLog()
{
  local i_level=""
  local i_style=""
  local i_logGroup=""
  local i_pid=""
  local i_userName=""

  local l_currentSecond=""
  local l_elapse=""
  local l_msgContent=""
  local l_msgHeader=""
  local l_shiftPos=""

  while getopts ":l:s:g:p:u:" options
  do
    case $options in
    l) 
	  i_level=$OPTARG
      l_shiftPos=`expr $l_shiftPos + 2 `
      ;;
    s) 
	  i_style=$OPTARG #e:echo s:log t: e and s
      l_shiftPos=`expr $l_shiftPos + 2 `
      ;;
    g) 
	  i_logGroup=$OPTARG
      l_shiftPos=`expr $l_shiftPos + 2 `
      ;;
    p) 
	  i_pid=$OPTARG
      l_shiftPos=`expr $l_shiftPos + 2 `
      ;;
    u) 
	  i_userName=$OPTARG
      l_shiftPos=`expr $l_shiftPos + 2 `
      ;;
    \?) 
	  echo "Invalid option: -$OPTARG, Usage writeLog [-lsgpu] [content]"
      exit 1
      ;;
	:)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
    esac
  done
  shift $l_shiftPos

  unset OPTARG
  unset OPTERR
  unset OPTIND

  if [ "$g_logLevelSetting" == "" ]
  then
    g_logLevelSetting=0
  fi

  if [ $g_logLevelSetting -le $i_level ]
  then    
    if [ "$i_level" == "" ]
    then
      i_level=1
    fi
  
    if [ ! -f $g_logFile ]
    then
      if [ "$g_logFile" == "" ]
      then
        g_logFile="`basename $0`.log"
      fi
      echo "##date_time, hostName, PPID, PID, i_logGroup, operationUser, elapse(s), g_logLevel, logDesc" > $g_logFile
    fi
  
    if [ "$i_pid" == "" ]
    then
      i_pid=$$
    fi
  
    l_msgContent="${g_logLevel[$i_level]}, $*"
    
    l_currentSecond=`date +%s`
    if [ "$g_dba_shell_elapse" == "" ]
    then
      l_elapse="start stat timing."
    else
      l_elapse="`expr $l_currentSecond - $g_dba_shell_elapse `"
    fi
    g_dba_shell_elapse=$l_currentSecond
  
    case $i_style in
    s)
      #记录日志到日志文件中 -------{
      l_msgHeader="`date "+%C%y%m%d %H:%M:%S"`, `hostname`, $PPID, $i_pid, ${i_logGroup:=noLogGroup}, ${i_userName:=noUserName}, $l_elapse,"
      echo "${l_msgHeader}$l_msgContent" >> $g_logFile
      #记录日志到日志文件中 -------}
      ;;
    t)
      #显示日志 -------{
      if [ $i_level -eq 2 ]
      then
        printWarning "$l_msgContent"
      elif  [ $i_level -eq 3 ]
      then
        printError  "$l_msgContent"
      else
        echo  "$l_msgContent"
      fi
      #显示日志 -------}

      #记录日志到日志文件中 -------{
      l_msgHeader="`date "+%C%y%m%d %H:%M:%S"`, `hostname`, $PPID, $i_pid, ${i_logGroup:=noLogGroup}, ${i_userName:=noUserName}, $l_elapse,"
      echo "${l_msgHeader}$l_msgContent" >> $g_logFile
      #记录日志到日志文件中 -------}
      ;;
    *) # 等同于 s
      #记录日志到日志文件中 -------{
      l_msgHeader="`date "+%C%y%m%d %H:%M:%S"`, `hostname`, $PPID, $i_pid, ${i_logGroup:=noLogGroup}, ${i_userName:=noUserName}, $l_elapse,"
      echo "${l_msgHeader}$l_msgContent" >> $g_logFile
      #记录日志到日志文件中 -------}
      ;;
    esac
  fi
}

#usage: toLower string
toUpper()
{
  echo $1|tr '[:lower:]' '[:upper:]'
}

toLower()
{
  echo $1|tr '[:upper:]' '[:lower:]'
}

ltrim()
{
  echo $1 | sed "s/^[ \s]\{1,\}//g"
}

rtrim()
{
  echo $1 | sed "s/[ \s]\{1,\}$//g"
}

trim()
{
  echo $1 | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" 
}


#subString 取子字串
#usage: subString String StartPostion SubStringLength
subString()
{
  if [ $# -lt 1 ]
  then
    printf ""
    return 0
  fi

  echo $* |awk ' {
    if ( NF > 1 )
       pos=$2
    else
      pos=1
    if ( NF > 2 )
      len=$3
    else
      len=length($1)-pos+1

    if ( len > length($1) )
      len=length($1)

    if ( pos < 1 )
      len=1

    printf "%s",substr($1,pos,len)
  }'
  return 0
}


#Sample: curTime=`Time2String`
Time2String() 
{
   l_TS=$(date +%F-%T | tr ':-' '_')
   echo "$l_TS"
}


#sample: LockFile 100 /tmp/runSQL.sql.lock
#        $?:1 参数不正确
#          :2 flock 命令不存在 
#          :3 没有获取到锁
#          :0 获取到了指定的所
#           主脚本退出时，锁自动释放
LockFile() 
{
   local l_fd=$1
   local l_lockFile=$2
   
   if [ "x$1" = "x" -o "x$2" = "x" ] 
   then
     return 1
   fi
   
   flockcmd=$(which flock)
   if [ ! -x $flockcmd ]; then
      echo "can not find flock command or with no permission"
      return 1
   fi

   # create lock file
   eval "exec $l_fd>$l_lockFile"

   # acquier lock, timeout when execute then 1 second
   $flockcmd -w 1 -e -n $l_fd && {
      return 0
   } || {
      return 2
   }
}

#sample: FileLock 100 /tmp/runSQL.sql.lock
#        $?:1 参数不正确
#          :2 flock 命令不存在 
#          :3 没有获取到锁
#          :0 获取到了指定的所
#           主脚本退出时，锁自动释放
UnlockFile() 
{
   local l_fd=$1
   local l_lockFile=$2
   
   if [ "x$1" = "x" -o "x$2" = "x" ] 
   then
     return 1
   fi
   
   flockcmd=$(which flock)
   if [ ! -x $flockcmd ]; then
      echo "can not find flock command or with no permission"
      return 1
   fi

   # create lock file
   eval "exec $l_fd>$l_lockFile"

   # acquier lock, timeout when execute then 1 second
   $flockcmd -w 1 -u -n $l_fd && {
      return 0
   } || {
      return 2
   }
}


# 0:is Active
# 1:参数不正确
# 2:ping失败
IsActive()
{
  if [ $# -ne 1 ]
  then    
    return 1
  fi

  local l_host=$1  
  ping "${l_host}" -c 1 -w 5 >/dev/null
  if [ $? -ne 0 ]
  then
    return 2
  fi

  return 0
}

# 0:is Active
# 1:参数不正确
# 2:ping失败 
FGRunCommand()
{
  local l_host=$1
  shift 1
  local l_cmd="$@"
  
  if [ "x$l_cmd" = "x" ]
  then
    return 1
  fi
  
  IsActive $l_host
  if [ $? -ne 0 ]
  then
    return 2
  fi 
  
  ssh $l_host "$l_cmd"  
}

# 0:is Active
# 1:参数不正确
# 2:ping失败 
BGRunCommand()
{
  local l_host=$1  
  local logFileName=""
  shift 1
  local l_cmd="$@"
  
  if [ "x$l_cmd" = "x" ]
  then
    return 1
  fi
  
  IsActive $l_host
  if [ $? -ne 0 ]
  then
    return 2
  fi 
  
  if [ "x$TMPDIR" = "x" ]
  then
    outputFile="/tmp/$0.log"
  else 
    outputFile="${TMPDIR}/$0.log"
  fi
  
  nohup ssh $l_host "date '+%C%y%m%d_%H%M%S' && $l_cmd && date '+%C%y%m%d_%H%M%S' && echo done. by liu.s  "  >> ${outputFile}  2>&1 &
}

splitStringToArray()
{
  if [ $# -eq 1 ]
  then
    l_splitChar=" "
  elif [ $# -eq 2 ]
  then
    l_splitChar="${2}"
  else
    return 1
  fi

  local l_string="${1}"
  for str in `echo $l_string | awk -v ch="${l_splitChar}" '{ nCount=split($0,myarr,ch); for(i=1;i<=nCount;i++) { print myarr[i]} }'`
  do
    echo "${str}"
  done
}

#alias rm=trash
trash()
{
  declare -a myDir
  local l_cnt=0
  local l_trashDir=~/.trash/

  l_para=$1
  while [ "x$l_para" != "x" ];do

	echo $l_para | grep -E "^-" > /dev/null
	if [ $? -ne 0 ]
	then
	  myDir[$l_cnt]=$l_para
	  l_cnt=`expr $l_cnt + 1 `
	fi

	shift 1
	l_para=$1
	
  done

  mkdir -p $l_trashDir 
  for item in ${myDir[@]}
  do 
    if [ -e $l_trashDir/$item -a -e $item ]
	then
	  CURRENT_DATE=`date "+%C%y%m%d_%H%M%S"`
	  l_trashDir=${l_trashDir}/${item}_${CURRENT_DATE}
	  mkdir -p $l_trashDir
	  mv $item $l_trashDir
	else
      [ -e $item ] && mv $item $l_trashDir
	fi
  done
} 

# Get the key value of input arguments format like '--args=value'.
get_key_value()
{
    echo "$1" | sed 's/^--[a-zA-Z_-]*=//' 
}


get_symlink()
{
  file=$1
  file=$(echo $file | sed 's/\/$//')

  # if the file is a symlink, try to resolve it
  if [ -h $file ];
  then
    file=`ls -l $file | awk '{ print $NF }'`
  fi

  case $file in
    /*) echo "$file";;
    */*) tmp=`pwd`/$file; echo $tmp | sed -e 's;/\./;/;' ;;
    *) which $file ;;
  esac
}

get_OS_Info()
{
	OS_ARCH=$(uname -i)
	OS_MAJOR_VERSION=$(cut -f7 -d' ' /etc/redhat-release | cut -f1 -d'.')
	OS_MINOR_VERSION=$(cut -f7 -d' ' /etc/redhat-release | cut -f2 -d'.')
	OS_NAME=$(uname)
}

killProcess()
{
  local pName=$1
  
  if [ "x" != "x$pName" ]
  then
    kill -9 $(pidof pName)
  fi
}

gen_hosts()
{
	echo "# Do not remove the following line, or various programs" > /etc/hosts
	echo "# that require network functionality will fail." >> /etc/hosts
	echo "127.0.0.1         localhost.localdomain localhost" >> /etc/hosts
	IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
	echo "$IP  ldap.hortonworks.com  ldap" >> /etc/hosts
}

function ppid () 
{
   ps -p ${1:-$$} -o ppid=;
}