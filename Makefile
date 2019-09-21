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

#	- Compilation flags:
#	Compiler and language version
CC := gcc -std=c17
#	If DEBUG is defined, we'll turn on the debug flag and attach address
#	sanitizer on the executables.
DEBUGF := $(if $(DEBUG),-g -fsanitize=address)
CFLAGS :=\
	-Wall \
	-Wextra \
	-Wpedantic\
	-Wshadow \
	-Wunreachable-code
OPT := $(if $(DEBUG),-O0,-O3 -march=native)
LIB := -L$(LIB_DIR)
INC := -I$(INC_DIR) -I$(SRC_DIR)

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
TARGET := $(patsubst %.c, $(OUT_DIR)/%, $(notdir $(MAIN)))

#	- Other source files:
SRC := $(filter-out $(MAIN), $(shell find $(SRC_DIR) -name '*.c'))

#	- Objects to be created:
OBJ := $(patsubst %.c, $(OBJ_DIR)/%.o, $(notdir $(SRC)))

################################################################################
#	Rules:

#	- Executables:
$(TARGET): $(OUT_DIR)/%: $(SRC_DIR)/%.c $(OBJ)
	$(CC) -o $@ $^ $(INC) $(LIB) $(DEBUGF) $(OPT)

#	- Objects:
$(OBJ_DIR)/%.o:
	$(CC) -c -o $@ $(filter %/$*.c, $(SRC)) $(INC) $(CFLAGS) $(DEBUGF) $(OPT)

################################################################################
#	Targets:

.DEFAULT_GOAL = all

all: deps $(TARGET)

clean:
	rm -f $(OBJ_DIR)/*.o $(INC_DIR)/*~ $(TARGET) *~ *.o

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
