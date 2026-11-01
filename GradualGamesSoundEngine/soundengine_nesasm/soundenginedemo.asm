;****************************************************************
;iNES header
;****************************************************************
  .inesprg 1   ;1x 16KB PRG code
  .ineschr 0   ;0x  8KB CHR data
  .inesmap 0   ;mapper 0 = NROM, no bank swapping
  .inesmir 1   ;background mirroring

;****************************************************************
;Constants
;****************************************************************

;The max number of streams we support. The engine assumes the first
;four streams are music, so this number must never be less than four!
MAX_STREAMS = 6

;****************************************************************
;The following are all opcodes. All opcodes in range 0-93 are
;interpreted as a note playback call. Everything 94 or above
;are interpreted as stream control opcodes.
;****************************************************************

A0  = 0
AS0 = 1
B0  = 2
C1  = 3
CS1 = 4
D1  = 5
DS1 = 6
E1  = 7
F1  = 8
FS1 = 9
G1  = 10
GS1 = 11
A1  = 12
AS1 = 13
B1  = 14
C2  = 15
CS2 = 16
D2  = 17
DS2 = 18
E2  = 19
F2  = 20
FS2 = 21
G2  = 22
GS2 = 23
A2  = 24
AS2 = 25
B2  = 26
C3  = 27
CS3 = 28
D3  = 29
DS3 = 30
E3  = 31
F3  = 32
FS3 = 33
G3  = 34
GS3 = 35
A3  = 36
AS3 = 37
B3  = 38
C4  = 39
CS4 = 40
D4  = 41
DS4 = 42
E4  = 43
F4  = 44
FS4 = 45
G4  = 46
GS4 = 47
A4  = 48
AS4 = 49
B4  = 50
C5  = 51
CS5 = 52
D5  = 53
DS5 = 54
E5  = 55
F5  = 56
FS5 = 57
G5  = 58
GS5 = 59
A5  = 60
AS5 = 61
B5  = 62
C6  = 63
CS6 = 64
D6  = 65
DS6 = 66
E6  = 67
F6  = 68
FS6 = 69
G6  = 70
GS6 = 71
A6  = 72
AS6 = 73
B6  = 74
C7  = 75
CS7 = 76
D7  = 77
DS7 = 78
E7  = 79
F7  = 80
FS7 = 81
G7  = 82
GS7 = 83
A7  = 84
AS7 = 85
B7  = 86
C8  = 87
CS8 = 88
D8  = 89
DS8 = 90
E8  = 91
F8  = 92
FS8 = 93

OPCODES_BASE = 94

;stream control opcodes

;set length
STL = 0+OPCODES_BASE

;set volume envelope
STV = 1+OPCODES_BASE

;set pitch envelope
STP = 2+OPCODES_BASE

;set duty envelope
SDU = 3+OPCODES_BASE

;set all stream parameters (takes 4 parameters, performs duties of all above opcodes)
SA =  4+OPCODES_BASE

;goto
GOT = 5+OPCODES_BASE

;terminate
TRM = 6+OPCODES_BASE

;opcodes read from volume and pitch envelopes. These values are also
;reserved by Famitracker, so they are safe to use.
ENV_STOP = %10000000 ;-128
ENV_LOOP = %01111111 ; 127

;a different set of opcodes for stop and loop for duty cycle envelopes.
;This is necessary since ENV_STOP can be intepreted as duty cycle = 2,
;preventing users from using that setting.
DUTY_ENV_STOP = %00111111
DUTY_ENV_LOOP = %00101010

;note length constants

_64TH    = 5
_32ND    = 2*_64TH
_16TH    = 2*_32ND
_8TH     = 2*_16TH
_QUARTER = 2*_8TH

;values to use for x for playing sound effects
soundeffect_one = 4
soundeffect_two = 5

;default tempo.
DEFAULT_TEMPO = 255

;song header offsets
header_tempo = 0
header_square1_stream_address = 1
header_square2_stream_address = 3
header_triangle_stream_address = 5
header_noise_stream_address = 7
header_volume_envelopes_address = 9
header_pitch_envelopes_address = 11
header_duty_envelopes_address = 13

