//This file contains functions from frame_m0.c which were written entirely in assembly.
//gcc does not support the __asm function decorator.

  .syntax unified
  .cpu cortex-m0
  .fpu softvfp
  .thumb

//////////////////////////////////////
// syncM0
//////////////////////////////////////  
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global syncM0      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   syncM0, %function   @@ - symbol type (not req)
    
syncM0:
		PUSH	{r4}

.start:
	// This sequence can be extended to reduce probability of false phase detection.
	// This routine acts as a "sieve", only letting a specific phase through.  
	// In practice, 2 different phases separated by 1 clock are permitted through
	// which is acceptable-- 5ns in a 30ns period.  
	// If the pixel clock is shifted 1/2 a cpu clock period (or less), with respect to the CPU clock, 2 phases will match.  
	// If the pixel clock is perfectly in line with the cpu clock, 1 phase will match.  
	// Worst case will aways be 2 possible phases. 
	// It takes between 50 and 200 cpu clock cycles to complete.  	
	LDR 	r2, [r0] // high
	NOP
	LDR 	r3, [r0] // low
	BICS	r2, r3
	LDR 	r3, [r0] // high
	ANDS	r3, r2
	LDR 	r2, [r0] // low
	LDR 	r4, [r0] // high
	BICS 	r4, r2
	LDR 	r2, [r0] // low
	BICS	r4, r2		
	LDR 	r2, [r0] // high
	ANDS	r4, r2		
	LDR 	r2, [r0] // low
	
	BICS	r4, r2
	ANDS	r4, r3

	TST		r4, r1
	BEQ		.start

	// in-phase begins here
	POP   	{r4}
	BX 		lr

	
//////////////////////////////////////
// syncM1
//////////////////////////////////////  	
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global syncM1      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   syncM1, %function   @@ - symbol type (not req)
    
syncM1:
	PUSH	{r4}

.startSyncM1:
	LDR 	r2, [r0] // high
	NOP
	NOP
	NOP
	NOP
	LDR 	r3, [r0] // low
	BICS	r2, r3
	NOP
	NOP
	NOP
	LDR 	r3, [r0] // high
	ANDS	r3, r2
	NOP
	NOP
	NOP
	LDR 	r2, [r0] // low
	LDR 	r4, [r0] // high
	BICS 	r4, r2
	NOP
	NOP
	NOP
	LDR 	r2, [r0] // low
	BICS	r4, r2		
	NOP
	NOP
	NOP
	LDR 	r2, [r0] // high
	ANDS	r4, r2		
	NOP
	NOP
	NOP
	LDR 	r2, [r0] // low
	
	BICS	r4, r2
	ANDS	r4, r3

	TST		r4, r1
	NOP		// an extra NOP makes us converge faster, worst case 400 cycles.  
	NOP
	NOP
	BEQ		.startSyncM1

	// in-phase begins here


	POP   	{r4}
	BX 		lr
	

//////////////////////////////////////
// lineM0
//////////////////////////////////////  	
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global lineM0      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   lineM0, %function   @@ - symbol type (not req)
    
lineM0:
		//PRESERVE8
		.eabi_attribute Tag_ABI_align8_preserved,1
		//IMPORT 	callSyncM0
		.global callSyncM0

		PUSH	{r4-r5, lr}

		// add width to memory pointer so we can compare
		ADDS	r3, r1
		// generate hsync bit
	  	MOVS	r4, #0x1
		LSLS	r4, #11

		PUSH	{r0-r3} // save args
		BL.W	callSyncM0 // get pixel sync
		POP		{r0-r3}	// restore args
	   
	   	// pixel sync starts here

		// these nops are set us up for sampling hsync reliably
		NOP
		NOP

		// wait for hsync to go high
.dest21:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BEQ		.dest21		// 3

		// skip pixels
