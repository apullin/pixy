//
// begin license header
//
// This file is part of Pixy CMUcam5 or "Pixy" for short
//
// All Pixy source code is provided under the terms of the
// GNU General Public License v2 (http://www.gnu.org/licenses/gpl-2.0.html).
// Those wishing to use Pixy source code, software and/or
// technologies under different licensing terms should contact us at
// cmucam@cs.cmu.edu. Such licensing terms are available for
// all portions of the Pixy codebase presented here.
//
// end license header
//

#include "chirp.h"
#include "frame_m0.h"

#define CAM_PCLK_MASK   0x2000

#define ALIGN(v, n)  ((uint32_t)v&((n)-1) ? ((uint32_t)v&~((n)-1))+(n) : (uint32_t)v)

void vsync()
{
	int v = 0, h = 0;

	while(1)
	{
		h = 0;
		while(CAM_VSYNC()!=0);
		while(1) // vsync low
		{
			while(CAM_HSYNC()==0)
			{
				if (CAM_VSYNC()!=0)
					goto end;
			}
			while(CAM_HSYNC()!=0); //grab data
			h++;
		}
end:
		v++;
		//if (v%25==0)
			//printf("%d %d\n", v, h);
	}
}

extern void syncM0(uint32_t *gpioIn, uint32_t clkMask);

extern void syncM1(uint32_t *gpioIn, uint32_t clkMask);

extern void lineM0(uint32_t *gpio, uint8_t *memory, uint32_t xoffset, uint32_t xwidth);

extern void lineM1R1(uint32_t *gpio, uint8_t *memory, uint32_t xoffset, uint32_t xwidth);

extern void lineM1R1(uint32_t *gpio, uint8_t *memory, uint32_t xoffset, uint32_t xwidth);

extern void lineM1R2(uint32_t *gpio, uint16_t *memory, uint32_t xoffset, uint32_t xwidth);

extern void lineM1R2Merge(uint32_t *gpio, uint16_t *lineMemory, uint8_t *memory, uint32_t xoffset, uint32_t xwidth);

void skipLine()
{
	while(!CAM_HSYNC());
	while(CAM_HSYNC());
}

void skipLines(uint32_t lines)
{
	uint32_t line;

	// wait for remainder of frame to pass
	while(!CAM_VSYNC()); 
	// vsync asserted
	while(CAM_VSYNC());
	// skip lines
	for (line=0; line<lines; line++)
		skipLine();
}

void grabM0R0(uint32_t xoffset, uint32_t yoffset, uint32_t xwidth, uint32_t ywidth, uint8_t *memory)
{
	uint32_t line;

	xoffset >>= 1;
	yoffset &= ~1;

	skipLines(yoffset);
	for (line=0; line<ywidth; line++, memory+=xwidth)
		lineM0((uint32_t *)&CAM_PORT, memory, xoffset, xwidth); // wait, grab, wait
}

void grabM1R1(uint32_t xoffset, uint32_t yoffset, uint32_t xwidth, uint32_t ywidth, uint8_t *memory)
{
	uint32_t line;

	xoffset >>= 1;
	yoffset &= ~1;

	skipLines(yoffset);
	for (line=0; line<ywidth; line++, memory+=xwidth)
		lineM1R1((uint32_t *)&CAM_PORT, memory, xoffset, xwidth); // wait, grab, wait
}

void grabM1R2(uint32_t xoffset, uint32_t yoffset, uint32_t xwidth, uint32_t ywidth, uint8_t *memory)
{
	uint32_t line;
	uint16_t *lineStore = (uint16_t *)(memory + xwidth*ywidth + 16);
	lineStore = (uint16_t *)ALIGN(lineStore, 2);

	// clear line storage for 1 line
	for (line=0; line<xwidth; line++)
		lineStore[line] = 0;

	skipLines(yoffset*2);
	// grab 1 line to put us out of phase with the camera's internal vertical downsample (800 to 400 lines)
	// ie, we are going to downsample again from 400 to 200.  Because the bayer lines alternate
	// there tends to be little difference between line pairs bg and gr lines after downsampling.
	// Same logic applies horizontally as well, but we always skip a pixel pair in the line routine.  
	lineM1R2Merge((uint32_t *)&CAM_PORT, lineStore, memory, xoffset, xwidth); // wait, grab, wait
	memory += xwidth;
	for (line=0; line<ywidth; line+=2, memory+=xwidth*2)
	{
		// CAM_HSYNC is negated here
		lineM1R2((uint32_t *)&CAM_PORT, lineStore, xoffset, xwidth); // wait, grab, wait
		lineM1R2((uint32_t *)&CAM_PORT, lineStore+xwidth, xoffset, xwidth); // wait, grab, wait
		lineM1R2Merge((uint32_t *)&CAM_PORT, lineStore, memory, xoffset, xwidth); // wait, grab, wait
		lineM1R2Merge((uint32_t *)&CAM_PORT, lineStore+xwidth, memory+xwidth, xoffset, xwidth); // wait, grab, wait
	}					
}

void callSyncM0(void)
{
	syncM0((uint32_t *)&CAM_PORT, CAM_PCLK_MASK);
}

void callSyncM1(void)
{
	syncM1((uint32_t *)&CAM_PORT, CAM_PCLK_MASK);
}

int32_t getFrame(uint8_t *type, uint32_t *memory, uint16_t *xoffset, uint16_t *yoffset, uint16_t *xwidth, uint16_t *ywidth)
{
	//printf("M0: grab %d %d %d %d %d\n", *type, *xoffset, *yoffset, *xwidth, *ywidth);

	if (*type==CAM_GRAB_M0R0)
		grabM0R0(*xoffset, *yoffset, *xwidth, *ywidth, (uint8_t *)*memory);
	else if (*type==CAM_GRAB_M1R1)
		grabM1R1(*xoffset, *yoffset, *xwidth, *ywidth, (uint8_t *)*memory);
	else if (*type==CAM_GRAB_M1R2)
		grabM1R2(*xoffset, *yoffset, *xwidth, *ywidth, (uint8_t *)*memory);
	else
		return -1;

	return 0;
}




int frame_init(void)
{
	chirpSetProc("getFrame", (ProcPtr)getFrame);
		
	return 0;	
}