;****************************************************************
;Macros
;****************************************************************

  .macro advance_stream_read_address

  clc
  lda stream_read_address_lo,x
  adc #1
  sta stream_read_address_lo,x
  lda stream_read_address_hi,x
  adc #0
  sta stream_read_address_hi,x

  .endm

;****************************************************************
;ZP variables
;****************************************************************
  .rsset $0000

sound_disable_update: .rs 1
sound_zp_start:
sound_local_byte_0: .rs 1
sound_local_byte_1: .rs 1
sound_local_byte_2: .rs 1

sound_local_word_0: .rs 2
sound_local_word_1: .rs 2
sound_local_word_2: .rs 2

sound_param_byte_0: .rs 1
sound_param_byte_1: .rs 1
sound_param_byte_2: .rs 1

sound_param_word_0: .rs 2
sound_param_word_1: .rs 2
sound_param_word_2: .rs 2

base_address_volume_envelopes: .rs 2
base_address_pitch_envelopes:  .rs 2
base_address_duty_envelopes:   .rs 2

stream_byte: .rs 1

apu_data_ready: .rs 1
apu_square_1_old: .rs 1
apu_square_2_old: .rs 1

;original song address
song_address: .rs 2
sound_zp_end:

;just a flag to tell us vblank completed---not part of the sound engine!
vblank_done: .rs 1

;****************************************************************
;RAM variables
;****************************************************************
  .rsset $0200

sound_ram_start:
song_base_address_volume_envelopes: .rs 2
song_base_address_pitch_envelopes: .rs 2
song_base_address_duty_envelopes: .rs 2
sfx_base_address_volume_envelopes: .rs 2
sfx_base_address_pitch_envelopes: .rs 2
sfx_base_address_duty_envelopes: .rs 2

;streams
stream_active:             .rs MAX_STREAMS
stream_length:             .rs MAX_STREAMS
stream_frame_counter:      .rs MAX_STREAMS
stream_volume_index:       .rs MAX_STREAMS
stream_volume_offset:      .rs MAX_STREAMS
stream_pitch_index:        .rs MAX_STREAMS
stream_pitch_offset:       .rs MAX_STREAMS
stream_duty_index:         .rs MAX_STREAMS
stream_duty_offset:        .rs MAX_STREAMS

stream_channel:            .rs MAX_STREAMS
stream_channel_register_1: .rs MAX_STREAMS
stream_channel_register_2: .rs MAX_STREAMS
stream_channel_register_3: .rs MAX_STREAMS
stream_channel_register_4: .rs MAX_STREAMS

stream_read_address_lo:    .rs MAX_STREAMS
stream_read_address_hi:    .rs MAX_STREAMS

stream_tempo_counter:      .rs MAX_STREAMS
stream_tempo_carry:        .rs MAX_STREAMS
stream_tempo:              .rs MAX_STREAMS

;five total channels, 4 bytes per channel, so 40 bytes.
apu_register_sets: .rs 40
sound_ram_end:

;****************************************************************
;Demo entry point
;****************************************************************
  .bank 0
  .org $C000
reset:
  sei          ;disable IRQs
  cld          ;disable decimal mode
  ldx #$40
  stx $4017    ;disable APU frame IRQ
  ldx #$FF
  txs          ;Set up stack
  inx          ;now X = 0
  stx $2000    ;disable NMI
  stx $2001    ;disable rendering
  stx $4010    ;disable DMC IRQs

vblankwait1:   ;First wait for vblank to make sure PPU is ready
  bit $2002
  bpl vblankwait1

clrmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0300, x
  inx
  bne clrmem

vblankwait2:      ;Second wait for vblank, PPU is ready after this
  bit $2002
  bpl vblankwait2


  lda #%10000000   ;intensify blues
  sta $2001

  ;turn on nmi
  lda #%10000000
  sta $2000

  lda #0
  sta vblank_done

  jsr here_is_how_you_initialize_everything