.dest22:
		SUBS	r2, #0x1	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		BGE		.dest22		// 3

		// variable delay --- get correct phase for sampling

		LDRB 	r2, [r0] 	  // 0
		STRB 	r2, [r1, #0x00]
		NOP
		NOP

		LDRB 	r2, [r0] 	  // 0
		STRB 	r2, [r1, #0x01]
		NOP
		NOP

.loop11:
		LDRB 	r2, [r0] 	  // 0
		STRB 	r2, [r1, #0x2]

		ADDS	r1, #0x03
		NOP

		LDRB 	r2, [r0]	  // 0
		STRB 	r2, [r1, #0x0]

		CMP		r1, r3

		LDRB 	r2, [r0]	  // -1
		STRB 	r2, [r1, #0x1] 

		BLT		.loop11

		// wait for hsync to go low (end of line)
.dest13:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BNE		.dest13		// 3

		POP		{r4-r5, pc}
		

//////////////////////////////////////
// lineM1R1
//////////////////////////////////////  	
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global lineM1R1      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   lineM1R1, %function   @@ - symbol type (not req)
    
lineM1R1:
		//PRESERVE8
		.eabi_attribute Tag_ABI_align8_preserved,1
		//IMPORT 	callSyncM1
		.global callSyncM1

		PUSH	{r4-r5, lr}

		// add width to memory pointer so we can compare
		ADDS	r3, r1
		// generate hsync bit
	  	MOVS	r4, #0x1
		LSLS	r4, #11

		PUSH	{r0-r3} // save args
		BL.W	callSyncM1 // get pixel sync
		POP		{r0-r3}	// restore args
	   
	   	// pixel sync starts here

		// wait for hsync to go high
.dest1:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BEQ		.dest1		// 3

		// skip pixels
.dest2:
		SUBS	r2, #0x1	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		BGE		.dest2		// 3

		// variable delay --- get correct phase for sampling
		NOP
		NOP

.loop1:
		LDRB 	r2, [r0] 	  
		STRB 	r2, [r1]
		NOP
		NOP
		NOP
		ADDS	r1, #0x01
		CMP		r1, r3
		BLT		.loop1

		// wait for hsync to go low (end of line)
.dest3:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BNE		.dest3		// 3

		POP		{r4-r5, pc}


//////////////////////////////////////
// lineM1R2
//////////////////////////////////////  	
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global lineM1R2      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   lineM1R2, %function   @@ - symbol type (not req)
    
lineM1R2:
		//PRESERVE8
		.eabi_attribute Tag_ABI_align8_preserved,1
		//IMPORT 	callSyncM1
		.global callSyncM1

		PUSH	{r4-r6, lr}

		// add width to memory pointer so we can compare
		LSLS	r3, #1
		ADDS	r3, r1
		// generate hsync bit
	  	MOVS	r4, #0x1
		LSLS	r4, #11

		PUSH	{r0-r3} // save args
		BL.W	callSyncM1 // get pixel sync
		POP		{r0-r3}	// restore args
	   
	   	// pixel sync starts here

.dest7:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BEQ		.dest7		// 3

		// skip pixels
.dest8:
		SUBS	r2, #0x1	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		BGE		.dest8		// 3

		// variable delay --- get correct phase for sampling
		NOP
		NOP

.loop3:
		LDRB 	r2, [r0]
		NOP
		NOP 	  
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP

		LDRB 	r5, [r0] 	  
		NOP
		NOP 	  
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP

		LDRB 	r6, [r0] 	  
		ADDS    r6, r2
		STRH 	r6, [r1, #0x00]
		NOP
		NOP 	  
		NOP
		NOP
		NOP
		NOP
		NOP

		LDRB 	r6, [r0] 	  
		ADDS    r6, r5
		STRH 	r6, [r1, #0x02]
		NOP
		NOP 	  
		ADDS	r1, #0x04
		CMP		r1, r3
		BLT		.loop3

		// wait for hsync to go low (end of line)
.dest9:
		LDR 	r5, [r0] 	// 2
		TST		r5, r4		// 1
		BNE		.dest9		// 3

		POP		{r4-r6, pc}
		
		
//////////////////////////////////////
// lineM1R2Merge
//////////////////////////////////////  	
@@ <function block>
	.text
    .align  2               @@ - 2^n alignment (n=2)
    .global lineM1R2Merge      @@ - Symbol name for function
    .code   16              @@ - 16bit THUMB code (BOTH are required!)
    .thumb_func             @@ /
    .type   lineM1R2Merge, %function   @@ - symbol type (not req)
    
lineM1R2Merge:
		//PRESERVE8
		.eabi_attribute Tag_ABI_align8_preserved,1
		//IMPORT 	callSyncM1
		.global callSyncM1

		PUSH	{r4-r7, lr}
		LDR		r4, [sp, #0x14]

		// add width to memory pointer so we can compare
		ADDS	r4, r2
		// generate hsync bit
	  	MOVS	r5, #0x1
		LSLS	r5, #11

		PUSH	{r0-r3} // save args
		BL.W	callSyncM1 // get pixel sync
		POP		{r0-r3}	// restore args
	   
	   	// pixel sync starts here

		// wait for hsync to go high
.dest4:	LDR 	r6, [r0] 	// 2
		TST		r6, r5		// 1
		BEQ		.dest4		// 3

		// skip pixels
.dest5:	SUBS	r3, #0x1	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		NOP				 	// 1
		BGE		.dest5		// 3

		// variable delay --- get correct phase for sampling
		NOP
		NOP

.loop4:
		LDRB 	r3, [r0] // 0
		LDRH	r6, [r1, #0x00]
		ADDS    r6, r3
		NOP
		NOP 	  
		NOP
		NOP
		NOP
		NOP
		NOP

		LDRB 	r3, [r0] // 0
		LDRH	r7, [r1, #0x02]
		ADDS    r7, r3
		NOP
		NOP 	  
		NOP
		NOP
		NOP
		NOP
		NOP

		LDRB 	r3, [r0] 	  // 0
		ADDS    r6, r3
		LSRS    r6, #2
		STRB 	r6, [r2, #0x00]
		NOP 	
		NOP
		NOP  
		NOP 	
		NOP
		NOP  

		LDRB 	r3, [r0] 	 // 0 
		ADDS    r7, r3
		LSRS    r7, #2
		STRB 	r7, [r2, #0x01]
		ADDS    r1, #0x04
		ADDS	r2, #0x02
		CMP		r2, r4
		BLT		.loop4

		// wait for hsync to go low (end of line)
.dest6:
		LDR 	r6, [r0] 	// 2
		TST		r6, r5		// 1
		BNE		.dest6		// 3

		POP		{r4-r7, pc}
