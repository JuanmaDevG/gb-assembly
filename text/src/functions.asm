DEF rLY EQU $ff44
DEF SCREEN_BUF_1 EQU $9800

DEF rLY_VSYNC_INIT      EQU 144
DEF rLY_VSYNC_END_SAFE  EQU 153

; NOTE: this algorithms are slow because there are a lot of instructions and checks between each copied byte
;       but it's made just for fun, so I don't care.


SECTION "Functions", ROM0

  ; PARAM: bc = byte count, hl = src mem block, de = dst vram addr
  load_vram::
    .sync_vblank:
      ld a, [$ff44]
      cp 144
      jr c, .sync_vblank ; VBLANK has not started
      cp 153
      jr z, .sync_vblank ; VBLANK is about to end
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, c
    cp 0
    jr nz, .sync_vblank
    ld a, b
    cp 0
    jr nz, .sync_vblank
    ret


  ; PARAM: hl = src txt loc, de = vram writepoint
  draw_text::
    .sync:
      ld a, [rLY]
      cp 144
      jr c, .sync
    .write_char:
      ld a, [rLY]
      cp 152
      jr nc, .sync
      ld a, [hl+]
      cp 0
      jr z, .end
      ld [de], a
      inc de
      jr .write_char
    .end:
      ret