forever:
  lda vblank_done
  beq forever

  ;strobe controller
  lda #$01
  sta $4016
  lda #$00
  sta $4016

  ;check A button to play sound effect 1
  lda $4016
  and #1
  beq not_a
  jsr how_to_play_sound_effect_one
not_a:

  ;check A button to play sound effect 2
  lda $4016
  and #1
  beq not_b
  jsr how_to_play_sound_effect_two
not_b:

  jmp forever

nmi:
  pha
  txa
  pha
  tya
  pha
  php

  jsr call_this_from_end_of_vblank

  lda #1
  sta vblank_done

  plp
  pla
  tay
  pla
  tax
  pla

irq:
  rti

;****************************************************************
;Sound engine usage demo functions.
;****************************************************************
here_is_how_you_initialize_everything:

  ;initialize modules
  jsr sound_initialize

  ;load sfx set
  lda #LOW(sfx_set1)
  sta sound_param_word_0
  lda #HIGH(sfx_set1)
  sta sound_param_word_0+1
  jsr sfx_initialize

  ;load a song
  lda #LOW(song1)
  sta song_address
  lda #HIGH(song1)
  sta song_address+1
  jsr song_initialize

  rts



how_to_play_sound_effect_one:

  ;this parameter is the address of the sound effect you wish
  ;to play.
  lda #LOW(sfx_select)
  sta sound_param_word_0
  lda #HIGH(sfx_select)
  sta sound_param_word_0+1

  ;this parameter corresponds to whether to play the
  ;sound on square 1, 2, triangle, or noise. DPMC is not supported.
  lda #3
  sta sound_param_byte_0
  ;to play a sound effect, you must use a stream that is not one
  ;of the song streams. In this engine, that is soundeffect_one
  ;and soundeffect_two.
  lda #soundeffect_one
  sta sound_param_byte_1

  jsr stream_initialize

  rts



how_to_play_sound_effect_two:

  lda #LOW(sfx_inventory)
  sta sound_param_word_0
  lda #HIGH(sfx_inventory)
  sta sound_param_word_0+1

  lda #0
  sta sound_param_byte_0
  lda #soundeffect_two
  sta sound_param_byte_1

  jsr stream_initialize

  rts



call_this_from_end_of_vblank:

  lda sound_disable_update
  bne sound_update_disabled

  jsr sound_update
  jsr sound_upload

sound_update_disabled:

  rts



;****************************************************************
;Demo data
;****************************************************************
  .include "song36.asm"
  .include "sfx_set.asm"

;****************************************************************
;Sound engine
;****************************************************************
sound_initialize:

  lda #1
  sta sound_disable_update

  ;clear sound engine zp and ram
  lda #0
  ldx #(sound_zp_end - sound_zp_start - 1)
.xloop0:
  sta sound_zp_start,x
  dex
  bne .xloop0
  sta sound_zp_start,x

  ldx #(sound_ram_end - sound_ram_start - 1)
.xloop1:
  sta sound_ram_start,x
  dex
  bne .xloop1
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



;kill all active streams and halt sound
sound_stop:

  ;save x
  txa
  pha

  inc sound_disable_update

  ;kill all streams
  ldx #(MAX_STREAMS-1)
.loop:

  lda #0
  sta stream_active,x

  dex
  bpl .loop

  jsr sound_initialize_apu_buffer

  dec sound_disable_update

  ;restore x
  pla
  tax

  rts


sound_update:

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
  asl a
  asl a
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
  asl a
  asl a
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


