.ifndef CONTROLLER_INC
CONTROLLER_INC = 1

.global controller_clear
.global controller_fill_buffer_with_accumulator
.global controller_read_start
.global controller_read_ignore_start
.global controller_read
.global controller_nop
.global controller_indirect

.struct buttons
  _a       .byte
  _b       .byte
  _select  .byte
  _start   .byte
  _up      .byte
  _down    .byte
  _left    .byte
  _right   .byte
.endstruct

.endif
