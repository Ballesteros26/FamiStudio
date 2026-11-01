.linecont +
.include "soundengine.inc"

.segment "ZEROPAGE"

sound_disable_update: .res 1
sound_zp_start:
sound_local_byte_0: .res 1
sound_local_byte_1: .res 1
sound_local_byte_2: .res 1

sound_local_word_0: .res 2
sound_local_word_1: .res 2
sound_local_word_2: .res 2

sound_param_byte_0: .res 1
sound_param_byte_1: .res 1
sound_param_byte_2: .res 1

sound_param_word_0: .res 2
sound_param_word_1: .res 2
sound_param_word_2: .res 2

base_address_volume_envelopes: .res 2
base_address_pitch_envelopes:  .res 2
base_address_duty_envelopes:   .res 2

stream_byte: .res 1

apu_data_ready: .res 1
apu_square_1_old: .res 1
apu_square_2_old: .res 1

;original song address
song_address: .res 2
sound_zp_end:

.segment "BSS"

sound_ram_start:
song_base_address_volume_envelopes: .res 2
song_base_address_pitch_envelopes: .res 2
song_base_address_duty_envelopes: .res 2
sfx_base_address_volume_envelopes: .res 2
sfx_base_address_pitch_envelopes: .res 2
sfx_base_address_duty_envelopes: .res 2

;streams
stream_active:             .res MAX_STREAMS
stream_length:             .res MAX_STREAMS
stream_frame_counter:      .res MAX_STREAMS
stream_volume_index:       .res MAX_STREAMS
stream_volume_offset:      .res MAX_STREAMS
stream_pitch_index:        .res MAX_STREAMS
stream_pitch_offset:       .res MAX_STREAMS
stream_duty_index:         .res MAX_STREAMS
stream_duty_offset:        .res MAX_STREAMS

stream_channel:            .res MAX_STREAMS
stream_channel_register_1: .res MAX_STREAMS
stream_channel_register_2: .res MAX_STREAMS
stream_channel_register_3: .res MAX_STREAMS
stream_channel_register_4: .res MAX_STREAMS

stream_read_address_lo:    .res MAX_STREAMS
stream_read_address_hi:    .res MAX_STREAMS

stream_tempo_counter:      .res MAX_STREAMS
stream_tempo_carry:        .res MAX_STREAMS
stream_tempo:              .res MAX_STREAMS

;five total channels, 4 bytes per channel, so 40 bytes.
apu_register_sets: .res 40
sound_ram_end:

.segment "CODE"

.proc sound_initialize

  lda #1
  sta sound_disable_update

  ;clear sound engine zp and ram
  lda #0
  ldx #(sound_zp_end - sound_zp_start - 1)
: sta sound_zp_start,x
  dex
  bne :-
  sta sound_zp_start,x

  ldx #(sound_ram_end - sound_ram_start - 1)
: sta sound_ram_start,x
  dex
  bne :-
  sta sound_ram_start,x

  ;enable square 1, square 2, triangle and noise
  lda #%00001111
  sta $4015

  sta apu_data_ready
  jsr sound_initialize_apu_buffer

  ;make sure all streams are killed
  jsr sound_stop

  dec sound_disable_update

  rts

.endproc

;kill all active streams and halt sound
.proc sound_stop

  ;save x
  txa
  pha

  inc sound_disable_update

  ;kill all streams
  ldx #(MAX_STREAMS-1)
loop:

  lda #0
  sta stream_active,x

  dex
  bpl loop

  jsr sound_initialize_apu_buffer

  dec sound_disable_update

  ;restore x
  pla
  tax

  rts
.endproc

.proc sound_update

  ;save regs
  txa
  pha

  ;apu data not ready
  lda #0
  sta apu_data_ready

  ;first copy all music streams, or the first four streams
  lda song_base_address_volume_envelopes
  sta base_address_volume_envelopes
  lda song_base_address_volume_envelopes+1
  sta base_address_volume_envelopes+1
  lda song_base_address_pitch_envelopes
  sta base_address_pitch_envelopes
  lda song_base_address_pitch_envelopes+1
  sta base_address_pitch_envelopes+1
  lda song_base_address_duty_envelopes
  sta base_address_duty_envelopes
  lda song_base_address_duty_envelopes+1
  sta base_address_duty_envelopes+1

  ldx #0
