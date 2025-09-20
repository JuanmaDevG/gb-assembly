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

; WARNING:
; Constant registers: b, hl (these are not replaceable for this program)

; NOTE:
; The enable_draw_mode is not efficient because it waits uselessly till the PPU is in VBLANK when it could be synchroonized to draw on HBlank mode when possible

include "hardware.inc"

SECTION "Triangles", ROM0
total_tiles: db 24
triangles:
  dw $9800, $9801, $9802, $9820, $9821, $9840
  dw $9811, $9812, $9813, $9832, $9833, $9853
  dw $99e0, $9a00, $9a01, $9a20, $9a21, $9a22
  dw $99f3, $9a12, $9a13, $9a31, $9a32, $9a33

; TODO: remove
; Allows to draw anywhere safely but not guaranteed to render on the current frame (because of LY register)
; FUNC: (n_param, (x_tile8, y_tile8, sprite_num8), ...)
async_safe_draw_noguarantee:
  ld a, [rSTAT]
  and STATF_MODE10 ;TODO: look for andc to not to store value on A
  jr z, async_safe_draw_noguarantee
  ; TODO: read the stack
  ; Pop all the stack (maybe just one op)
  ret

SECTION "Entry point", ROM0[$150]
main::
  di
  ld hl, total_tiles    ; Data pointer
  ld b, [hl]            ; Countdown iterator
  inc hl
  draw_tile:
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    .enable_draw_mode:
      ld a, [rLY]
      cp 144
    jr nz, .enable_draw_mode
    ld a, $19
    ld [de], a
    dec b
  jr nz, draw_tile
  halt


; ALTERNATIVA A LAS LINEAS 44 - 45 (peor, instrucciones extra):
;   push hl
;   ld h, e
;   ld l, d
;   ld [hl], $19
