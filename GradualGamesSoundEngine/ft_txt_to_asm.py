import os
import sys

LINE_WIDTH = 64
macros = {"volume": [],
          "pitch": [],
          "duty": []}
macro_type_to_str = {0: "volume",
                     2: "pitch",
                     4: "duty"}
silent_volume_index = None
flat_pitch_index = None
instruments = []
track = {}
orders = []
patterns = []


#Splits a note string, formats the note and converts the instrument index to an integer
def process_note(note):
    split_note = note.split()
    split_note[0] = format_note(split_note[0])
    instrument_index = -1
    if split_note[1] != "..":
        instrument_index = int(split_note[1])
    split_note[1] = instrument_index
    return split_note


#Formats a note to match equates in our soundengine.
def format_note(note):
    if note != "...":
        #if third char is #, this is a noise note (which don't use the note equates,
        #they are just raw values. We must convert them by mirroring them against 15,
        #for some reason they are in reverse in famitracker versus actual values that
        #get written to 2A03 registers.
        if note[2] == "#":
            note = "$" + str(15 - int(note[0], 16))
        else:
            if note[1] == "#":
                note = note[0] + "S" + note[2]
            if note[1] == "-":
                note = note[0] + note[2]
        return note
    else:
        return None


#Returns note length in rows. Can then be multiplied by track speed to get
#STL frame count value.
def get_note_length(song_rows, channel, index):

    #starting at a note of a valid index the length is always at least 1
    note_length = 1
    i = index + 1
    if i == len(song_rows):
        return note_length
    #count the length of the note by the number of rows that do not have a note in them or the end of the song
    while i < len(song_rows) and song_rows[i][channel][0] is None:
        i += 1
        note_length += 1

    return note_length


#Generates a stream in asm format for a particular channel of a song.
#Stops short of fully formatting the stream for output to a file. Instead,
#it generates asm code for each note individually ignoring whether to start
#or end a line, or output a .byte directive, or add commas, etc. That will be
#done in a separate step.
def generate_stream(song_rows, channel):
    global silent_volume_index

    i = 0
    current_volume = None
    current_pitch = None
    current_duty = None
    current_note_length = None
    stream = []

    while True:
        note = song_rows[i][channel][0]
        instrument = song_rows[i][channel][1]
        note_length = get_note_length(song_rows, channel, i)

        volume = instruments[instrument]["volume"]
        pitch = instruments[instrument]["pitch"]
        duty = instruments[instrument]["duty"]

        note_output = []

        #If the note is none, change the note settings to use a silent volume envelope (which we output while generating
        #final asm file), and no pitch or duty envelope, and an arbitrary note. We use A0.
        if note is None:
            volume = silent_volume_index
            note = "A0"
            pitch = None
            duty = None

        if volume != -1 and volume != current_volume:
            note_output.append("STV,%s" % (volume))
            current_volume = volume

        if pitch != -1 and pitch != current_pitch:
            note_output.append("STP,%s" % (pitch))
            current_pitch = pitch

        if current_pitch is None:
            #If we get here, we know that no pitch envelope was specified for the
            #first note. Output the flat pitch index, assuming this instrument doesn't
            #modify pitch.
            note_output.append("STP,%s" % (flat_pitch_index))
            current_pitch = flat_pitch_index

        if duty != -1 and duty != current_duty:
            note_output.append("SDU,%s" % (duty))
            current_duty = duty

        if note_length != current_note_length:
            #we support notes longer than 255 by repeating the note at length 255 until we're under 255, then output
            #the note normally.
            real_note_length = note_length * track["speed"]
            if real_note_length > 255:
                note_output.append("STL,%s" % (255))
                while real_note_length > 255:
                    note_output.append(note)
                    real_note_length -= 255
            note_output.append("STL,%s" % (real_note_length))
            current_note_length = note_length

        note_output.append(note)

        stream.append(note_output)

        i += note_length
        if i == len(song_rows):
            break

    return stream


def generate_asm_from_stream(stream):

    asm = []
    current_line = "  .byte "
    for i in range(0, len(stream)):
        for note in stream[i]:
            if current_line == "  .byte ":
                current_line += note
            else:
                current_line += "," + note
            if (len(current_line) + 1) > LINE_WIDTH:
                current_line += '\n'
                asm.append(current_line)
                current_line = "  .byte "
    current_line += '\n'
    asm.append(current_line)

    return asm


