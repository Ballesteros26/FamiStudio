.ifndef SOUNDENGINE_INC
SOUNDENGINE_INC = 1

.globalzp sound_disable_update
.globalzp apu_data_ready
.globalzp apu_square_1_old
.globalzp apu_square_2_old
.globalzp sound_param_byte_0
.globalzp sound_param_byte_1
.globalzp sound_param_byte_2
.globalzp sound_param_word_0
.globalzp sound_param_word_1
.globalzp sound_param_word_2
.globalzp base_address_volume_envelopes
.globalzp base_address_pitch_envelopes
.globalzp base_address_duty_envelopes
.globalzp stream_byte
.globalzp song_address

;these are base addresses for song streams (first four streams)
.global song_base_address_volume_envelopes
.global song_base_address_pitch_envelopes
.global song_base_address_duty_envelopes

;these are base addresses for sfx streams (all streams after the first four)
.global sfx_base_address_volume_envelopes
.global sfx_base_address_pitch_envelopes
.global sfx_base_address_duty_envelopes

;this does not need to be exposed, but it is convenient for pseudo random number seeding, since
;it is always moving even when the hero is not. Just hope we'll be careful with it ;)
.global stream_read_address_lo

.global sound_initialize
.global sound_stop
.global sound_update
.global sound_upload
.global song_initialize
.global sfx_initialize
.global stream_initialize
.global stream_stop
.global stream_update

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

.struct song_header
  tempo .byte
  square1_stream_address .word
  square2_stream_address .word
  triangle_stream_address .word
  noise_stream_address .word
  volume_envelopes_address .word
  pitch_envelopes_address .word
  duty_envelopes_address .word
.endstruct

.macro advance_stream_read_address

  clc
  lda stream_read_address_lo,x
  adc #1
  sta stream_read_address_lo,x
  lda stream_read_address_hi,x
  adc #0
  sta stream_read_address_hi,x

.endmacro

;this macro updates the sound engine safely. It is intended to
;be used at the end of an nmi routine, after ppu synchronization.
.macro safe_soundengine_update

  lda sound_disable_update
  bne sound_update_disabled
  ;;switch to music bank
  ;ldy music_bank
  ;lda bank_table,y
  ;sta bank_table,y

  jsr sound_update
  jsr sound_upload

  ;;switch back to whatever current bank was before nmi
  ;ldy current_bank
  ;lda bank_table,y
  ;sta bank_table,y
sound_update_disabled:

.endmacro

.endif