; Note table borrowed from freq_ntsc.bin provided with Famitracker's driver.
note_table_lo:
      .db LOW($07f2), LOW($077f), LOW($0714), LOW($06ae), LOW($064e), LOW($05f3), LOW($059e)
      .db LOW($054d), LOW($0501), LOW($04b9), LOW($0475), LOW($0435), LOW($03f9), LOW($03bf), LOW($038a)
      .db LOW($0357), LOW($0327), LOW($02f9), LOW($02cf), LOW($02a6), LOW($0280), LOW($025c), LOW($023a)
      .db LOW($021a), LOW($01fc), LOW($01df), LOW($01c5), LOW($01ab), LOW($0193), LOW($017c), LOW($0167)
      .db LOW($0153), LOW($0140), LOW($012e), LOW($011d), LOW($010d), LOW($00fe), LOW($00ef), LOW($00e2)
      .db LOW($00d5), LOW($00c9), LOW($00be), LOW($00b3), LOW($00a9), LOW($00a0), LOW($0097), LOW($008e)
      .db LOW($0086), LOW($007f), LOW($0077), LOW($0071), LOW($006a), LOW($0064), LOW($005f), LOW($0059)
      .db LOW($0054), LOW($0050), LOW($004b), LOW($0047), LOW($0043), LOW($003f), LOW($003b), LOW($0038)
      .db LOW($0035), LOW($0032), LOW($002f), LOW($002c), LOW($002a), LOW($0028), LOW($0025), LOW($0023)
      .db LOW($0021), LOW($001f), LOW($001d), LOW($001c), LOW($001a), LOW($0019), LOW($0017), LOW($0016)
      .db LOW($0015), LOW($0014), LOW($0012), LOW($0011), LOW($0010), LOW($000f), LOW($000e), LOW($000e)

note_table_hi:
      .db HIGH($07f2), HIGH($077f), HIGH($0714), HIGH($06ae), HIGH($064e), HIGH($05f3), HIGH($059e)
      .db HIGH($054d), HIGH($0501), HIGH($04b9), HIGH($0475), HIGH($0435), HIGH($03f9), HIGH($03bf), HIGH($038a)
      .db HIGH($0357), HIGH($0327), HIGH($02f9), HIGH($02cf), HIGH($02a6), HIGH($0280), HIGH($025c), HIGH($023a)
      .db HIGH($021a), HIGH($01fc), HIGH($01df), HIGH($01c5), HIGH($01ab), HIGH($0193), HIGH($017c), HIGH($0167)
      .db HIGH($0153), HIGH($0140), HIGH($012e), HIGH($011d), HIGH($010d), HIGH($00fe), HIGH($00ef), HIGH($00e2)
      .db HIGH($00d5), HIGH($00c9), HIGH($00be), HIGH($00b3), HIGH($00a9), HIGH($00a0), HIGH($0097), HIGH($008e)
      .db HIGH($0086), HIGH($007f), HIGH($0077), HIGH($0071), HIGH($006a), HIGH($0064), HIGH($005f), HIGH($0059)
      .db HIGH($0054), HIGH($0050), HIGH($004b), HIGH($0047), HIGH($0043), HIGH($003f), HIGH($003b), HIGH($0038)
      .db HIGH($0035), HIGH($0032), HIGH($002f), HIGH($002c), HIGH($002a), HIGH($0028), HIGH($0025), HIGH($0023)
      .db HIGH($0021), HIGH($001f), HIGH($001d), HIGH($001c), HIGH($001a), HIGH($0019), HIGH($0017), HIGH($0016)
      .db HIGH($0015), HIGH($0014), HIGH($0012), HIGH($0011), HIGH($0010), HIGH($000f), HIGH($000e), HIGH($000e)

channel_callback_table_lo:
  .db LOW(square_1_play_note)
  .db LOW(square_2_play_note)
  .db LOW(triangle_play_note)
  .db LOW(noise_play_note)

channel_callback_table_hi:
  .db HIGH(square_1_play_note)
  .db HIGH(square_2_play_note)
  .db HIGH(triangle_play_note)
  .db HIGH(noise_play_note)

stream_callback_table_lo:
  .db LOW(stream_set_length)
  .db LOW(stream_set_volume_envelope)
  .db LOW(stream_set_pitch_envelope)
  .db LOW(stream_set_duty_envelope)
  .db LOW(stream_set_all)
  .db LOW(stream_goto)
  .db LOW(stream_terminate)

