*---------------------------------------------------------------------------------------
* Program    :Absolute Addressing testing file
* Description:Assemble various absolute addressing mode
*----------------------------------------------------------------------------------------
	OPT 	CRE
	ORG	$400
START 	MOVEA.W #$9100, A0 *A0<-- FFFF9100
        MOVEA.W #$1000, A1
        LEA     $9100, A0  *A0<-- 00009100
 	MOVEA.W #$4213, A0 *A0<-- 00004213
	MOVEA.L #$9100, A0 *A0<--- 00009100
	MOVEA.L #$00004213, A0 *A0<-- 00004213
	MOVE.L #$00008000, D0
	MOVEA.W D0, A0
	
	
	MOVE.B  $00004340, D3 *Word addressing
	MOVE.B  $0000A340, D3 *Long word addressing
	MOVE.B  $A340, D3     *Long Word addressing
	MOVE.B  $FFFFA340, D3 *word addressing
	MOVE.B  $FFFF4340, D3 *long word addressing
	
	LEA  $00004340, A1 *Word addressing
	LEA  $0000A340, A1 *Long word addressing
	LEA  $A340, A1     *Long Word addressing
	MOVEA.W #$A340, A1 *Word Addressing
	LEA  $FFFFA340, A1 *word addressing
	LEA  $FFFF4340, A1 *long word addressing

	
	
	MOVE.L  #$AAAAAAAA, D0
	MOVE.B  #$BB, D0
	MOVE.L  #-3, D0
	ASL.L   #8, D0
	MOVE.L  #-3, D0
	ASL.W   #8, D0

	MOVE.L  #$F, D0
	ASL.B   #5, D0

        MOVEQ   #$11, D0
	MOVE.L  #$3456ABCF, D0
	ASR.W 	#3, D0
	MOVE.L  #$3456ABCF, D0
	ASL.W 	#3, D0

	
	
DONE	STOP	#$2700
	END	$400






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
