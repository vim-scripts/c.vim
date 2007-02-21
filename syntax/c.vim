"===================================================================================
"
"         FILE:  c.vim
"  DESCRIPTION:  syntax file
"                enable syntax based folding
"                part of the c-support plugin
"
"       AUTHOR:  Dr.-Ing. Fritz Mehner
"        EMAIL:  mehner@fh-swf.de
"      COMPANY:  FH Südwestfalen, Iserlohn
"      VERSION:  1.0
"      CREATED:  11.03.2006
"     REVISION:  ---
"===================================================================================
"
" fold C blocks
"
syn region cBlock start="{" end="}" transparent fold
set foldmethod=syntax
set foldlevel=999

