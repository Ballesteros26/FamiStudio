.feature force_range
.include "usage.inc"
.include "soundengine.inc"
.include "ppu.inc"
.include "zp.inc"

.segment "CODE"

.include "song36.asm"
.include "sfx_set.asm"

.proc here_is_how_you_initialize_everything

  ;initialize modules
  jsr sound_initialize

  ;load sfx set
  lda #<sfx_set1
  sta sound_param_word_0
  lda #>sfx_set1
  sta sound_param_word_0+1
  jsr sfx_initialize

  ;load a song
  lda #<song1
  sta song_address
  lda #>song1
  sta song_address+1
  jsr song_initialize

  rts

.endproc

.proc here_is_how_to_play_sound_effect_one

  ;this parameter is the address of the sound effect you wish
  ;to play.
  lda #<sfx_select
  sta sound_param_word_0
  lda #>sfx_select
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

.endproc

.proc here_is_how_to_play_sound_effect_two

  lda #<sfx_inventory
  sta sound_param_word_0
  lda #>sfx_inventory
  sta sound_param_word_0+1

  lda #0
  sta sound_param_byte_0
  lda #soundeffect_two
  sta sound_param_byte_1

  jsr stream_initialize

  rts

.endproc

.proc call_this_from_end_of_vblank

  ;turn on monochrome color while the sound engine runs
  set_ppu_2001_bit PPU1_DISPLAY_TYPE
  upload_ppu_2001

  ;update the sound engine. This should always be done at the
  ;end of vblank, this way it is always running at the same speed
  ;even if your game slows down. This macro originally had some
  ;bankswitching code in it from my game engine, hence the name "safe."
  safe_soundengine_update

  ;turn off monochrome color now that the sound engine is
  ;done. You should see a nice gray bar that shows how much
  ;cpu time the sound engine is using.
  clear_ppu_2001_bit PPU1_DISPLAY_TYPE
  upload_ppu_2001

  rts

.endproc