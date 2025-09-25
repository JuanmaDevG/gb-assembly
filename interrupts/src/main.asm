;;----------LICENSE NOTICE-------------------------------------------------------------------------------------------------------;;
;;  This file is part of GBTelera: A Gameboy Development Framework                                                               ;;
;;  Copyright (C) 2024 ronaldo / Cheesetea / ByteRealms (@FranGallegoBR)                                                         ;;
;;                                                                                                                               ;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ;;
;; files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,    ;;
;; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the         ;;
;; Softwareis furnished to do so, subject to the following conditions:                                                           ;;
;;                                                                                                                               ;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.;;
;;                                                                                                                               ;;
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ;;
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ;;
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ;;
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ;;
;;-------------------------------------------------------------------------------------------------------------------------------;;

; TODO: look reset vector. Very interesting for small one-byte calls

;IME : CPU flag only accesible by "di", "ei" and "reti"
DEF rIE EQU $ffff ; Interrupt enable: what interrupts are we interested in
DEF rIF EQU $ff0f ; Interrupt flag: modified by the system by interrupts
DEF rLY EQU $ff44

; IE INTERRUPT BITS:
; 0 -> VBlank

include "font.inc"
include "macros.inc"
include "assets.inc"


; PARAM: hl, de, bc
MACRO HLDEBC
  ld hl, \1
  ld de, \2
  ld bc, \3
ENDM


SECTION "Interrupt handlers", ROM0[$40]
; vblank
reti
ds 7, 0


SECTION "Functions", ROM0
  ; NOPARAM, use: a
  interrupt_mode_load:
    ld a, %00000001
    ld [$ffff], a     ; Interrupt enable:
    ret

  ; NOPARAM
  interrupt_mode_game:
    ; TODO: learn all about interrupts

  ; PARAM: bc = bytecount, hl = src block addr, de = dst block addr
  load_vram_block:
    ei
    .next_block:
      ld a, b
      cp 0
      jr nz, .load_big_block
      ld a, c
      cp 16
      jr nc, .load_big_block
    .load_small_block:
      halt
      ld a, [hl+]
      ld [de], a
      inc de
      dec c
      jr nz, .load_small_block
      di
      ret
    .load_big_block:
      halt
      LD16_HL2DE
      ld a, c
      sub 16
      jr nc, .skip_carry
      dec b
      .skip_carry:
        jr .next_block


  ; NOPARAM, USE ALL
  clear_screen:
    ei
    ld hl, $9800
    ld bc, $1214 ; 18 columns, 20 rows
    ld de, 12
    .wait:
      halt
    .clear_tile:
      xor a
      ld [hl+], a
      dec c
      jr nz, .no_linejump
      add hl, de
      dec b
      jr z, .end
      .no_linejump:
      ld a, [$ff44]
      cp 153
      jr z, .wait
    .end
      di
      ret
      ; TODO: if not enough time to draw, go wait


SECTION "Game data", WRAM0
ds 2

SECTION "Text data", ROM0
text: db "How are you Rob? Move around but please, add the characters left to your font, it is still incomplete", 0


SECTION "Entry point", ROM0[$150]
main::
  di
  call interrupt_mode_load
  HLDEBC font, VRAM_FONT, FONT_SIZE
  call load_vram_block
  HLDEBC assets, VRAM_ASSETS, ASSETS_SIZE
  call load_vram_block
  call clear_screen

  call interrupt_mode_game


  halt
