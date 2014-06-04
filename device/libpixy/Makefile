######################################################################################
# GNU GCC ARM Embeded Toolchain base directories and binaries 
######################################################################################
GCC_BASE = "C:/Program Files (x86)/GNU Tools ARM Embedded/4.8 2014q1/"
#GCC_BIN  = $(GCC_BASE)bin/
GCC_LIB  = $(GCC_BASE)lib/
GCC_INC  = $(GCC_BASE)include/
AS       = $(GCC_BIN)arm-none-eabi-as
CC       = $(GCC_BIN)arm-none-eabi-gcc
CPP      = $(GCC_BIN)arm-none-eabi-g++
LD       = $(GCC_BIN)arm-none-eabi-gcc
OBJCOPY  = $(GCC_BIN)arm-none-eabi-objcopy


######################################################################################
# Custom options for cortex-m and cortex-r processors 
######################################################################################
CORTEX_M0PLUS_CC_FLAGS  = -mthumb -mcpu=cortex-m0plus -mthumb-interwork 
CORTEX_M0PLUS_LIB_PATH  = $(GCC_LIB)armv6-m
CORTEX_M0_CC_FLAGS      = -mthumb -mcpu=cortex-m0 -mthumb-interwork 
CORTEX_M0_LIB_PATH      = $(GCC_LIB)armv6-m
CORTEX_M1_CC_FLAGS      = -mthumb -mcpu=cortex-m1
CORTEX_M1_LIB_PATH      = $(GCC_LIB)armv6-m
CORTEX_M3_CC_FLAGS      = -mthumb -mcpu=cortex-m3
CORTEX_M3_LIB_PATH      = $(GCC_LIB)armv7-m
CORTEX_M4_NOFP_CC_FLAGS = -mthumb -mcpu=cortex-m4
CORTEX_M4_NOFP_LIB_PATH = $(GCC_LIB)armv7e-m
CORTEX_M4_SWFP_CC_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=softfp -mfpu=fpv4-sp-d16
CORTEX_M4_SWFP_LIB_PATH = $(GCC_LIB)armv7e-m/softfp
CORTEX_M4_HWFP_CC_FLAGS = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
CORTEX_M4_HWFP_LIB_PATH = $(GCC_LIB)armv7e-m/fpu
CORTEX_R4_NOFP_CC_FLAGS = -mthumb -march=armv7-r
CORTEX_R4_NOFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb
CORTEX_R4_SWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=softfp -mfpu=vfpv3-d16
CORTEX_R4_SWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/softfp
CORTEX_R4_HWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=hard -mfpu=vfpv3-d16
CORTEX_R4_HWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/fpu
CORTEX_R5_NOFP_CC_FLAGS = -mthumb -march=armv7-r
CORTEX_R5_NOFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb
CORTEX_R5_SWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=softfp -mfpu=vfpv3-d16
CORTEX_R5_SWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/softfp
CORTEX_R5_HWFP_CC_FLAGS = -mthumb -march=armv7-r -mfloat-abi=softfp -mfloat-abi=hard -mfpu=vfpv3-d16
CORTEX_R5_HWFP_LIB_PATH = $(GCC_LIB)armv7-r/thumb/fpu


######################################################################################
# Main makefile project configuration
#    PROJECT      = <name of the target to be built>
#    MCU_CC_FLAGS = <one of the CC_FLAGS above>
#    MCU_LIB_PATH = <one of the LIB_PATH above>
#    OPTIMIZE_FOR = < SIZE or nothing >
#    DEBUG_LEVEL  = < -g compiler option or nothing >
#    OPTIM_LEVEL  = < -O compiler option or nothing >
######################################################################################
PROJECT           = libpixy_m0
MCU_CC_FLAGS      = $(CORTEX_M0PLUS_CC_FLAGS)
MCU_LIB_PATH      = $(CORTEX_M0PLUS_LIB_PATH)
OPTIMIZE_FOR      = 
DEBUG_LEVEL       = 
OPTIM_LEVEL       = 
LINKER_SCRIPT     = ../STM32F4xx_1024k_flash.ld
PROJECT_INC_PATHS = -I. -I"../../common" -I"../video"
PROJECT_LIB_PATHS = -L.
PROJECT_LIBRARIES = -Lpixy_m0 -Lpixy_m4
#PROJECT_SYMBOLS   = -DTOOLCHAIN_GCC_ARM -DNO_RELOC='0'  
PROJECT_SYMBOLS   = -DPIXY -DIPC_SLAVE -DCORE_M0 -DNO_RELOC='0' 

#libpixy_m0
LIBPIXY_M0_SRC = chirp debug lpc43xx_uart ipc_mbx smlink debug_frmwrk
#STARTUP = startup_stm32f4xx_gnu.S
BUILD_DIR = .
LIBPIXY_M0_OBJS = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(LIBPIXY_M0_SRC)))
LIBPIXY_M0_TARGET = libpixy_m0.a

#libpixy_m4
LIBPIXY_M4_SRC  = debug_frmwrk fpu_init lpc43xx_adc lpc43xx_cgu lpc43xx_scu lpc43xx_uart
LIBPIXY_M4_SRC += platform_config system_LPC43xx usbcore usbdesc usbhw usbuser 
LIBPIXY_M4_SRC += ipc_mbx  lpc43xx_ssp

LIBPIXY_M4_SRCPP = sccb usblink smlink camera led rcservo misc power param flash chirp
LIBPIXY_M4_SRCA  = startup_stm32f4xx_gnu