stream_callback_table_hi:
  .db HIGH(stream_set_length)
  .db HIGH(stream_set_volume_envelope)
  .db HIGH(stream_set_pitch_envelope)
  .db HIGH(stream_set_duty_envelope)
  .db HIGH(stream_set_all)
  .db HIGH(stream_goto)
  .db HIGH(stream_terminate)

  ;****************************************************************
  ;these callbacks are all note playback and only execute once per
  ;frame.
  ;****************************************************************

square_2_play_note:
square_1_play_note:

  ;set negate flag for sweep unit
  lda #$08
  sta stream_channel_register_2,x

  ;only load note at the very beginning of a note
  ;(when length and frame counter are the same,
  ;it has just been reset at the beginning of a note)
  lda stream_length,x
  cmp stream_frame_counter,x
  bne .skip_load_note
  ;load note index
  ldy stream_byte

  ;load low byte of note
  lda note_table_lo,y
  ;store in low 8 bits of pitch
  sta stream_channel_register_3,x
  ;load high byte of note
  lda note_table_hi,y
  sta stream_channel_register_4,x
.skip_load_note:

  ;load volume index
  lda stream_volume_index,x
  asl a
  tay
  ;load volume address
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, branch if opcode
  lda [sound_local_word_0],y
  cmp #ENV_STOP
  beq .volume_stop
  cmp #ENV_LOOP
  bne .skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

.skip_volume_loop:

  ;initialize channel control register with envelope decay and
  ;length counter disabled but preserving current duty cycle.
  lda stream_channel_register_1,x
  and #%11000000
  ora #%00110000

  ;load current volume value.
  ora [sound_local_word_0],y
  sta stream_channel_register_1,x

  inc stream_volume_offset,x

.volume_stop:

  ;load pitch index
  lda stream_pitch_index,x
  asl a
  tay
  ;load pitch address
  lda [base_address_pitch_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_pitch_envelopes],y
  sta sound_local_word_0+1
  ;load pitch offset
  ldy stream_pitch_offset,x

  ;load pitch value
  lda [sound_local_word_0],y
  cmp #ENV_STOP
  beq .pitch_stop
  cmp #ENV_LOOP
  bne .skip_pitch_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_pitch_offset,x
  tay

.skip_pitch_loop:

  ;test sign
  lda [sound_local_word_0],y
  bmi .pitch_delta_negative
.pitch_delta_positive:

  clc
  lda stream_channel_register_3,x
  adc [sound_local_word_0],y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #0
  sta stream_channel_register_4,x

  jmp .pitch_delta_test_done

.pitch_delta_negative:

  clc
  lda stream_channel_register_3,x
  adc [sound_local_word_0],y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #$ff
  sta stream_channel_register_4,x

.pitch_delta_test_done:

  ;move pitch offset along
  inc stream_pitch_offset,x

.pitch_stop:

.duty_code:
  ;load duty index
  lda stream_duty_index,x
  asl a
  tay
  ;load duty address
  lda [base_address_duty_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_duty_envelopes],y
  sta sound_local_word_0+1
  ;load duty offset
  ldy stream_duty_offset,x

  ;load duty value for this frame, but hard code flags and duty for now
  lda [sound_local_word_0],y
  cmp #DUTY_ENV_STOP
  beq .duty_stop
  cmp #DUTY_ENV_LOOP
  bne .skip_duty_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_duty_offset,x
  tay

.skip_duty_loop:

  ;or the duty value into the register
  lda stream_channel_register_1,x
  and #%00111111
  ora [sound_local_word_0],y
  sta stream_channel_register_1,x

  ;move duty offset along
  inc stream_duty_offset,x

.duty_stop:

  rts


triangle_play_note:

  ;only load note at the very beginning of a note
  ;(when length and frame counter are the same,
  ;it has just been reset at the beginning of a note)
  lda stream_length,x
  cmp stream_frame_counter,x
  bne .skip_load_note
  ;load note index
  ldy stream_byte

  ;load low byte of note
  lda note_table_lo,y
  ;store in low 8 bits of pitch
  sta stream_channel_register_3,x
  ;load high byte of note
  lda note_table_hi,y
  sta stream_channel_register_4,x