def main():
    global macros
    global instruments
    global track
    global orders
    global patterns
    global silent_volume_index
    global flat_pitch_index

    if len(sys.argv) != 2:
        print("%s expects one argument: input_file" % (sys.argv[0]))

    input_file = sys.argv[1]
    output_file = os.path.splitext(input_file)[0] + ".asm"

    lines = []
    with open(input_file) as f:
        lines = f.readlines()

    #Look for MACRO, INST2A03, TRACK, COLUMNS, ORDER, PATTERN, and ROW
    current_pattern = None
    for line in lines:
        split_line = line.split()
        if len(split_line) >= 1:
            if split_line[0] == "MACRO":
                macro_split_line = line.split(":")
                type_index = macro_split_line[0].split()
                values = macro_split_line[1].split()
                macro = {}
                macro["type"] = int(type_index[1])
                macro["index"] = int(type_index[2])
                macro["values"] = [int(value) for value in values]
                macros[macro_type_to_str[macro["type"]]].append(macro)

            if split_line[0] == "INST2A03":
                inst_split_line = line.split()
                instrument = {}
                instrument["index"] = int(inst_split_line[1])
                instrument["volume"] = int(inst_split_line[2])
                instrument["pitch"] = int(inst_split_line[4])
                instrument["duty"] = int(inst_split_line[6])
                instruments.append(instrument)

            if split_line[0] == "TRACK":
                track_split_line = line.split()
                track["pattern_length"] = int(track_split_line[1])
                track["speed"] = int(track_split_line[2])
                track["tempo"] = int(track_split_line[3])

            if split_line[0] == "ORDER":
                order_split_line = line.split(":")
                order_values = [int(value) for value in order_split_line[1].split()]
                order = {}
                order["square1"] = order_values[0]
                order["square2"] = order_values[1]
                order["triangle"] = order_values[2]
                order["noise"] = order_values[3]
                orders.append(order)

            if split_line[0] == "PATTERN":
                pattern_split_line = line.split()
                pattern_index = int(pattern_split_line[1])
                current_pattern = []
                patterns.append(current_pattern)

            #relies on there being a pattern to insert rows into.
            if split_line[0] == "ROW":
                if current_pattern != None:
                    row_split_line = line.split(":")
                    row_header = row_split_line[0].split()

                    #Format the notes to match our soundengine equates
                    square1 = process_note(row_split_line[1])
                    square2 = process_note(row_split_line[2])
                    triangle = process_note(row_split_line[3])
                    noise = process_note(row_split_line[4])

                    row = {}
                    row["index"] = int(row_header[1], 16)
                    row["square1"] = square1
                    row["square2"] = square2
                    row["triangle"] = triangle
                    row["noise"] = noise
                    current_pattern.append(row)

    #At this point, we've gathered all of the exported song data and we're ready
    #to convert it to asm directives.

    #add bogus silent volume macro for silent notes. This is a workaround until we
    #implement some sort of padding or count down opcode in the sound engine.
    macro = {}
    macro["type"] = 0
    silent_volume_index = len(macros["volume"])
    macro["index"] = silent_volume_index
    macro["values"] = [0]
    macros["volume"].append(macro)

    #add default flat pitch envelope for instruments that don't specify a pitch envelope
    macro = {}
    macro["type"] = 2
    flat_pitch_index = len(macros["pitch"])
    macro["index"] = flat_pitch_index
    macro["values"] = [0]
    macros["pitch"].append(macro)

    #Compile the song to a (potentially redundant) list of rows based on orders and
    #patterns.
    song_rows = []
    for order in orders:
        for i in range(0, track["pattern_length"]):
            song_row = {}
            for channel in ["square1", "square2", "triangle", "noise"]:
                if order[channel] < len(patterns):
                    song_row[channel] = patterns[order[channel]][i][channel]
                else:
                    song_row[channel] = process_note(" ... .. . ... ")
            song_rows.append(song_row)

    #Now that we've compiled the song, we can generate the final asm file.
    with open(output_file, 'w') as f:

        #song header
        f.write("song1:\n")
        f.write("  .byte 255\n")
        for lut in ["square1", "square2", "triangle", "noise", "volume", "pitch", "duty"]:
            f.write("  .word %s\n" % (lut))
        f.write("\n")

        #envelope luts
        for env in ["volume", "pitch", "duty"]:
            #lut
            f.write(env + ":\n")
            for macro in macros[env]:
                f.write("  .word " + env + str(macro["index"]) + "\n")
            f.write("\n")

        #envelopes themselves
        for env in ["volume", "pitch"]:
            for macro in macros[env]:
                f.write(env + str(macro["index"]) + ":\n")
                f.write("  .byte ")
                for value in macro["values"]:
                    f.write(str(value) + ",")
                f.write("ENV_STOP\n")
            f.write("\n")

        #duty envelopes require special handling
        for macro in macros["duty"]:
            f.write("duty" + str(macro["index"]) + ":\n")
            f.write("  .byte ")
            for value in macro["values"]:
                #Duty cycle values are shifted into their proper bit position for ORing into
                #channel control register (used by sound engine)
                f.write(str(value << 6) + ",")
            f.write("DUTY_ENV_STOP\n")
        f.write("\n")

        #streams
        for channel in ["square1", "square2", "triangle", "noise"]:
            stream_header = channel + ":\n"
            f.write(stream_header)
            stream = generate_stream(song_rows, channel)
            asm = generate_asm_from_stream(stream)
            f.writelines(asm)
            stream_loop = "  .byte GOT\n  .word %s\n\n" % (channel)
            f.write(stream_loop)


if __name__ == '__main__':
    main()