song_stream_register_copy_loop:

  ;load whether this stream is active
  lda stream_active,x
  beq song_stream_not_active

  ;update the stream
  jsr stream_update

  ;load channel number
  lda stream_channel,x
  ;multiply by four to get location within apu_register_sets
  asl
  asl
  tay
  ;copy the registers over
  lda stream_channel_register_1,x
  sta apu_register_sets,y
  lda stream_channel_register_2,x
  sta apu_register_sets+1,y
  lda stream_channel_register_3,x
  sta apu_register_sets+2,y
  lda stream_channel_register_4,x
  sta apu_register_sets+3,y
song_stream_not_active:

  inx
  cpx #4
  bne song_stream_register_copy_loop
do_not_update_music:

  ;next, copy all sfx streams, or the last four streams
  lda sfx_base_address_volume_envelopes
  sta base_address_volume_envelopes
  lda sfx_base_address_volume_envelopes+1
  sta base_address_volume_envelopes+1
  lda sfx_base_address_pitch_envelopes
  sta base_address_pitch_envelopes
  lda sfx_base_address_pitch_envelopes+1
  sta base_address_pitch_envelopes+1
  lda sfx_base_address_duty_envelopes
  sta base_address_duty_envelopes
  lda sfx_base_address_duty_envelopes+1
  sta base_address_duty_envelopes+1

  ldx #4
sfx_stream_register_copy_loop:

  ;load whether this stream is active
  lda stream_active,x
  beq sfx_stream_not_active

  ;update the stream
  jsr stream_update

  ;load channel number
  lda stream_channel,x
  ;multiply by four to get location within apu_register_sets
  asl
  asl
  tay
  ;copy the registers over
  lda stream_channel_register_1,x
  sta apu_register_sets,y
  lda stream_channel_register_2,x
  sta apu_register_sets+1,y
  lda stream_channel_register_3,x
  sta apu_register_sets+2,y
  lda stream_channel_register_4,x
  sta apu_register_sets+3,y
sfx_stream_not_active:

  inx
  cpx #MAX_STREAMS
  bne sfx_stream_register_copy_loop

  ;apu data ready
  lda #1
  sta apu_data_ready

  ;restore regs
  pla
  tax

  rts
.endproc

; Note table borrowed from freq_ntsc.bin provided with Famitracker's driver.
.define note_table \
             $07f2, $077f, $0714, $06ae, $064e, $05f3, $059e, \
      $054d, $0501, $04b9, $0475, $0435, $03f9, $03bf, $038a, \
      $0357, $0327, $02f9, $02cf, $02a6, $0280, $025c, $023a, \
      $021a, $01fc, $01df, $01c5, $01ab, $0193, $017c, $0167, \
      $0153, $0140, $012e, $011d, $010d, $00fe, $00ef, $00e2, \
      $00d5, $00c9, $00be, $00b3, $00a9, $00a0, $0097, $008e, \
      $0086, $007f, $0077, $0071, $006a, $0064, $005f, $0059, \
      $0054, $0050, $004b, $0047, $0043, $003f, $003b, $0038, \
      $0035, $0032, $002f, $002c, $002a, $0028, $0025, $0023, \
      $0021, $001f, $001d, $001c, $001a, $0019, $0017, $0016, \
      $0015, $0014, $0012, $0011, $0010, $000f, $000e, $000e

note_table_lo: .lobytes note_table
note_table_hi: .hibytes note_table

.define channel_callback_table \
  square_1_play_note, \
  square_2_play_note, \
  triangle_play_note, \
  noise_play_note

channel_callback_table_lo: .lobytes channel_callback_table
channel_callback_table_hi: .hibytes channel_callback_table

.define stream_callback_table \
  stream_set_length, \
  stream_set_volume_envelope, \
  stream_set_pitch_envelope, \
  stream_set_duty_envelope, \
  stream_set_all, \
  stream_goto, \
  stream_terminate

