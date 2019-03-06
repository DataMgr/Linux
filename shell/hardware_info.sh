#!/usr/bin/env bash

#ChangeLog:
#created by liuchangsheng 2010-12-30 9:27:02
#2018/04/03 收集整理一些常用的shell

#only for debug
export PS4='+{$LINENO:${FUNCNAME[0]}}'
SCRIPT_PATH=$( cd "$( dirname "$0" )" && pwd ) 
 
source $SCRIPT_PATH/base.sh 


usage() {
    echo 'Usage: mons [OPTION]...

Without argument, it prints connected monitors list with their names and ids.
Options are exclusive and can be used in conjunction with extra options.

Information:
  -h    Prints this help and exits.
  -v    Prints version and exits.

Two monitors:
  -o    Primary monitor only.
  -s    Second monitor only.
  -d    Duplicates the primary monitor.
  -m    Mirrors the primary monitor.
  -e <side>
         Extends the primary monitor to the selected side
         [ top | left | right | bottom ].
  -n <side>
         This mode selects the previous ones, one after another. The argument
         sets the side for the extend mode.

More monitors:
  -O <mon>
        Only enables the monitor with a specified id.
  -S <mon1>,<mon2>:<pos>
        Only enables two monitors with specified ids. The specified position
        places the second monitor on the right (R) or at the top (T).

Extra (in-conjunction or alone):
  --dpi <dpi>
        Set the DPI, a strictly positive value within the range [0 ; 27432].
  --primary <mon_name>
        Select a connected monitor as the primary output. Run the script
        without argument to print monitors information, the names are in the
        second column between ids and status. The primary monitor is marked
        by an asterisk.

Daemon mode:
  -a    Performs an automatic display if it detects only one monitor.
'
}

version() {
    echo 'Mons 0.8.2
Copyright (C) 2017 Thomas "Ventto" Venries.

License MIT: <https://opensource.org/licenses/MIT>.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'
}

# Helps to generate manpage with help2man before installing the library
[ "$1" = '-h' ] && { usage; exit; }
[ "$1" = '-v' ] && { version; exit; }
