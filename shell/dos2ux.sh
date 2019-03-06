#!/usr/bin/env bash
  
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SCRIPT_PATH=$( cd "$( dirname "$0" )" && pwd ) 
 
find $SCRIPT_PATH -name "*.sh" -o -name "*.pl" -o -name "*.cfg"   -o -name "*.list"   -o -name "*.server" | xargs dos2unix
find $SCRIPT_PATH -name "*.sh" -o -name "*.pl" -o -name "*.Linux" -o -name "*.server"                     | xargs chmod 755
#chmod 755 $SCRIPT_PATH/mysqlAgent/xbstream
#chmod 755 $SCRIPT_PATH/mysqlAgent/xtrabackup
#chmod 755 $SCRIPT_PATH/mysqlAgent/xtrabackup_51
#chmod 755 $SCRIPT_PATH/mysqlAgent/xtrabackup_55 