stream_callback_table_lo: .lobytes stream_callback_table
stream_callback_table_hi: .hibytes stream_callback_table

  ;****************************************************************
  ;these callbacks are all note playback and only execute once per
  ;frame.
  ;****************************************************************

.proc square_1_play_note

  ;set negate flag for sweep unit
  lda #$08
  sta stream_channel_register_2,x

  ;only load note at the very beginning of a note
  ;(when length and frame counter are the same,
  ;it has just been reset at the beginning of a note)
  lda stream_length,x
  cmp stream_frame_counter,x
  bne skip_load_note
  ;load note index
  ldy stream_byte

  ;load low byte of note
  lda note_table_lo,y
  ;store in low 8 bits of pitch
  sta stream_channel_register_3,x
  ;load high byte of note
  lda note_table_hi,y
  sta stream_channel_register_4,x
skip_load_note:

  ;load volume index
  lda stream_volume_index,x
  asl
  tay
  ;load volume address
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, branch if opcode
  lda (sound_local_word_0),y
  cmp #ENV_STOP
  beq volume_stop
  cmp #ENV_LOOP
  bne skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

skip_volume_loop:

  ;initialize channel control register with envelope decay and
  ;length counter disabled but preserving current duty cycle.
  lda stream_channel_register_1,x
  and #%11000000
  ora #%00110000

  ;load current volume value.
  ora (sound_local_word_0),y
  sta stream_channel_register_1,x

  inc stream_volume_offset,x

volume_stop:

  ;load pitch index
  lda stream_pitch_index,x
  asl
  tay
  ;load pitch address
  lda (base_address_pitch_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_pitch_envelopes),y
  sta sound_local_word_0+1
  ;load pitch offset
  ldy stream_pitch_offset,x

  ;load pitch value
  lda (sound_local_word_0),y
  cmp #ENV_STOP
  beq pitch_stop
  cmp #ENV_LOOP
  bne skip_pitch_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_pitch_offset,x
  tay

skip_pitch_loop:

  ;test sign
  lda (sound_local_word_0),y
  bmi pitch_delta_negative
pitch_delta_positive:

  clc
  lda stream_channel_register_3,x
  adc (sound_local_word_0),y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #0
  sta stream_channel_register_4,x

  jmp pitch_delta_test_done

pitch_delta_negative:

  clc
  lda stream_channel_register_3,x
  adc (sound_local_word_0),y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #$ff
  sta stream_channel_register_4,x

pitch_delta_test_done:

  ;move pitch offset along
  inc stream_pitch_offset,x

pitch_stop:

duty_code:
  ;load duty index
  lda stream_duty_index,x
  asl
  tay
  ;load duty address
  lda (base_address_duty_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_duty_envelopes),y
  sta sound_local_word_0+1
  ;load duty offset
  ldy stream_duty_offset,x

  ;load duty value for this frame, but hard code flags and duty for now
  lda (sound_local_word_0),y
  cmp #DUTY_ENV_STOP
  beq duty_stop
  cmp #DUTY_ENV_LOOP
  bne skip_duty_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_duty_offset,x
  tay

skip_duty_loop:

  ;or the duty value into the register
  lda stream_channel_register_1,x
  and #%00111111
  ora (sound_local_word_0),y
  sta stream_channel_register_1,x

  ;move duty offset along
  inc stream_duty_offset,x

duty_stop:

  rts
.endproc

square_2_play_note = square_1_play_note

.proc triangle_play_note

  ;only load note at the very beginning of a note
  ;(when length and frame counter are the same,
  ;it has just been reset at the beginning of a note)
  lda stream_length,x
  cmp stream_frame_counter,x
  bne skip_load_note
  ;load note index
  ldy stream_byte

  ;load low byte of note
  lda note_table_lo,y
  ;store in low 8 bits of pitch
  sta stream_channel_register_3,x
  ;load high byte of note
  lda note_table_hi,y
  sta stream_channel_register_4,x
