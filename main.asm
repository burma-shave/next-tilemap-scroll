;===========================================================================
; main.asm
;===========================================================================

    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

NEX:    equ 1   ;  1=Create nex file, 0=create sna file

    IF NEX == 0
        ;DEVICE ZXSPECTRUM128
        DEVICE ZXSPECTRUM48
        ;DEVICE NOSLOT64K
    ELSE
        DEVICE ZXSPECTRUMNEXT
    ENDIF


;===========================================================================
; Tileset
;===========================================================================
    ORG 0x4000
    defs 0x6000 - $    ; move after screen area
    ORG $6000
tilemap:
    incbin "tiles.map"

    ORG $6600
tiles:
    incbin "tiles.spr"

palette:
    incbin "tiles.pal"


TILES_BASE_BANK5_OFFSET     equ (tiles- $4000) >> 8
TILEMAP_BASE_BANK5_OFFSET   equ (tilemap - $4000) >> 8

    ORG $8000

    ;include "utilities.asm"
    include "constants.i.asm"

;===========================================================================
; main routine - the code execution starts here.
; Sets up the new interrupt routine, the memory
; banks and jumps to the start loop.
;===========================================================================

main:
    ; Disable interrupts
    ; di
    NEXTREG TILEMAP_CONTROL_NR_6B, %10100001    ; 40x32, 16-bit entries
    NEXTREG TILEMAP_DEFAULT_ATTR_NR_6C, %00000000       ; default tile attributes
    NEXTREG TILEMAP_BASE_ADR_NR_6E, $20
    NEXTREG TILEMAP_GFX_ADR_NR_6F, $26 ; MSB of offset into

;    	NEXTREG PALETTE_CONTROL_NR_43, %00110000		; Auto increment, select first tilemap palette
;     NEXTREG PALETTE_INDEX_NR_40, 0
; 	LD HL, palette			; Address of palette data in memory
; 	LD B, 16			; Copy 16 colours
; .copyPalette
; 	LD A, (HL)		; Load RRRGGGBB into A
; 	INC HL			; Increment to next entry
; 	NEXTREG PALETTE_VALUE_NR_41, A		; Send entry to Next HW
; 	DJNZ .copyPalette	; Repeat until B=0

main_loop:
    jr main_loop

;===========================================================================
; Stack.
;===========================================================================



    IF NEX == 0
        SAVESNA "z80-sample-program.sna", main
    ELSE
        SAVENEX OPEN "z80-sample-program.nex", main, $ff40
        SAVENEX CORE 3, 1, 5
        SAVENEX CFG 7   ; Border color
        SAVENEX AUTO
        SAVENEX CLOSE
    ENDIF
