song1:
  .byte 255
  .word Square1
  .word Square2
  .word Triangle
  .word Noise
  .word volume_envelopes
  .word pitch_envelopes
  .word duty_envelopes

volume_envelopes:
  .word volume_envelope_0
  .word volume_envelope_1
  .word volume_envelope_2
  .word volume_envelope_3
  .word volume_envelope_4
  .word volume_envelope_5
  .word volume_envelope_6

pitch_envelopes:
  .word pitch_envelope_0
  .word pitch_envelope_1

duty_envelopes:
  .word duty_envelope_0
  .word duty_envelope_1
  .word duty_envelope_2

volume_envelope_0:
  .byte 0, ENV_STOP
volume_envelope_1:
  .byte 4,4,4,4,4,0,ENV_STOP
volume_envelope_2:
  .byte 10,9,8,7,6,5,4,4,3,3,3,2,1,1,1,0,ENV_STOP
volume_envelope_3:
  .byte 0,1,2,3,4,4,4,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2
  .byte 2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,ENV_STOP
volume_envelope_4:
  .byte 3,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,4,4,4,4,3,ENV_STOP
volume_envelope_5:
  .byte 7,5,2,0,ENV_STOP
volume_envelope_6:
  .byte 1,2,2,2,2,2,2,2,2,ENV_STOP

pitch_envelope_0:
  .byte 0, ENV_LOOP
pitch_envelope_1:
  .byte 0,0,0,0,0,0,0,0,0,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1
  .byte -1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1
  .byte 1,-1,-1,-1,-1,1,1,ENV_STOP

duty_envelope_0:
  .byte 0, DUTY_ENV_STOP
duty_envelope_1:
  .byte 128,DUTY_ENV_STOP
duty_envelope_2:
  .byte 192,DUTY_ENV_STOP

Square1:
  .byte STV,3,STP,1,SDU,2,STL,28,CS3,STL,14,CS2,GS2,STL,42,B2,STL,14,DS3,STL,28,E3
  .byte STL,14,DS3,STL,7,E3,DS3,STL,56,CS3,STL,84,CS3,STL,14,FS3,DS3,STL,84,E3,STL,28
  .byte E3,CS3,STL,14,CS2,GS2,STL,42,B2,STL,14,DS3,STL,28,E3,STL,14,DS3,STL,7,E3,DS3
  .byte STL,56,CS3,STL,84,CS3,STL,28,B2,CS3,AS2,GS2,FS2,STL,70,E2,STL,14,DS2,E2,DS2
  .byte STL,70,E2,STL,14,GS2,AS2,STL,7,B2,FS2,STL,70,E2,STL,14,DS2,E2,DS2,STL,70,E2
  .byte STL,14,GS2,AS2,STL,7,B2,FS2,STL,70,E3,STL,14,E3,DS3,B2,STL,70,E3,STL,14,E3
  .byte AS3,B3,STL,28,GS3,AS3,B3,CS4,E4,DS4,CS4,B3
  .byte GOT
  .word Square1
Square2:
  .byte STV,3,STP,1,SDU,2,STL,28,CS4,CS3,STL,56,GS3,STL,28,B3,AS3,GS3,FS3,STL,84,GS3
  .byte STL,14,AS3,FS3,STL,84,GS3,STL,28,GS3,E4,E3,STL,56,DS4,STL,28,CS4,STL,14,B3
  .byte STL,7,CS4,B3,STL,28,AS3,FS3,STL,84,GS3,STL,14,FS3,CS3,STL,28,GS3,FS3,E3,DS3
  .byte STL,70,GS2,STL,14,FS2,GS2,FS2,STL,28,GS2,AS2,B2,CS3,STL,70,GS2,STL,14,FS2
  .byte GS2,FS2,STL,28,GS2,AS2,B2,CS3,STL,70,CS3,STL,14,CS3,B2,GS2,STL,70,CS3,STL,14
  .byte GS3,CS4,DS4,STL,28,B3,FS3,E3,DS3,E3,DS3,CS3,DS3
  .byte GOT
  .word Square2
Triangle:
  .byte STV,1,STP,0,SDU,1,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28
  .byte CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28
  .byte CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28
  .byte CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28
  .byte CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28
  .byte CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,E2,STL,14,E2,E2,STL,28
  .byte E2,STL,14,E2,STL,7,E2,E2,STL,28,E2,STL,14,E2,E2,STL,28,E2,STL,14,E2,STL,7
  .byte E2,E2,STL,28,E2,STL,14,E2,E2,STL,28,E2,STL,14,E2,STL,7,E2,E2,STL,28,E2,STL,14
  .byte E2,E2,STL,28,E2,STL,14,E2,STL,7,E2,E2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2
  .byte STL,14,CS2,STL,7,CS2,CS2,STL,28,CS2,STL,14,CS2,CS2,STL,28,CS2,STL,14,CS2,STL,7
  .byte CS2,CS2,STL,28,GS2,FS2,E2,DS2,E2,DS2,CS2,B1
  .byte GOT
  .word Triangle
Noise:
  .byte STV,5,STP,0,SDU,0,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14,4,4,STL,28,4,STL,14
  .byte 4,4,STL,28,4,STL,14,4,4
  .byte GOT
  .word Noise
