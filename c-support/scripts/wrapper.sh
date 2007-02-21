#!/bin/bash
#===============================================================================
#          FILE:  wrapper.sh
#         USAGE:  ./wrapper.sh executable [cmd-line-args] 
#   DESCRIPTION:  Wraps the execution of a programm or script.
#                 Use with xterm: xterm -e wrapper.sh executable cmd-line-args
#                 This script is used by several plugins:
#                  bash-support.vim, c.vim and perl-support.vim
#       OPTIONS:  ---
#  REQUIREMENTS:  which(1) - shows the full path of (shell) commands.
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  1.2
#       CREATED:  23.11.2004 18:04:01 CET
#      REVISION:  17.03.2005 - executable quoted
#      REVISION:  18.02.2006 - look for the full pathname of an executable
#===============================================================================

command=${@}                             # the complete command line
executable=${1}                          # name of the executable; may be quoted

fullname=$(which $executable)
[ $? -eq 0 ] && executable=$fullname

if [ ${#} -ge 1 ] && [ -x "$executable" ]
then
  shift
  "$executable" ${@}
  echo -e "\n\n\"${command}\" returned ${?}"
else
  echo -e "\n  !! file \"${executable}\" does not exist or is not executable !!"
fi
echo -e "  ... press return key ... "
read dummy
