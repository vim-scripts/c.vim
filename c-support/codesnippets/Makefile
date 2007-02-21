#=======================================================================================
#
#     Filename: Makefile
#  Description: 
#
#        Usage: make              (generate executable                      )
#               make clean        (remove objects, executable, prerequisits )
#               make tarball      (generate compressed archive              )
#               make zip          (generate compressed archive              )
#
#      Version: 1.0
#      Created: 
#     Revision: ---
#
#       Author: 
#      Company: 
#        Email: 
#
#        Notes: C   extension   :  c 
#               C++ extensions  :  cc cpp C 
#               C and C++ sources can be mixed.
#               Prerequisites are generated automatically; makedepend is not
#               needed (see documentation for GNU make Version 3.80, July 2002,
#               section 4.13). The utility sed is used.
#               
#============================================== makefile template version 1.6 ==========

# ------------  name of the executable  ------------------------------------------------
EXECUTABLE      = main

# ------------  list of all source files  ----------------------------------------------
SOURCES         = main.c

# ------------  compiler  --------------------------------------------------------------
CC              = gcc
CXX             = g++

# ------------  compiler flags  --------------------------------------------------------
CFLAGS          = -Wall -O0 -g      # Do not optimize. Produce debugging information.

# ------------  linker-Flags  ----------------------------------------------------------
LFLAGS          = -g

# ------------  additional system include directories  ---------------------------------
GLOBAL_INC_DIR  = 

# ------------  private include directories  -------------------------------------------
LOCAL_INC_DIR   = $(HOME)/include

# ------------  system libraries  (e.g. -lm )  -----------------------------------------
SYS_LIBS        = -lm  

# ------------  additional system library directories  ---------------------------------
GLOBAL_LIB_DIR  = 

# ------------  additional system libraries  -------------------------------------------
GLOBAL_LIBS     = 

# ------------  private library directories  -------------------------------------------
LOCAL_LIB_DIR   = $(HOME)/lib

# ------------  private libraries  (e.g. libxyz.a )  -----------------------------------
LOCAL_LIBS      = 

# ------------  archive generation -----------------------------------------------------
TARBALL_EXCLUDE = *.{o,gz,zip}
ZIP_EXCLUDE     = *.{o,gz,zip}

# ------------  run executable out of this Makefile  (yes/no)  -------------------------
# ------------  cmd line parameters for this executable  -------------------------------
EXE_START       = no
EXE_CMDLINE     = 

#=======================================================================================
# The following statements usually need not to be changed
#=======================================================================================

C_SOURCES       = $(filter     %.c, $(SOURCES))
CPP_SOURCES     = $(filter-out %.c, $(SOURCES))
ALL_INC_DIR     = $(addprefix -I, $(LOCAL_INC_DIR) $(GLOBAL_INC_DIR))
ALL_LIB_DIR     = $(addprefix -L, $(LOCAL_LIB_DIR) $(GLOBAL_LIB_DIR))
GLOBAL_LIBSS    = $(addprefix $(GLOBAL_LIB_DIR)/, $(GLOBAL_LIBS))
LOCAL_LIBSS     = $(addprefix $(LOCAL_LIB_DIR)/, $(LOCAL_LIBS))
ALL_CFLAGS      = $(CFLAGS) $(ALL_INC_DIR)
ALL_LFLAGS      = $(LFLAGS) $(ALL_LIB_DIR)
BASENAMES       = $(basename $(SOURCES))

# ------------  generate the names of the object files  --------------------------------
OBJECTS         = $(addsuffix .o,$(BASENAMES))

# ------------  generate the names of the hidden prerequisite files  -------------------
PREREQUISITES   = $(addprefix .,$(addsuffix .d,$(BASENAMES)))

# ------------  make the executable  ---------------------------------------------------
$(EXECUTABLE):	$(OBJECTS)
ifeq ($(strip $(CPP_SOURCES)),)
								$(CC)  $(ALL_LFLAGS) -o $(EXECUTABLE) $(OBJECTS) $(LOCAL_LIBSS) $(GLOBAL_LIBSS) $(SYS_LIBS)
else                                                                           
								$(CXX) $(ALL_LFLAGS) -o $(EXECUTABLE) $(OBJECTS) $(LOCAL_LIBSS) $(GLOBAL_LIBSS) $(SYS_LIBS)
endif
ifeq ($(EXE_START),yes)
								./$(EXECUTABLE) $(EXE_CMDLINE)
endif

# ------------  include the automatically generated prerequisites  ---------------------
# ------------  if target is not clean, tarball or zip             ---------------------
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),tarball)
ifneq ($(MAKECMDGOALS),zip)
include         $(PREREQUISITES)
endif
endif
endif

# ------------  make the objects  ------------------------------------------------------
%.o:						%.c
								$(CC)  -c $(ALL_CFLAGS) $< 

%.o:						%.cc
								$(CXX) -c $(ALL_CFLAGS) $< 

%.o:						%.cpp
								$(CXX) -c $(ALL_CFLAGS) $< 

%.o:						%.C
								$(CXX) -c $(ALL_CFLAGS) $< 

# ------------  make the prerequisites  ------------------------------------------------
#
.%.d:           %.c
								@$(make-prerequisite-c)

.%.d:						%.cc
								@$(make-prerequisite-cplusplus)

.%.d:						%.cpp
								@$(make-prerequisite-cplusplus)

.%.d:						%.C
								@$(make-prerequisite-cplusplus)

#  canned command sequences
#  echoing of the sed command is suppressed by the leading @

define	make-prerequisite-c
							@$(CC)   -MM $(ALL_CFLAGS) $< > $@.$$$$;            \
							sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@; \
							rm -f $@.$$$$; 
endef

define	make-prerequisite-cplusplus
							@$(CXX)  -MM $(ALL_CFLAGS) $< > $@.$$$$;            \
							sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' < $@.$$$$ > $@; \
							rm -f $@.$$$$; 
endef

# ------------  remove generated files  ------------------------------------------------
# ------------  remove hidden backup files  --------------------------------------------
clean:
								rm  --force  $(EXECUTABLE) $(OBJECTS) $(PREREQUISITES) *~

# ------------ tarball generation ------------------------------------------------------
tarball:
					@lokaldir=`pwd`; lokaldir=$${lokaldir##*/}; \
					rm --force $$lokaldir.tar.gz;               \
					tar --exclude=$(TARBALL_EXCLUDE)            \
					    --create                                \
					    --gzip                                  \
					    --verbose                               \
					    --file  $$lokaldir.tar.gz *

# ------------ zip ---------------------------------------------------------------------
zip:
					@lokaldir=`pwd`; lokaldir=$${lokaldir##*/}; \
					zip -r  $$lokaldir.zip * -x $(ZIP_EXCLUDE)

# ======================================================================================
# vim: set tabstop=2: set shiftwidth=2: 