skip_load_note:

  ;load volume index
  lda stream_volume_index,x
  asl
  tay
  ;load volume address
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, but hard code flags and duty for now
  lda (sound_local_word_0),y
  cmp #ENV_STOP
  beq volume_stop
  cmp #ENV_LOOP
  bne skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

skip_volume_loop:

  lda #%10000000
  ora (sound_local_word_0),y
  sta stream_channel_register_1,x

  inc stream_volume_offset,x

volume_stop:

  ;load pitch index
  lda stream_pitch_index,x
  asl
  tay
  ;load pitch address
  lda (base_address_pitch_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_pitch_envelopes),y
  sta sound_local_word_0+1
  ;load pitch offset
  ldy stream_pitch_offset,x

  ;load pitch value
  lda (sound_local_word_0),y
  cmp #ENV_STOP
  beq pitch_stop
  cmp #ENV_LOOP
  bne skip_pitch_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_pitch_offset,x
  tay

skip_pitch_loop:

  ;test sign
  lda (sound_local_word_0),y
  bmi pitch_delta_negative
pitch_delta_positive:

  clc
  lda stream_channel_register_3,x
  adc (sound_local_word_0),y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #0
  sta stream_channel_register_4,x

  jmp pitch_delta_test_done

pitch_delta_negative:

  clc
  lda stream_channel_register_3,x
  adc (sound_local_word_0),y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #$ff
  sta stream_channel_register_4,x

pitch_delta_test_done:

  ;move pitch offset along
  inc stream_pitch_offset,x

pitch_stop:

  rts
.endproc

.proc noise_play_note

  ;load note index
  lda stream_byte

  ;note index is actually the "sound type" for noise channel
  sta stream_channel_register_3,x

  ;load volume index
  lda stream_volume_index,x
  asl
  tay
  ;load volume address
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0
  iny
  lda (base_address_volume_envelopes),y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, hard code disable flags
  lda (sound_local_word_0),y
  cmp #ENV_STOP
  beq volume_stop
  cmp #ENV_LOOP
  bne skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

skip_volume_loop:

  lda #%00110000
  ora (sound_local_word_0),y
  sta stream_channel_register_1,x

  ;move volume offset along
  inc stream_volume_offset,x
volume_stop:

  rts
.endproc


  ;****************************************************************
  ;these callbacks are all stream control and execute in sequence
  ;until exhausted.
  ;****************************************************************

.proc stream_set_all

  ;grab all parameters from right after the opcode
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1

  ;get length parameter
  ldy #1
  lda (sound_local_word_0),y
  sta stream_length,x
  sta stream_frame_counter,x

  ;get volume envelope index
  iny
  lda (sound_local_word_0),y
  sta stream_volume_index,x
  lda #0
  sta stream_volume_offset,x

  ;get pitch envelope index
  iny
  lda (sound_local_word_0),y
  sta stream_pitch_index,x
  lda #0
  sta stream_pitch_offset,x

  ;get duty envelope index
  iny
  lda (sound_local_word_0),y
  sta stream_duty_index,x
  lda #0
  sta stream_duty_offset,x

  ;now advance the stream read address to point to last parameter.
  ;all other callbacks have only one parameter---and they are pointing
  ;to it by the end of the routine. the read address is then advanced to
  ;the next opcode or note by stream_update.
  clc
  lda stream_read_address_lo,x
  adc #4
  sta stream_read_address_lo,x
  lda stream_read_address_hi,x
  adc #0
  sta stream_read_address_hi,x

  rts
.endproc

.proc stream_set_volume_envelope

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda (sound_local_word_0),y
  sta stream_volume_index,x
  lda #0
  sta stream_volume_offset,x

  rts
.endproc

.proc stream_set_pitch_envelope

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda (sound_local_word_0),y
  sta stream_pitch_index,x
  lda #0
  sta stream_pitch_offset,x

  rts
.endproc

.proc stream_set_duty_envelope

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda (sound_local_word_0),y
  sta stream_duty_index,x
  lda #0
  sta stream_duty_offset,x

  rts
.endproc

.proc stream_set_length

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda (sound_local_word_0),y
  sta stream_length,x
  sta stream_frame_counter,x

  rts
