.include "zp.inc"
.include "controller.inc"

.segment "CODE"

;the default controller clear routine. Note it spills into
;controller_fill_buffer_with_accumulator. Call
;controller_fill_buffer_with_accumulator to fill the
;controller buffer with a different value.
.proc controller_clear

  lda #%00000000

.endproc

.proc controller_fill_buffer_with_accumulator

  sta buffer_controller+buttons::_a
  sta buffer_controller+buttons::_b
  sta buffer_controller+buttons::_left
  sta buffer_controller+buttons::_right
  sta buffer_controller+buttons::_up
  sta buffer_controller+buttons::_down
  sta buffer_controller+buttons::_select
  sta buffer_controller+buttons::_start

  rts

.endproc

;reads only the start button into its buffer byte
.proc controller_read_start

  lda #$01  ; strobe joypad
  sta $4016
  lda #$00
  sta $4016

  lda $4016  ; A
  lda $4016  ; B
  lda $4016          ; Select
  lda $4016          ; Start
  ror
  rol buffer_controller+3

  rts

.endproc

.proc controller_read_ignore_start

  lda #$01
  sta $4016
  lda #$00
  sta $4016

  ;a
  lda $4016
  ror
  rol buffer_controller

  ;b
  lda $4016
  ror
  rol buffer_controller+1

  ;select
  lda $4016
  ror
  rol buffer_controller+2

  ;start
  lda $4016
  lda #0
  sta buffer_controller+3

  ;up
  lda $4016
  ror
  rol buffer_controller+4

  ;down
  lda $4016
  ror
  rol buffer_controller+5

  ;left
  lda $4016
  ror
  rol buffer_controller+6

  ;right
  lda $4016
  ror
  rol buffer_controller+7

  rts

.endproc

;deserializes the controller into a buffer
;output: buffer_controller
.proc controller_read

  lda #$01
  sta $4016
  lda #$00
  sta $4016

  ;a
  lda $4016
  ror
  rol buffer_controller

  ;b
  lda $4016
  ror
  rol buffer_controller+1

  ;select
  lda $4016
  ror
  rol buffer_controller+2

  ;start
  lda $4016
  ror
  rol buffer_controller+3

  ;up
  lda $4016
  ror
  rol buffer_controller+4

  ;down
  lda $4016
  ror
  rol buffer_controller+5

  ;left
  lda $4016
  ror
  rol buffer_controller+6

  ;right
  lda $4016
  ror
  rol buffer_controller+7

  rts
.endproc

;This is a blank controller routine intended to allow special entities
;such as the innkeep to take control of the hero and make her walk towards
;a bed for example.
.proc controller_nop

  rts

.endproc

;this routine indirectly calls the currently installed controller routine
.proc controller_indirect

  jmp (controller_routine)

.endproc
