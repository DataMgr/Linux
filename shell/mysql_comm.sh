#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

runMySQLCmd()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3"
  shift 3
  local l_cmd="$@"
  
  
  mysql -h${l_Host} -u${l_UserName} -p${l_Pwd} --skip_column_names -e "${l_cmd}" 
}

pingMySQL()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3" 
  
  
  retVal=$(mysqladmin -h${l_Host} -u${l_UserName} -p${l_Pwd} ping) 
  if [ "$retVal" = "mysqld is alive" ]
  then
    return 0
  else
    return 1
  fi    
}

shutdownMySQL()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3" 
  
  
  mysqladmin -h${l_Host} -u${l_UserName} -p${l_Pwd} shutdown 
}

changePassword()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3" 
  local l_User2="$4"
  local l_newPwd="$5"
  
  runMySQLCmd $l_Host $l_UserName $l_Pwd  "UPDATE mysql.user SET password=PASSWORD('$l_newPwd') WHERE User='$l_User2'; commit; FLUSH PRIVILEGES;"
}


#getMySQLEnv SLAVE_SATUS  localhost root MySQL "show status like 'Slave_running'";
#echo $SLAVE_SATUS

#getMySQLEnv BIG_SELECT localhost root MySQL "show variables like 'sql_big_selects'";
#echo $BIG_SELECT
getMySQLEnv()
{
  local l_statusVal="$1"
  local l_Host="$2"
  local l_UserName="$3"
  local l_Pwd="$4"
  shift 4
  local l_cmd="$@"
  local l_MySQLResult=""
  
  
  l_MySQLResult=$(mysql -h${l_Host} -u${l_UserName} -p${l_Pwd} --skip_column_names -e "${l_cmd}")
  l_MySQLResult=$(echo $l_MySQLResult | cut -f2 -d' ' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g")
  eval $l_statusVal=$l_MySQLResult
}

#getMySQLKeyVal MASTER_FILE $host root mysql File "show master status \G" 
#               MASTER_FILE 可以获得具体的master的日志文件
getMySQLKeyVal()
{
  local l_statusVal="$1"
  local l_Host="$2"
  local l_UserName="$3"
  local l_Pwd="$4"
  local l_key="$5"
  shift 5
  local l_cmd="$@"
  local l_MySQLResult=""
  local l_tmpResultFile="/tmp/${l_Host}_`Time2String`"
  
  mysql -h${l_Host} -u${l_UserName} -p${l_Pwd} -e "${l_cmd}" > $l_tmpResultFile
  l_MySQLResult=$(grep -iw "${l_key}:" $l_tmpResultFile| cut -f2 -d':' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" )
  if [ $? -eq 0 ]
  then
    rm -f $l_tmpResultFile
  fi
  
  eval $l_statusVal="$l_MySQLResult"  
}

#getMySQLKeyVal MASTER_FILE $host root mysql File "show master status \G" 
#               MASTER_FILE 可以获得具体的master的日志文件
getMasterStatus()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3"  
  local l_MySQLResult=""
  local l_tmpResultFile="/tmp/${l_Host}_`Time2String`"
  local l_RetVal=1
  local l_key=""
  
  mysql -h${l_Host} -u${l_UserName} -p${l_Pwd} -e "show master status \G" > $l_tmpResultFile  
  
  l_statusVal="MASTER_FILE"
  l_key="File"
  l_MySQLResult=$(grep -iw "${l_key}:" $l_tmpResultFile| cut -f2 -d':' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" )  
  l_RetVal=$?
  eval $l_statusVal="$l_MySQLResult" 

  l_statusVal="MASTER_POS"
  l_key="Position" 
  l_MySQLResult=$(grep -iw "${l_key}:" $l_tmpResultFile| cut -f2 -d':' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" ) 
  if [ $? -eq 0 -a $l_RetVal -eq 0 ]
  then
    rm -f $l_tmpResultFile
  fi
  eval $l_statusVal="$l_MySQLResult"   
}

#getMySQLKeyVal MASTER_FILE $host root mysql File "show master status \G" 
#               MASTER_FILE 可以获得具体的master的日志文件
getSlaveStatus()
{
  local l_Host="$1"
  local l_UserName="$2"
  local l_Pwd="$3"  
  local l_MySQLResult=""
  local l_tmpResultFile="/tmp/${l_Host}_`Time2String`"
  local l_RetVal=1
  local l_key=""
  
  mysql -h${l_Host} -u${l_UserName} -p${l_Pwd} -e "show slave status \G" > $l_tmpResultFile  
  
  l_key="RELAY_MASTER_LOG_FILE"
  l_MySQLResult=$(grep -iw "${l_key}:" $l_tmpResultFile| cut -f2 -d':' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" )  
  l_RetVal=$?
  eval $l_key="$l_MySQLResult" 
  
  l_key="EXEC_MASTER_LOG_POS" 
  l_MySQLResult=$(grep -iw "${l_key}:" $l_tmpResultFile| cut -f2 -d':' | sed "s/^[ \s]\{1,\}//g;s/[ \s]\{1,\}$//g" ) 
  if [ $? -eq 0 -a $l_RetVal -eq 0 ]
  then
    rm -f $l_tmpResultFile
  fi
  eval $l_key="$l_MySQLResult"   
}

syncGap()
{
  local l_RHost="$1"
  local l_RbinLogDir="$2" 
  local l_RbinLog="$3"  
  local l_RbinLogPos="$4"
  local l_lRootPassword="$5"
  local l_tmpResultFile="diffSQL_`Time2String`"
  local l_lDiffSQL="R_L_$l_tmpResultFile"
  
  ssh $l_RHost "cd $l_RbinLogDir && source ~/.bash_profile && mysqlbinlog $l_RbinLog --start-position=$l_RbinLogPos -r $l_tmpResultFile"
  scp $l_RHost:${l_RbinLogDir}/$l_tmpResultFile ${l_lDiffSQL}
  
  mysql -uroot -p$l_lRootPassword < $l_lDiffSQL
}


# Usage will be helpful when you need to input the valid arguments.
usage()
{
cat <<EOF
Usage: $0 [configure-options]
  -?, --help Show this help message.
  --MySQLdir=<> Set the MySQL directory
  --sysbenchdir=<> Set the sysbench directory 
  --defaults-file=<> Set the configure file for MySQL
  --host=<> Set the host name.
  --port=<> Set the port number.
  --database=<> Set the database to sysbench.
  --user=<> Set the user name.
  --password=<> Set the password of user.
  --socket=<> Set the socket file
  --tablesize=<> Set the table seize.
  --engine=<> Set the sysbench engine.
  --min-threads=<> Set the min threads number.
  --max-threads=<> Set the max threads number.
  --max-requests=<> Set the max requests number.
  --max-time=<> Set the max time number.
  --step=<> Set the thread incremental step.
  --var=<> Set the variable to test.
  --value=<> Set the value of the variable. 
  --interval=<> Set the interval time.
  --count=<> Set the count of test.
  -p,--prepare,--prepare=<> Set the prepare procedure.
  -c,--cleanup,--cleanup=<> Set the cleanup procedure.
  -r,--run,--run=<> Set the run procedure.
  -s,--server,--server=<> Set the server whether start and shutdown
                                   within the test or not.
  --outputdir=<> Set the output directory. 

Note: this script is intended for internal use by developers.

EOF
}

# Print the default value of the arguments of the script.
print_default()
{
cat <<EOF
  The default value of the variables:
  
  MySQLdir $MySQLDIR
  sysbenchdir $SYSBENCHDIR
  defaults-file $CONFIG
  host $HOST
  port $PORT
  database $DATABASE
  user $USER
  password $PASSWORD
  socket $SOCKET
  tablesize $TABLESIZE
  engine $ENGINE
  min-threads $MIN_THREADS
  max-threads $MAX_THREADS
  max-requests $REQUESTS
  max-time $TIME
  step $STEP
  var $VAR
  value $VALUE
  interval $INTERVAL
  count $COUNT
  prepare TRUE
  cleanup TRUE
  run TRUE
  server TRUE
  outputdir $OUTPUTDIR

EOF
}

# Parse the input arguments and get the value of the input argument.
parse_options()
{
  while test $# -gt 0
  do
    case "$1" in 
    --MySQLdir=*)
      MySQLDIR=`get_key_value "$1"`;;
    --sysbenchdir=*)
      SYSBENCHDIR=`get_key_value "$1"`;;
    --defaults-file=*)
      CONFIG=`get_key_value "$1"`;;
    --host=*)
      HOST=`get_key_value "$1"`;;
    --port=*)
      PORT=`get_key_value "$1"`;;
    --database=*)
      DATABASE=`get_key_value "$1"`;;
    --user=*)
      USER=`get_key_value "$1"`;;
    --password=*)
      PASSWORD=`get_key_value "$1"`;;
    --socket=*)
      SOCKET=`get_key_value "$1"`;;
    --tablesize=*)
      TABLESIZE=`get_key_value "$1"`;;
    --engine=*)
      ENGINE=`get_key_value "$1"`;;
    --min-threads=*)
      MIN_THREADS=`get_key_value "$1"`;;
    --max-threads=*)
      MAX_THREADS=`get_key_value "$1"`;;
    --max-requests=*)
      REQUESTS=`get_key_value "$1"`;;
    --max-time=*)
      TIME=`get_key_value "$1"`;;
    --step=*)
      STEP=`get_key_value "$1"`;;
    --var=*)
      VAR=`get_key_value "$1"`;;
    --value=*)
      VALUE=`get_key_value "$1"`;;
    --interval=*)
      INTERVAL=`get_key_value "$1"`;;
    --count=*)
      COUNT=`get_key_value "$1"`;;
    -p | --prepare)
      PREPARE=1;;
    --prepare=*)
      PREPARE=`get_key_value "$1"`;;
    -r | --run)
      RUN=1;;
    --run=*)
      RUN=`get_key_value "$1"`;;
    -c | --cleanup)
      CLEANUP=1;;
    --cleanup=*)
      CLEANUP=`get_key_value "$1"`;;
    -s | --server)
      SERVER=1;;
    --server=*)
      SERVER=`get_key_value "$1"`;;
    --outputdir=*)
      OUTPUTDIR=`get_key_value "$1"`+"/${DATETIME}";;
    -? | --help)
      usage
      print_default
      exit 0;;
    *)
      echo "Unknown option '$1'"
      exit 1;;
    esac
    shift
  done
}