.endproc

;this opcode loops to the beginning of the stream. It expects the two
;following bytes to contain the address to loop to.
.proc stream_goto

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda (sound_local_word_0),y
  sta stream_read_address_lo,x
  ldy #1
  lda (sound_local_word_0),y
  sta stream_read_address_hi,x

  sec
  lda stream_read_address_lo,x
  sbc #1
  sta stream_read_address_lo,x
  lda stream_read_address_hi,x
  sbc #0
  sta stream_read_address_hi,x

  rts

.endproc

;this opcode returns from the parent caller by popping two bytes off
;the stack and then doing rts.
.proc stream_terminate

  ;set the current stream to inactive
  lda #0
  sta stream_active,x

  ;pop current address off the stack
  pla
  pla

  ;return from parent caller
  rts
.endproc

;expects song_address to contain address of a song definition,
;assumed to be four addresses to initialize streams on, for square1, square2, triangle and noise.
;any addresses found to be zero will not initialize that channel.
.proc song_initialize

  ;save index regs
  tya
  pha
  txa
  pha

  inc sound_disable_update

  ;load square 1 stream
  ldx #0
  jsr stream_stop

  ldy #song_header::square1_stream_address
  lda (song_address),y
  sta sound_param_word_0
  iny
  lda (song_address),y
  beq no_square_1
  sta sound_param_word_0+1

  lda #0
  sta sound_param_byte_0

  lda #0
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #song_header::tempo
  lda (song_address),y
  sta stream_tempo,x
no_square_1:

  ;load square 2 stream
  ldx #1
  jsr stream_stop

  ldy #song_header::square2_stream_address
  lda (song_address),y
  sta sound_param_word_0
  iny
  lda (song_address),y
  beq no_square_2
  sta sound_param_word_0+1

  lda #1
  sta sound_param_byte_0

  lda #1
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #song_header::tempo
  lda (song_address),y
  sta stream_tempo,x
no_square_2:

  ;load triangle stream
  ldx #2
  jsr stream_stop

  ldy #song_header::triangle_stream_address
  lda (song_address),y
  sta sound_param_word_0
  iny
  lda (song_address),y
  beq no_triangle
  sta sound_param_word_0+1

  lda #2
  sta sound_param_byte_0

  lda #2
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #song_header::tempo
  lda (song_address),y
  sta stream_tempo,x
no_triangle:

  ;load noise stream
  ldx #3
  jsr stream_stop

  ldy #song_header::noise_stream_address
  lda (song_address),y
  sta sound_param_word_0
  iny
  lda (song_address),y
  beq no_noise
  sta sound_param_word_0+1

  lda #3
  sta sound_param_byte_0

  lda #3
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #song_header::tempo
  lda (song_address),y
  sta stream_tempo,x
no_noise:

  ;load volume envelopes
  ldy #song_header::volume_envelopes_address
  lda (song_address),y
  sta song_base_address_volume_envelopes
  iny
  lda (song_address),y
  sta song_base_address_volume_envelopes+1

  ;load pitch envelopes
  ldy #song_header::pitch_envelopes_address
  lda (song_address),y
  sta song_base_address_pitch_envelopes
  iny
  lda (song_address),y
  sta song_base_address_pitch_envelopes+1

  ;load duty envelopes
  ldy #song_header::duty_envelopes_address
  lda (song_address),y
  sta song_base_address_duty_envelopes
  iny
  lda (song_address),y
  sta song_base_address_duty_envelopes+1

  dec sound_disable_update

  ;restore index regs
  pla
  tax
  pla
  tay

  rts

.endproc

