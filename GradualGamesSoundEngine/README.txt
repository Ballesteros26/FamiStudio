****************************************************************
*Gradual Games Sound Engine README
*by Derek Andrews <derek.george.andrews@gmail.com>
****************************************************************

****************************************************************
*INTRODUCTION
****************************************************************

I've decided to make my Sound Engine available to the public,
again. No licenses involved, feel free to use anything included
in any way you wish. I definitely appreciate credit should you
decide to use my engine. In fact, someone giving me credit
(zxdplay, the creator of StarKeeper) inspired me to make this
engine available again.

****************************************************************
*ENGINE FEATURES
****************************************************************

This SoundEngine was intended to be very simple and lightweight,
suitable for use in games. It supports volume, pitch, and duty
envelopes, which can play once or loop infinitely. It supports
playing four channels of music, no DPCM, and two channels for
sound effects. The two sound effect channels temporarily
overwrite one channel of music, and can be used together if
employed on different channels (e.g. square 1 and 2). The engine
also supports tempo, set once in the song header.

****************************************************************
*DEMO CODE
****************************************************************
I've included versions of the sound engine demo for nesasm3,
asm6, and ca65. If you're familiar with standard NES program
structure they should be pretty easy to follow. All three versions
have a handful of routines that show you how to use the engine.
Search for the following labels in soundenginedemo.asm.

here_is_how_you_initialize_everything:
how_to_play_sound_effect_one:
how_to_play_sound_effect_two:
call_this_from_end_of_vblank:

Please note, some of these routines have different names in
the CA65 version, because nesasm3 complained for some odd reason
about the longer names. The CA65 version has all demo usage code
in a file called usage.asm.

****************************************************************
*COMPILING THE DEMO
****************************************************************
Compiling the demo programs ought to be very straightforward.
Make sure you have nesasm3, asm6 or ca65 (whichever you're
going to work with) in your PATH.

For the nesasm3 version, you should only have to do:

nesasm3 soundenginedemo.asm

For asm6, it is also sinmple:

asm6 soundenginedemo.asm soundenginedemo.nes

For CA65, however, there are several modules and configuration
files. I've included a python script to automate the process,
called build.py. I wrote that script against Python 3.4.1, so
I would recommend getting Python 3.4.1 installed (it is a free
download) to use the script. Again, you need to have your PATH
pointed to CA65 so the script can call it. Just double click
on it to build it. If you want to clean the build you can call

python build.py clean

from the command line.

****************************************************************
*CONVERTER SCRIPT
****************************************************************
I've included ft_txt_to_asm.py. This is a Python program that
can convert text output from FamiTracker into a .asm file you
can use with the Sound Engine. I originally wrote it against
Python 3.4.1...so I'd recommend installing Python 3.4.1 to use
the script. To use it in Windows, all you should have to do is

1. Export your song by clicking File...Export text in FamiTracker.
2. Track the resulting .txt file to ft_txt_to_asm.py.
3. A file with the same name but with .asm at the end should appear.

You should be able to open up song36.asm (included with each of
the sound engine demos) and paste in the contents of your new .asm
file in there, and recompile the demo code and hear your song.

PLEASE NOTE: The converter script has limitations. It does not
pay any attention to any FamiTracker effects. It ignores note on
and off opcodes in envelopes. You may have to massage your envelopes
to use ENV_STOP or ENV_LOOP depending on your desires (once
exported).

ALSO: The converter expects every instrument to fully specify all
envelopes it uses, even if they are flat (like staying at one
volume, not changing pitch, etc.). Failure to do so will result
in undefined behavior.

You can use this converter to help create sound effects. Again,
the resulting song data may need to be massaged to make the data
suitable for use as a sound effect. You can experiment with the
stream opcodes manually, too.