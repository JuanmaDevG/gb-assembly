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

; _IME : CPU flag only accesible by "di", "ei" and "reti"
DEF _IE EQU $ffff ; Interrupt enable: what interrupts are we interested in
DEF _IF EQU $ff0f ; Interrupt flag: modified by the system by interrupts

; IE INTERRUPT BITS:
; 0 -> VBlank

SECTION "Interrupts", ROM0[$40]
jp vblank_handler
ds 5, 0


SECTION "Variables", WRAM0
vblank_flag: ds 1


; NOTE: Handlers can be called whenever by interruptions to they must make a context switch
SECTION "Handlers", ROM0
vblank_handler:
  push hl
  push af
  ld a, 1
  ld [vblank_flag], a
  ;TODO


SECTION "Procedures", ROM0
  ; NOPARAM
  interrupt_setup::
    ld a, %00000001
    ld a, [$ffff]
    ret


SECTION "Entry point", ROM0[$150]
main::
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