;expects sound_param_word_0 to contain address of a sfx defnition,
;assumed to be three addresses for volume envelopes, pitch envelopes and duty envelopes.
.proc sfx_initialize
sfx_address = sound_param_word_0

  ;save index regs
  tya
  pha
  txa
  pha

  inc sound_disable_update

  ;load volume envelopes
  ldy #0
  lda (sfx_address),y
  sta sfx_base_address_volume_envelopes
  iny
  lda (sfx_address),y
  sta sfx_base_address_volume_envelopes+1

  ;load pitch envelopes
  iny
  lda (sfx_address),y
  sta sfx_base_address_pitch_envelopes
  iny
  lda (sfx_address),y
  sta sfx_base_address_pitch_envelopes+1

  ;load duty envelopes
  iny
  lda (sfx_address),y
  sta sfx_base_address_duty_envelopes
  iny
  lda (sfx_address),y
  sta sfx_base_address_duty_envelopes+1

  dec sound_disable_update

  ;restore index regs
  pla
  tax
  pla
  tay

  rts

.endproc

;expects sound_param_byte_0 to contain the channel on which to play the stream.
;expects sound_param_byte_1 to contain the offset of the stream instance to initialize
;expects sound_param_word_0 to contain the starting read address of the stream to
;initialize.
.proc stream_initialize
channel = sound_param_byte_0
stream = sound_param_byte_1
starting_read_address = sound_param_word_0

  ;save x
  txa
  pha

  ldx stream

  inc sound_disable_update

  lda starting_read_address
  ora starting_read_address+1
  beq null_starting_read_address

  ;set stream to be inactive while initializing
  lda #0
  sta stream_active,x

  ;set a default note length (20 frames)
  lda #20
  sta stream_length,x

  ;set initial frame counter
  sta stream_frame_counter,x

  ;set initial envelope indices
  lda #0
  sta stream_volume_index,x
  sta stream_pitch_index,x
  sta stream_duty_index,x
  sta stream_volume_offset,x
  sta stream_pitch_offset,x
  sta stream_duty_offset,x

  ;set channel
  lda channel
  sta stream_channel,x

  ;set initial read address
  lda starting_read_address
  sta stream_read_address_lo,x
  lda starting_read_address+1
  sta stream_read_address_hi,x

  ;set default tempo
  lda #DEFAULT_TEMPO
  sta stream_tempo,x
  lda #0
  sta stream_tempo_counter,x
  sta stream_tempo_carry,x

  ;set stream to be active
  lda #1
  sta stream_active,x
null_starting_read_address:

  dec sound_disable_update

  ;restore x
  pla
  tax

  rts
.endproc

;stops a stream from playing
;assumes x contains the index of the stream to kill
.proc stream_stop

  inc sound_disable_update

  lda #0
  sta stream_active,x

  dec sound_disable_update

  rts

.endproc

;updates a single stream
;expects x to be pointing to a stream instance as an offset from streams
.proc stream_update
callback_address = sound_local_word_0
read_address = sound_local_word_1

  ;load current read address of stream
  lda stream_read_address_lo,x
  sta read_address
  lda stream_read_address_hi,x
  sta read_address+1

  ;load next byte from stream data
  ldy #0
  lda (read_address),y
  sta stream_byte

  ;is this byte a note or a stream opcode?
  cmp #OPCODES_BASE
  bpl process_opcode
process_note:

  ;determine which channel callback to use
  lda stream_channel,x
  tay
  lda channel_callback_table_lo,y
  sta callback_address
  lda channel_callback_table_hi,y
  sta callback_address+1

  ;call the channel callback!
  jsr indirect_jsr_callback_address

  ;add the tempo to the current counter. On carry, advance.
  ror stream_tempo_carry,x
  lda stream_tempo_counter,x
  adc stream_tempo,x
  sta stream_tempo_counter,x
  rol stream_tempo_carry,x
  lda stream_tempo_carry,x
  beq do_not_advance_frame_counter

  ;decrement the frame counter. on zero, advance the stream's read address.
  dec stream_frame_counter,x
  bne frame_counter_not_zero

  ;reset the frame counter
  lda stream_length,x
  sta stream_frame_counter,x

  ;reset volume, pitch, and duty offsets
  lda #0
  sta stream_volume_offset,x
  sta stream_pitch_offset,x
  sta stream_duty_offset,x

  ;advance the stream's read address.
  advance_stream_read_address
do_not_advance_frame_counter:
frame_counter_not_zero:

  rts
