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

; _IME : CPU flag only accesible by "di", "ei" and "reti"
DEF _IE EQU $ffff ; Interrupt enable: what interrupts are we interested in
DEF _IF EQU $ff0f ; Interrupt flag: modified by the system by interrupts

; IE INTERRUPT BITS:
; 0 -> VBlank

include "font.inc"
include "macros.inc"


SECTION "VBlank handler", ROM0[$40]
reti
ds 7, 0


SECTION "Functions", ROM0
  ; NOPARAM, use: a
  interrupt_setup:
    ld a, %00000001
    ld [$ffff], a     ; Interrupt enable:
    ret

  ; TODO: make more vram writes with HBlank
  ; PARAM: bc = bytecount, hl = src block addr, de = dst block addr
  load_vram_block:
    ei
    .wait:
      halt
    .safe_tile_load:
      LD16B_HL2DE
      ld a, c
      sub 16
      ld c, a
      jr nc, .ignore_carry
      dec b
      .ignore_carry:
      ld a, [$ff44]
      cp 152
      jr nc, .wait ; VBlank is about to end
      jr .safe_tile_load
    di
    ret


SECTION "Entry point", ROM0[$150]
main::
  di
  call interrupt_setup
  ld hl, font
  ld de, $8010
  ld bc, FONT_SIZE
  call load_vram_block

  halt