.skip_load_note:

  ;load volume index
  lda stream_volume_index,x
  asl a
  tay
  ;load volume address
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, but hard code flags and duty for now
  lda [sound_local_word_0],y
  cmp #ENV_STOP
  beq .volume_stop
  cmp #ENV_LOOP
  bne .skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

.skip_volume_loop:

  lda #%10000000
  ora [sound_local_word_0],y
  sta stream_channel_register_1,x

  inc stream_volume_offset,x

.volume_stop:

  ;load pitch index
  lda stream_pitch_index,x
  asl a
  tay
  ;load pitch address
  lda [base_address_pitch_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_pitch_envelopes],y
  sta sound_local_word_0+1
  ;load pitch offset
  ldy stream_pitch_offset,x

  ;load pitch value
  lda [sound_local_word_0],y
  cmp #ENV_STOP
  beq .pitch_stop
  cmp #ENV_LOOP
  bne .skip_pitch_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_pitch_offset,x
  tay

.skip_pitch_loop:

  ;test sign
  lda [sound_local_word_0],y
  bmi .pitch_delta_negative
.pitch_delta_positive:

  clc
  lda stream_channel_register_3,x
  adc [sound_local_word_0],y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #0
  sta stream_channel_register_4,x

  jmp .pitch_delta_test_done

.pitch_delta_negative:

  clc
  lda stream_channel_register_3,x
  adc [sound_local_word_0],y
  sta stream_channel_register_3,x
  lda stream_channel_register_4,x
  adc #$ff
  sta stream_channel_register_4,x

.pitch_delta_test_done:

  ;move pitch offset along
  inc stream_pitch_offset,x

.pitch_stop:

  rts


noise_play_note:

  ;load note index
  lda stream_byte

  ;note index is actually the "sound type" for noise channel
  sta stream_channel_register_3,x

  ;load volume index
  lda stream_volume_index,x
  asl a
  tay
  ;load volume address
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0
  iny
  lda [base_address_volume_envelopes],y
  sta sound_local_word_0+1
  ;load volume offset
  ldy stream_volume_offset,x

  ;load volume value for this frame, hard code disable flags
  lda [sound_local_word_0],y
  cmp #ENV_STOP
  beq .volume_stop
  cmp #ENV_LOOP
  bne .skip_volume_loop

  ;we hit a loop opcode, reset offset and re-load value
  lda #0
  sta stream_volume_offset,x
  tay

.skip_volume_loop:

  lda #%00110000
  ora [sound_local_word_0],y
  sta stream_channel_register_1,x

  ;move volume offset along
  inc stream_volume_offset,x
.volume_stop:

  rts



  ;****************************************************************
  ;these callbacks are all stream control and execute in sequence
  ;until exhausted.
  ;****************************************************************

stream_set_all:

  ;grab all parameters from right after the opcode
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1

  ;get length parameter
  ldy #1
  lda [sound_local_word_0],y
  sta stream_length,x
  sta stream_frame_counter,x

  ;get volume envelope index
  iny
  lda [sound_local_word_0],y
  sta stream_volume_index,x
  lda #0
  sta stream_volume_offset,x

  ;get pitch envelope index
  iny
  lda [sound_local_word_0],y
  sta stream_pitch_index,x
  lda #0
  sta stream_pitch_offset,x

  ;get duty envelope index
  iny
  lda [sound_local_word_0],y
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


stream_set_volume_envelope:

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda [sound_local_word_0],y
  sta stream_volume_index,x
  lda #0
  sta stream_volume_offset,x

  rts


stream_set_pitch_envelope:

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda [sound_local_word_0],y
  sta stream_pitch_index,x
  lda #0
  sta stream_pitch_offset,x

  rts


stream_set_duty_envelope:

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda [sound_local_word_0],y
  sta stream_duty_index,x
  lda #0
  sta stream_duty_offset,x

  rts