LIBPIXY_M4_OBJS  = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(LIBPIXY_M4_SRC)))
LIBPIXY_M4_OBJS += $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(LIBPIXY_M4_SRCPP)))
LIBPIXY_M4_OBJS += $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(LIBPIXY_M4_SRCA)))
LIBPIXY_M4_TARGET = libpixy_m4.a

#exec_m0
EXEC_M0_SRC = ../video/main_m0 startup_stm32f4xx_gnu qqueue exec_m0 frame_m0 rls_m0
EXEC_M0_OBJS  = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(EXEC_M0_SRC)))
EXEC_M0_TARGET = exec_m0.o

#video_m4
VIDEO_M4_SRC = lpc43xx_i2c
VIDEO_M4_SRCPP   = ../video/main_m4 ../video/conncomp ../video/exec 
VIDEO_M4_SRCPP  += ../video/progblobs ../video/progvideo ../video/progpt ../video/button
VIDEO_M4_SRCPP  += ../../common/blob ../../common/blobs ../../common/colorlut
VIDEO_M4_SRCPP  += qqueue i2c serial analogdig spi uart ../video/progchase
VIDEO_M4_OBJS   = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(VIDEO_M4_SRC)))
VIDEO_M4_OBJS  += $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(VIDEO_M4_SRCPP)))
VIDEO_M4_TARGET = video_m4.o

######################################################################################
# Main makefile system configuration
######################################################################################
SYS_OBJECTS = 
SYS_INC_PATHS = -I. -I$(GCC_INC) 
SYS_LIB_PATHS = -L$(MCU_LIB_PATH)
ifeq (OPTIMIZE_FOR, SIZE)
SYS_LIBRARIES = -lstdc++_s -lsupc++_s -lm -lc_s -lg_s -lnosys
SYS_LD_FLAGS  = --specs=nano.specs -u _printf_float -u _scanf_float
else 
SYS_LIBRARIES = -lstdc++ -lsupc++ -lm -lc -lg -lnosys
SYS_LD_FLAGS  = 
endif


############################################################################### 
# Command line building
###############################################################################
ifdef DEBUG_LEVEL
CC_DEBUG_FLAGS = -g$(DEBUG_LEVEL)
CC_SYMBOLS = -DDEBUG $(PROJECT_SYMBOLS)
else
CC_DEBUG_FLAGS =
CC_SYMBOLS = -DNODEBUG $(PROJECT_SYMBOLS)
endif 

ifdef OPTIM_LEVEL
CC_OPTIM_FLAGS = -O$(OPTIM_LEVEL)
else 
CC_OPTIM_FLAGS = 
endif

INCLUDE_PATHS = $(PROJECT_INC_LIB) $(SYS_INC_PATHS) $(PROJECT_INC_PATHS)
LIBRARY_PATHS = $(PROJECT_LIB_LIB) $(SYS_LIB_PATHS)
CC_FLAGS = $(MCU_CC_FLAGS) -c $(CC_OPTIM_FLAGS) $(CC_DEBUG_FLAGS) -fno-common -fmessage-length=0 -Wall -fno-exceptions -ffunction-sections -fdata-sections
LD_FLAGS = $(MCU_CC_FLAGS) -Wl,--gc-sections $(SYS_LD_FLAGS) -Wl,-Map=$(PROJECT).map 
LD_SYS_LIBS = $(SYS_LIBRARIES)

BULD_TARGET = $(PROJECT)


############################################################################### 
# Makefile execution
###############################################################################

libpixy_m0: $(LIBPIXY_M0_OBJS)
	arm-none-eabi-ar ruv $(LIBPIXY_M0_TARGET) $(LIBPIXY_M0_OBJS)
	
libpixy_m4: $(LIBPIXY_M4_OBJS)
	arm-none-eabi-ar ruv $(LIBPIXY_M4_TARGET) $(LIBPIXY_M4_OBJS) 

exec_m0: $(EXEC_M0_OBJS)

video_m4: $(VIDEO_M4_OBJS)
	
all: libpixy_m0 libpixy_m4

clean:
	rm -f $(LIBPIXY_M0_OBJS) $(LIBPIXY_M4_OBJS) $(EXEC_M0_OBJS) $(VIDEO_M4_OBJS) 
	rm -f $(LIBPIXY_M0_TARGET) $(LIBPIXY_M4_TARGET) $(EXEC_M0_TARGET) $(VIDEO_M4_TARGET)

.s.o:
	$(AS) $(MCU_CC_FLAGS) -o $@ $<

.c.o:
	$(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99   $(INCLUDE_PATHS) -o $@ $<

.cpp.o:
	$(CPP) $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu++98 $(INCLUDE_PATHS) -o $@ $<

%: %.o
    $(CC)  $(CC_FLAGS) $(CC_SYMBOLS) -std=gnu99   $(INCLUDE_PATHS) -o $@ $<

video_m4.elf: video_m4 libpixy_m4 libpixy_m0
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(PROJECT_LIBRARIES) $(SYS_LIBRARIES) $(PROJECT_LIBRARIES) $(SYS_LIBRARIES)
	
$(BULD_TARGET).elf: $(PROJECT_OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(PROJECT_LIBRARIES) $(SYS_LIBRARIES) $(PROJECT_LIBRARIES) $(SYS_LIBRARIES)

$(BULD_TARGET).bin: $(BULD_TARGET).elf
	$(OBJCOPY) -O binary $< $@

