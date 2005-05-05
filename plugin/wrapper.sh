#!/bin/bash
#===============================================================================
#         FILE:  wrapper.sh
#        USAGE:  ./wrap.sh executable [cmd-line-args] 
#  DESCRIPTION:  Wraps the execution of a programm or script.
#                Use with xterm: xterm -e wrapper.sh executable cmd-line-args
#                This script is used by several plugins:
#                 bash-support.vim, c.vim and perl-support.vim
#       AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#      COMPANY:  FH Südwestfalen, Iserlohn
#      VERSION:  1.1
#      CREATED:  23.11.2004 18:04:01 CET
#     REVISION:  17.03.2005 - executable quoted
#===============================================================================

command=${@}                             # the complete command line
executable=${1}                          # name of the executable; may be quoted

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