stream_set_length:

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda [sound_local_word_0],y
  sta stream_length,x
  sta stream_frame_counter,x

  rts


;this opcode loops to the beginning of the stream. It expects the two
;following bytes to contain the address to loop to.
stream_goto:

  advance_stream_read_address
  ;load byte at read address
  lda stream_read_address_lo,x
  sta sound_local_word_0
  lda stream_read_address_hi,x
  sta sound_local_word_0+1
  ldy #0
  lda [sound_local_word_0],y
  sta stream_read_address_lo,x
  ldy #1
  lda [sound_local_word_0],y
  sta stream_read_address_hi,x

  sec
  lda stream_read_address_lo,x
  sbc #1
  sta stream_read_address_lo,x
  lda stream_read_address_hi,x
  sbc #0
  sta stream_read_address_hi,x

  rts



;this opcode returns from the parent caller by popping two bytes off
;the stack and then doing rts.
stream_terminate:

  ;set the current stream to inactive
  lda #0
  sta stream_active,x

  ;pop current address off the stack
  pla
  pla

  ;return from parent caller
  rts


;expects song_address to contain address of a song definition,
;assumed to be four addresses to initialize streams on, for square1, square2, triangle and noise.
;any addresses found to be zero will not initialize that channel.
song_initialize:

  ;save index regs
  tya
  pha
  txa
  pha

  inc sound_disable_update

  ;load square 1 stream
  ldx #0
  jsr stream_stop

  ldy #header_square1_stream_address
  lda [song_address],y
  sta sound_param_word_0
  iny
  lda [song_address],y
  beq .no_square_1
  sta sound_param_word_0+1

  lda #0
  sta sound_param_byte_0

  lda #0
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #header_tempo
  lda [song_address],y
  sta stream_tempo,x
.no_square_1:

  ;load square 2 stream
  ldx #1
  jsr stream_stop

  ldy #header_square2_stream_address
  lda [song_address],y
  sta sound_param_word_0
  iny
  lda [song_address],y
  beq .no_square_2
  sta sound_param_word_0+1

  lda #1
  sta sound_param_byte_0

  lda #1
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #header_tempo
  lda [song_address],y
  sta stream_tempo,x
.no_square_2:

  ;load triangle stream
  ldx #2
  jsr stream_stop

  ldy #header_triangle_stream_address
  lda [song_address],y
  sta sound_param_word_0
  iny
  lda [song_address],y
  beq .no_triangle
  sta sound_param_word_0+1

  lda #2
  sta sound_param_byte_0

  lda #2
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #header_tempo
  lda [song_address],y
  sta stream_tempo,x
.no_triangle:

  ;load noise stream
  ldx #3
  jsr stream_stop

  ldy #header_noise_stream_address
  lda [song_address],y
  sta sound_param_word_0
  iny
  lda [song_address],y
  beq .no_noise
  sta sound_param_word_0+1

  lda #3
  sta sound_param_byte_0

  lda #3
  sta sound_param_byte_1

  jsr stream_initialize

  ldy #header_tempo
  lda [song_address],y
  sta stream_tempo,x
.no_noise:

  ;load volume envelopes
  ldy #header_volume_envelopes_address
  lda [song_address],y
  sta song_base_address_volume_envelopes
  iny
  lda [song_address],y
  sta song_base_address_volume_envelopes+1

  ;load pitch envelopes
  ldy #header_pitch_envelopes_address
  lda [song_address],y
  sta song_base_address_pitch_envelopes
  iny
  lda [song_address],y
  sta song_base_address_pitch_envelopes+1

  ;load duty envelopes
  ldy #header_duty_envelopes_address
  lda [song_address],y
  sta song_base_address_duty_envelopes
  iny
  lda [song_address],y
  sta song_base_address_duty_envelopes+1

  dec sound_disable_update

  ;restore index regs
  pla
  tax
  pla
  tay

  rts



