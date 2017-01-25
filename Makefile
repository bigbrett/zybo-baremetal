# jason.dahlstrom@gmail.com
TARGET = Debug

# Include each /../include directory in the include paths
INCLUDE_PATHS = ./include
INCDIR = $(foreach d, $(INCLUDE_PATHS), -I$d)

BINDIR =/opt/Xilinx/SDK/2016.2/gnu/arm/lin/bin
AS = ${BINDIR}/arm-xilinx-eabi-as
CC = ${BINDIR}/arm-xilinx-eabi-gcc
LD = ${BINDIR}/arm-xilinx-eabi-ld
SZ = ${BINDIR}/arm-xilinx-eabi-size

ASFLAGS = -g -mcpu=cortex-a9
CCFLAGS = ${INCDIR} -MMD -MP -nostdinc -mthumb-interwork -fno-builtin -O0 -g -Wall -Werror -mcpu=cortex-a9 -c
LDFLAGS = -nostdlib -TZynq.ld

LIBDIR = lib
LIBS = -lgcc

${TARGET}/obj/%.o: %.S
	mkdir -p ${TARGET}/obj/
	${AS} ${ASFLAGS} -o ${TARGET}/obj/${@F} $<
${TARGET}/obj/%.o: %.c
	mkdir -p ${TARGET}/obj/
	${CC} ${CCFLAGS} -o ${TARGET}/obj/${@F} $<
	
VPATH = ./asm ./src

S_SRCS = $(shell find ${VPATH} -maxdepth 1 -name "*.S")
S_OBJS = ${S_SRCS:.S=.o}
C_SRCS = $(shell find ${VPATH} -maxdepth 1 -name "*.c") 
C_OBJS = ${C_SRCS:.c=.o}

OBJS = $(addprefix ${TARGET}/obj/, $(notdir ${S_OBJS} ${C_OBJS}))

all: image

image : ${OBJS}
	${LD} ${LDFLAGS} -L${LIBDIR} -o ${TARGET}/$@.elf ${OBJS} ${LIBS}
	@${SZ} ${TARGET}/$@.elf
	
#
# Remove all build output
#
clean : force
	rm -rf Debug/
	
#
# Bring in header file dependencies.  These are gnerated with the -MMD and -MP
# flags to gcc below.  If the .d file doesn't exist that means the .o file 
# doesn't exist, so the target is built.  If a .o file is built, then a 
# corresponding .d file also exists so this will read in correct dependencies
#
-include $(OBJS:.o=.d)

#
# Indicate that 'force' is never up to date, so the dependent rule always
# executes even if the file "force" exists and appears up to date...
#
.PHONY : force
