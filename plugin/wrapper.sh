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
#      VERSION:  1.0
#      CREATED:  23.11.2004 18:04:01 CET
#     REVISION:  18.12.2004
#===============================================================================

if [ ${#} -ge 1 ] && [ -x "${1}" ]
then
  ${@}             # run and pass parameter without interpretation or expansion
  echo -e "\n\n\"${@}\" returned ${?}"
else
  echo -e "\n  !!!  file \"${1}\" does not exist or is not executable  !!!"
fi
echo -e "  ... press return key ... "
read dummy