;expects sound_param_word_0 to contain address of a sfx defnition,
;assumed to be three addresses for volume envelopes, pitch envelopes and duty envelopes.
sfx_initialize:
sfx_address = sound_param_word_0

  ;save index regs
  tya
  pha
  txa
  pha

  inc sound_disable_update

  ;load volume envelopes
  ldy #0
  lda [sfx_address],y
  sta sfx_base_address_volume_envelopes
  iny
  lda [sfx_address],y
  sta sfx_base_address_volume_envelopes+1

  ;load pitch envelopes
  iny
  lda [sfx_address],y
  sta sfx_base_address_pitch_envelopes
  iny
  lda [sfx_address],y
  sta sfx_base_address_pitch_envelopes+1

  ;load duty envelopes
  iny
  lda [sfx_address],y
  sta sfx_base_address_duty_envelopes
  iny
  lda [sfx_address],y
  sta sfx_base_address_duty_envelopes+1

  dec sound_disable_update

  ;restore index regs
  pla
  tax
  pla
  tay

  rts



;expects sound_param_byte_0 to contain the channel on which to play the stream.
;expects sound_param_byte_1 to contain the offset of the stream instance to initialize
;expects sound_param_word_0 to contain the starting read address of the stream to
;initialize.
stream_initialize:
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
  beq .null_starting_read_address

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
.null_starting_read_address:

  dec sound_disable_update

  ;restore x
  pla
  tax

  rts


;stops a stream from playing
;assumes x contains the index of the stream to kill
stream_stop:

  inc sound_disable_update

  lda #0
  sta stream_active,x

  dec sound_disable_update

  rts



;updates a single stream
;expects x to be pointing to a stream instance as an offset from streams
stream_update:
callback_address = sound_local_word_0
read_address = sound_local_word_1

  ;load current read address of stream
  lda stream_read_address_lo,x
  sta read_address
  lda stream_read_address_hi,x
  sta read_address+1

  ;load next byte from stream data
  ldy #0
  lda [read_address],y
  sta stream_byte

  ;is this byte a note or a stream opcode?
  cmp #OPCODES_BASE
  bpl .process_opcode
.process_note:

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
  beq .do_not_advance_frame_counter

  ;decrement the frame counter. on zero, advance the stream's read address.
  dec stream_frame_counter,x
  bne .frame_counter_not_zero

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
.do_not_advance_frame_counter:
.frame_counter_not_zero:

  rts
.process_opcode:

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

indirect_jsr_callback_address:
  jmp [callback_address]
  rts



sound_initialize_apu_buffer:

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


sound_upload:

  lda apu_data_ready
  beq .apu_data_not_ready

  jsr sound_upload_apu_register_sets

.apu_data_not_ready:

  rts


;adapted from MetalSlime's Nerdy Nights sound engine
sound_upload_apu_register_sets:
.square1:
  lda apu_register_sets+0
  sta $4000
  lda apu_register_sets+1
  sta $4001
  lda apu_register_sets+2
  sta $4002
  lda apu_register_sets+3
  cmp apu_square_1_old       ;compare to last write
  beq .square2                ;don't write this frame if they were equal
  sta $4003
  sta apu_square_1_old       ;save the value we just wrote to $4003
.square2:
  lda apu_register_sets+4
  sta $4004
  lda apu_register_sets+5
  sta $4005
  lda apu_register_sets+6
  sta $4006
  lda apu_register_sets+7
  cmp apu_square_2_old
  beq .triangle
  sta $4007
  sta apu_square_2_old       ;save the value we just wrote to $4007
.triangle:
  lda apu_register_sets+8
  sta $4008
  lda apu_register_sets+10
  sta $400A
  lda apu_register_sets+11
  sta $400B
.noise:
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


;****************************************************************
;Vectors
;****************************************************************
  .bank 1
  .org $FFFA     ;first of the three vectors starts here
  .dw nmi        ;when an NMI happens (once per frame if enabled) the
                 ;processor will jump to the label NMI:
  .dw reset      ;when the processor first turns on or is reset, it will jump
                 ;to the label RESET:
  .dw irq        ;external interrupt IRQ is not used in this tutorial
