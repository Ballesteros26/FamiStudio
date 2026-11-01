;file: soundengine_demo.asm
;author: Derek Andrews <derek.george.andrews@gmail.com>
;description: This program is a demo of my sound and music engine.
;It is just a bunch of boilerplate to initialize the NES and set
;up IRQ vectors and so forth. To understand how the sound engine
;is used, check out the usage.asm module.

.feature force_range
.include "usage.inc"
.include "controller.inc"
.include "ppu.inc"
.include "zp.inc"

.segment "HEADER"
.byte "NES",$1a   ;iNES header
.byte $01         ;# of PRG-ROM blocks. These are 16kb each. $4000 hex.
.byte $00         ;# of CHR-ROM blocks. These are 8kb each. $2000 hex.
.byte $01         ;Vertical mirroring. SRAM disabled. No trainer. Four-screen mirroring disabled. Mapper #0 (NROM)
.byte $00         ;Rest of NROM bits (all 0)

.segment "CODE"

palette:
  .byte $12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12
  .byte $12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12

reset:
  ;set interrupt disable flag
  sei

  ;clear binary encoded decimal flag
  cld

  ;disable APU frame IRQ
  lda #$40
  sta $4017

  ;initialize stack
  ldx #$FF
  txs

  ;turn off all graphics, and clear PPU registers
  lda #$00
  sta ppu_2000
  sta ppu_2001
  upload_ppu_2000
  upload_ppu_2001

  ;disable DMC IRQs
  lda #$00
  sta $4010

  ;Clear the vblank flag, so we know that we are waiting for the
  ;start of a vertical blank and not powering on with the
  ;vblank flag spuriously set
  bit $2002

  ;wait for PPU to be ready
  wait_vblank
  wait_vblank

  ;install default controller read routine
  lda #<controller_read
  sta controller_routine
  lda #>controller_read
  sta controller_routine+1

  ;initialize ppu registers with settings we're never going to change
  set_ppu_2000_bit PPU0_EXECUTE_NMI
  set_ppu_2001_bit PPU1_SPRITE_CLIPPING
  set_ppu_2001_bit PPU1_BACKGROUND_CLIPPING
  clear_ppu_2000_bit PPU0_BACKGROUND_PATTERN_TABLE_ADDRESS
  set_ppu_2000_bit PPU0_SPRITE_PATTERN_TABLE_ADDRESS
  upload_ppu_2000
  upload_ppu_2001

  ;load palette
  lda #<palette
  sta palette_address
  lda #>palette
  sta palette_address+1
  jsr ppu_load_palette

  jsr here_is_how_you_initialize_everything

main_loop:
  clear_vblank_done
  wait_vblank_done

  jsr controller_read

  lda buffer_controller+buttons::_a
  and #%00000011
  cmp #%00000001
  bne :+

  jsr here_is_how_to_play_sound_effect_one

:

  lda buffer_controller+buttons::_b
  and #%00000011
  cmp #%00000001
  bne :+

  jsr here_is_how_to_play_sound_effect_two
:

  jmp main_loop

vblank:

  pha
  txa
  pha
  tya
  pha
  php

  lda #1
  sta vblank_done_flag

  ;Just use up vblank cycles to push monochrome bit
  ;CPU usage display of sound engine onto the screen
  ldx #$00
: dex
  bne :-
  ldx #$00
: dex
  bne :-

  jsr call_this_from_end_of_vblank

  plp
  pla
  tay
  pla
  tax
  pla

irq:
  rti

.segment "VECTORS"
  .word vblank
  .word reset
  .word irq
