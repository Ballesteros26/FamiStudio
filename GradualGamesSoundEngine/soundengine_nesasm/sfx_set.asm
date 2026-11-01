sfx_volume_envelope_silence:
  .byte 0, ENV_STOP

sfx_volume_envelope_loud:
  .byte 15, ENV_STOP

;used for hit
sfx_volume_envelope_2:
  .byte 14, 12, 11, 9, 7, 6, 4, 2, 1, 0, 0, ENV_STOP

;used for door slam
sfx_volume_envelope_3:
  .byte 10,7,5,4,0,ENV_STOP

;used for flapping
sfx_volume_envelope_4:
  .byte 3,5,9,12,13,10,6,3,5,7,8,9,8,6,0,ENV_LOOP

;used for sword
sfx_volume_envelope_5:
  .byte 3,4,6,9,9,0,ENV_STOP

;used for explosion
sfx_volume_envelope_6:
  .byte 15,10,6,2,0,0,ENV_STOP

;used for text
sfx_volume_envelope_7:
  .byte 3,1,0,ENV_STOP

;used for key
sfx_volume_envelope_8:
  .byte 10,7,3,0,ENV_STOP

;used for cursor
sfx_volume_envelope_9:
  .byte 11,6,1,0,0,ENV_STOP

;used for selecting something either in inventory screen or
;alternating between tech 1 and tech 2
sfx_volume_envelope_10:
  .byte 14,11,8,5,2,0,ENV_STOP

;used for entering or leaving inventory screen
sfx_volume_envelope_11:
  .byte 2,3,5,7,8,10,12,0,ENV_STOP

;used for error
sfx_volume_envelope_12:
  .byte 12,10,9,8,6,2,ENV_STOP

;used for hit
sfx_volume_envelope_13:
  .byte 15,6,10,15,9,2,0,ENV_STOP

;used for door slam
sfx_volume_envelope_14:
  .byte 9,8,7,5,4,3,2,1,1,0,0,0,0,0,0,0,ENV_STOP

;used for door slam
sfx_volume_envelope_15:
  .byte 0,1,1,1,1,2,2,3,3,4,5,6,8,10,13,15,ENV_STOP

;used for monolith slam
sfx_volume_envelope_16:
  .byte 2,3,3,4,5,6,6,8,9,9,0,15,14,12,9,6,4,3,2,2,1,1,1,0,ENV_STOP

sfx_pitch_envelope_0:
  .byte 0, ENV_LOOP

sfx_pitch_envelope_1:
  .byte 0, 1, 2, 3, 4, 5, 4, 3, 2, 1, -1, -2, -3, -4, -5, ENV_LOOP

sfx_duty_envelope_0:
  .byte 0, DUTY_ENV_STOP
sfx_duty_envelope_1:
  .byte -128,DUTY_ENV_LOOP

sfx_volume_envelopes:
  .word sfx_volume_envelope_silence
  .word sfx_volume_envelope_loud
  .word sfx_volume_envelope_2
  .word sfx_volume_envelope_3
  .word sfx_volume_envelope_4
  .word sfx_volume_envelope_5
  .word sfx_volume_envelope_6
  .word sfx_volume_envelope_7
  .word sfx_volume_envelope_8
  .word sfx_volume_envelope_9
  .word sfx_volume_envelope_10
  .word sfx_volume_envelope_11
  .word sfx_volume_envelope_12
  .word sfx_volume_envelope_13
  .word sfx_volume_envelope_14
  .word sfx_volume_envelope_15
  .word sfx_volume_envelope_16

sfx_pitch_envelopes:
  .word sfx_pitch_envelope_0
  .word sfx_pitch_envelope_1

sfx_duty_envelopes:
  .word sfx_duty_envelope_0
  .word sfx_duty_envelope_1

sfx_set1:
  .word sfx_volume_envelopes
  .word sfx_pitch_envelopes
  .word sfx_duty_envelopes

sfx_test:
  .byte STV,2, STP, 0, SDU, 0, STL, 50, 5
  .byte TRM

sfx_hit:
  .byte STV,13,STP,0,SDU,0,STL,20,8
  .byte TRM

sfx_sword:
  .byte STV,5,STP,0,SDU,0,STL,6,8
  .byte TRM

sfx_door:
  .byte STV,3,STP,0,SDU,0,STL,6,10,15
  .byte TRM

sfx_flap:
  .byte STV,4,STP,0,SDU,0,STL,45,9
  .byte TRM

sfx_explosion:
  .byte STV,6,STP,0,SDU,0,STL,2,3,4,6,8,10,11,STL,6,13
  .byte TRM

sfx_text:
  .byte STV,7,STP,0,SDU,0,STL,3,F4
  .byte TRM

sfx_get_item:
  .byte STV,8,STP,0,SDU,1,STL,3,D6,A6,STV,0,D6
  .byte TRM

sfx_move_cursor:
  .byte STV,9,STP,0,SDU,0,STL,5,11
  .byte TRM

sfx_select:
  .byte STV,10,STP,0,SDU,1,STL,2,GS3,GS4,GS5
  .byte TRM

sfx_inventory:
  .byte STV,11,STP,0,SDU,1,STL,6,G4,G3,G2,G1,G2,G3
  .byte TRM

sfx_error:
  .byte STV,12,STP,0,SDU,0,STL,4,B1,F1
  .byte TRM

sfx_door_slam:
  .byte STV,15,STP,0,SDU,0,STL,12,11,STV,14,STL,6,10,STL,6,15
  .byte TRM

sfx_monolith_slam:
  .byte STV,16,STP,0,SDU,0,STL,24,15
  .byte TRM
