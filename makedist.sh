#!/bin/bash
#===============================================================================
#
#          FILE:  makedist.sh
# 
#         USAGE:  ./makedist.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       VERSION:  1.0
#       CREATED:  12.05.2007 08:41:41 CEST
#      REVISION:  $Id: makedist.sh,v 1.7 2011/06/01 08:36:24 mehner Exp $
#===============================================================================

archive_name="cvim"
exclude_list="makedist.sh hotkeys.latex/\* *.swp *.cvsignore"

rm --force $archive_name".zip"

#-------------------------------------------------------------------------------
#   Hotkeys: PDF und LaTeX-Quelle kopieren
#-------------------------------------------------------------------------------
cp hotkeys.latex/c-hotkeys.tex c-support/doc/
cp hotkeys.latex/c-hotkeys.pdf c-support/doc/

#-------------------------------------------------------------------------------
#   persönliche Angaben aus dem Haupt-Template-File ändern
#-------------------------------------------------------------------------------
templatefile=./c-support/templates/Templates

if [ -f $templatefile ] ; then
	sed --in-place '/^\s*|AUTHOR|\s*=/s/Dr. Fritz Mehner/YOUR NAME/'  $templatefile
	sed --in-place '/^\s*|AUTHORREF|\s*=/s/fgm//'                     $templatefile
	sed --in-place '/^\s*|EMAIL|\s*=/s/mehner@fh-swf.de//'            $templatefile
	sed --in-place '/^\s*|COMPANY|\s*=/s/FH Südwestfalen, Iserlohn//' $templatefile
else
	echo -e "Datei ${templatefile} nicht gefunden!\n"
fi

#-------------------------------------------------------------------------------
#   Archiv erstellen
#-------------------------------------------------------------------------------
zip -r "$archive_name" . -x "$exclude_list" 