process_opcode:

  ;look up the opcode in the stream callbacks table
  sec
  sbc #OPCODES_BASE
  tay
  ;get the address
  lda stream_callback_table_lo,y
  sta callback_address
  lda stream_callback_table_hi,y
  sta callback_address+1
  ;call the callback!
  jsr indirect_jsr_callback_address

  ;advance the stream's read address.
  advance_stream_read_address

  ;immediately process the next opcode or note. The idea here is that
  ;all stream control opcodes will execute during the current frame as "setup"
  ;for the next note. All notes will execute once per frame and will always
  ;return from this routine. This leaves the problem, how would the stream
  ;control opcode "terminate" work? It works by pulling the current return
  ;address off the stack and then performing an rts, effectively returning
  ;from its caller, this routine.
  jmp stream_update

.proc indirect_jsr_callback_address
  jmp (callback_address)
  rts
.endproc

.endproc

.proc sound_initialize_apu_buffer

  ;****************************************************************
  ;Initialize Square 1
  ;****************************************************************

  ;set Saw Envelope Disable and Length Counter Disable to 1 for square 1.
  lda #%00110000
  sta apu_register_sets

  lda #$08    ;set Negate flag on the sweep unit
  sta apu_register_sets+1

  ;set period to C9, which is a C#...just in case nobody writes to him
  lda #$C9
  sta apu_register_sets+2

  ;make sure the old value starts out different from the first default value
  sta apu_square_1_old

  lda #$00
  sta apu_register_sets+3

  ;****************************************************************
  ;Initialize Square 2
  ;****************************************************************

  ;set Saw Envelope Disable and Length Counter Disable to 1 for square 2.
  lda #%00110000
  sta apu_register_sets+4

  lda #$08    ;set Negate flag on the sweep unit
  sta apu_register_sets+5

  ;set period to C9, which is a C#...just in case nobody writes to him
  lda #$C9
  sta apu_register_sets+6

  ;make sure the old value starts out different from the first default value
  sta apu_square_2_old

  lda #$00
  sta apu_register_sets+7

  ;****************************************************************
  ;Initialize Triangle
  ;****************************************************************
  lda #%10000000
  sta apu_register_sets+8

  lda #$C9
  sta apu_register_sets+10

  lda #$00
  sta apu_register_sets+11

  ;****************************************************************
  ;Initialize Noise
  ;****************************************************************
  lda #%00110000
  sta apu_register_sets+12

  lda #%00000000
  sta apu_register_sets+13

  lda #%00000000
  sta apu_register_sets+14

  lda #%00000000
  sta apu_register_sets+15

  rts
.endproc

.proc sound_upload

  lda apu_data_ready
  beq apu_data_not_ready

  jsr sound_upload_apu_register_sets

apu_data_not_ready:

  rts
.endproc

;adapted from MetalSlime's Nerdy Nights sound engine
.proc sound_upload_apu_register_sets
square1:
  lda apu_register_sets+0
  sta $4000
  lda apu_register_sets+1
  sta $4001
  lda apu_register_sets+2
  sta $4002
  lda apu_register_sets+3
  cmp apu_square_1_old       ;compare to last write
  beq square2                ;don't write this frame if they were equal
  sta $4003
  sta apu_square_1_old       ;save the value we just wrote to $4003
square2:
  lda apu_register_sets+4
  sta $4004
  lda apu_register_sets+5
  sta $4005
  lda apu_register_sets+6
  sta $4006
  lda apu_register_sets+7
  cmp apu_square_2_old
  beq triangle
  sta $4007
  sta apu_square_2_old       ;save the value we just wrote to $4007
triangle:
  lda apu_register_sets+8
  sta $4008
  lda apu_register_sets+10
  sta $400A
  lda apu_register_sets+11
  sta $400B
noise:
  lda apu_register_sets+12
  sta $400C
  lda apu_register_sets+14
  sta $400E
  lda apu_register_sets+15
  sta $400F

  ;clear out all volume values from this frame in case a sound effect is killed suddenly
  lda #%00110000
  sta apu_register_sets
  sta apu_register_sets+4
  sta apu_register_sets+12
  lda #%10000000
  sta apu_register_sets+8

  rts
.endproc
