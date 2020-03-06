#	-- c-template --
#
#	c-template's project Makefile.
#
#	Utilization example:
#		make <TARGET> ["DEBUG=true"]
#
#	@param TARGET
#		Can be any of the following:
#		all - builds the project (DEFAULT TARGET)
#		clean - cleans up all binaries generated during compilation
#		redo - cleans up and then builds
#		help - shows the utilization example
#
#	@param "DEBUG=true"
#		When present, the build will happen in debug mode.
#
#	@author
#		@hcpsilva - Henrique Silva
#
#	Make's default action is "all" when no parameters are provided.


################################################################################
#	Definitions:

#	- Project's directories:
INC_DIR := include
OBJ_DIR := bin
OUT_DIR := build
SRC_DIR := src
LIB_DIR := lib

DEBUG :=

#	Add the extra paths through these variables in the command line
LIB_EXTRA :=
INC_EXTRA :=

#	- Compilation flags:
#	Compiler and language version
CC := gcc -std=c17
#	If DEBUG is defined, we'll turn on the debug flag and attach address
#	sanitizer on the executables.
DEBUGF := $(if $(DEBUG),-g -fsanitize=address)
CFLAGS :=\
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wshadow \
	-Wunreachable-code
LDFLAGS :=\
	-shared \
	-fPIC
OPT := $(if $(DEBUG),-O0,-O3 -march=native)
LIB := -L$(LIB_DIR) $(LIB_EXTRA)
INC := -I$(INC_DIR) -I$(SRC_DIR) $(INC_EXTRA)

#	Put here any dependencies you wish to include in the project, according to the
#	following format:
#	"<name> <URL> [<URL> ...]" "<name> <URL> [<URL> ...]" ...
DEPS :=

################################################################################
#	Files:

#	- Main source files:
#	Presumes that all "main" source files are in the root of SRC_DIR
MAIN := $(wildcard $(SRC_DIR)/*.c)

#	- Path to all final binaries:
TARGET_EXE := $(patsubst %.c, $(OUT_DIR)/%, $(notdir $(MAIN)))

#	- Library directories:
LIBS := $(shell find $(LIB_DIR) -maxdepth 1 -mindepth 1 -type d)

#	- Path to all final libraries:
TARGET_LIB := $(patsubst %, $(LIB_DIR)/lib%.so, $(basename $(LIBS)))

#	- Other source files:
EXE_SRC := $(shell find $(SRC_DIR) -name '*.c' | cut -d'/' -f2-)

#	- Objects to be created:
EXE_OBJ := $(patsubst %.c, $(OBJ_DIR)/%.o, $(EXE_SRC))

#	- Library source files:
LIB_SRC := $(shell find $(LIB_DIR) -mindepth 2 -type f -name '*.c' | cut -d'/' -f2-)

#	- Library objects:
LIB_OBJ := $(patsubst %.c, $(OBJ_DIR)/%.o, $(LIB_SRC))

################################################################################
#	Rules:

#	- Executables:
$(TARGET_EXE): $(OUT_DIR)/%: $(SRC_DIR)/%.c $(EXE_OBJ)
	$(CC) -o $@ $^ $(INC) $(LIB) $(DEBUGF) $(OPT)

#	- Objects:
$(EXEC_OBJ): $(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) -c -o $@ $< $(INC) $(CFLAGS) $(DEBUGF) $(OPT)

#	- Shared Libraries:
$(TARGET_LIB): $(LIB_DIR)/lib%.so: $(LIB_OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) $(FUN) $(INC) $(CFLAGS) $(OPT)

#	- Library objects
$(LIB_OBJ): $(OBJ_DIR)/%.o: $(LIB_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) -c -o $@ $< $(INC) $(CFLAGS) $(DEBUGF) $(OPT)

################################################################################
#	Targets:

.DEFAULT_GOAL = all

all: deps $(TARGET_LIB) $(TARGET_EXE)

clean:
	rm -rf $(OBJ_DIR)/* $(INC_DIR)/*~ $(TARGET_EXE) $(TARGET_LIB) *~ *.o

redo: clean all

help:
	@echo "c-template's project Makefile."
	@echo
	@echo "Utilization example:"
	@echo " make <TARGET> ['DEBUG=true']"
	@echo
	@echo "@param TARGET"
	@echo " Can be any of the following:"
	@echo " all - builds the project (DEFAULT TARGET)"
	@echo " clean - cleans up all binaries generated during compilation"
	@echo " redo - cleans up and then builds"
	@echo " help - shows the utilization example"
	@echo
	@echo "@param 'DEBUG=true'"
	@echo " When present, the build will happen in debug mode."

################################################################################
#	Debugging and etc.:

#	Debug of the Make variables
print-%:
	@echo $* = $($*)

#	Dependency fetching
deps:
	@./scripts/build.sh '$(DEPS)'

.PHONY: all clean redo help print-% deps
