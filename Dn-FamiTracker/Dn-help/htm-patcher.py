# htm-patcher
# patches templates with pandoc converted markdown
# Copyright 2026 Persune, MIT
import argparse, pathlib

parser = argparse.ArgumentParser()
parser.add_argument("input", type=pathlib.Path)
parser.add_argument("output", type=pathlib.Path)
parser.add_argument("patch", type=pathlib.Path)
parser.add_argument("search_string", type=str)
args = parser.parse_args()

with open(args.input, mode="r", newline="\n", encoding="utf-8") as input:
    with open(args.output, mode="w", newline="\n", encoding="utf-8") as output:
        for line in input:
            if args.search_string in line:
                with open(args.patch, mode="r", newline="\n", encoding="utf-8") as patch:
                    [output.write(patches) for patches in patch]
            else:
                output.write(line)
