#=======================================================================================
#
#     Filename: Makefile
#  Description: 
#
#        Usage: make
#               make clean
#               make tarball
#
#      Version: 1.0
#      Created: 
#     Revision: ---
#
#       Author: 
#      Company: 
#        Email: 
#
#        Notes: Prerequisites are generated automatically; makedepend is not needed
#               (see documentation for GNU make Version 3.79, April 2000, section 4.12).
#               The utility sed and BASH file tests are used.
#               
#=======================================================================================

# ------------  C++ file name extensions  ----------------------------------------------
CPP_EXTENSION  = cc 

# ------------  compiler  --------------------------------------------------------------
CC              = g++

# ------------  compiler flags  --------------------------------------------------------
CFLAGS          = -g -Wall

# ------------  linker-Flags  ----------------------------------------------------------
LFLAGS          = -g

# ------------  name of the executable  ------------------------------------------------
EXECUTABLE      = main.e

# ------------  list of all source files  ----------------------------------------------
C_SOURCES       = main.c

CPP_SOURCES     = 

# ------------  additional system include directories  ---------------------------------
GLOBAL_INC_DIR  = /usr/X11/include

# ------------  additional system library directories  ---------------------------------
GLOBAL_LIB_DIR  = /usr/X11/lib

# ------------  system libraries  ------------------------------------------------------
SYS_LIBS        = -lm  -lX11

# ------------  private include directories  -------------------------------------------
LOCAL_INC_DIR   = .

# ------------  private library directories  -------------------------------------------
LOCAL_LIB_DIR   = .

# ------------  private libraries  -----------------------------------------------------
LOCAL_LIBS      = 

# ------------  tarball generation -----------------------------------------------------
tarball_exclude = 

#=======================================================================================
# The following statements usually need not to be changed
#=======================================================================================

ALL_INC_DIR     = $(LOCAL_INC_DIR) $(GLOBAL_INC_DIR)
ALL_LIB_DIR     = $(LOCAL_LIB_DIR) $(GLOBAL_LIB_DIR)
ALL_CFLAGS      = $(CFLAGS)  -I$(ALL_INC_DIR)
ALL_LFLAGS      = $(LFLAGS)  -L$(ALL_LIB_DIR) $(SYS_LIBS) $(LOCAL_LIBS)

# ------------  generate the names of the object files  --------------------------------
OBJECTS         = ${C_SOURCES:.c=.o} 
OBJECTS        += $(CPP_SOURCES:.cc=.o)

# ------------  generate the names of the hidden prerequisite files  -------------------
PREREQUISITES   = $(addprefix .,${C_SOURCES:.c=.d} )
PREREQUISITES  += $(addprefix .,${CPP_SOURCES:.cc=.d} )

# ------------  make the executable  ---------------------------------------------------
$(EXECUTABLE):	$(OBJECTS)
								$(CC) $(ALL_LFLAGS) -o $(EXECUTABLE) $(OBJECTS)
								./$(EXECUTABLE)

# ------------  list of the automatically generated prerequisites  ---------------------
include         $(PREREQUISITES)

# ------------  make the objects  ------------------------------------------------------
%.o:						%.c
								$(CC) -c $(ALL_CFLAGS) $< 

%.o:						%.cc
								$(CC) -c $(ALL_CFLAGS) $< 

# ------------  make the prerequisites  ------------------------------------------------
#  echoing of the sed command is suppressed by the leading @
#
.%.d:           %.c
								@set -e; $(CC)  -MM $< \
								| sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
								[ -s $@ ] || rm -f $@
								@[ -f $@ ]&& echo "prerequisite file  $@  generated"

.%.d:           %.cc
								@set -e; $(CC)  -MM $< \
								| sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
								[ -s $@ ] || rm -f $@
								@[ -f $@ ]&& echo "prerequisite file  $@  generated"

# ------------  remove generated files  ------------------------------------------------
# ------------  remove hidden backup files  --------------------------------------------
clean:
								rm  --force  $(EXECUTABLE) $(OBJECTS) $(PREREQUISITES)
								rm  --force  *~

# ------------ tarball generation ------------------------------------------------------
tarball:
					lokaldir=`pwd`; lokaldir=$${lokaldir##*/}; \
					rm --force $$lokaldir.tar.gz;              \
					tar --exclude=$(tarball_exclude)           \
					    --create                               \
					    --gzip                                 \
					    --verbose                              \
					    --file  $$lokaldir.tar.gz *

# ======================================================================================
# vim: set tabstop=2: set shiftwidth=2: 
