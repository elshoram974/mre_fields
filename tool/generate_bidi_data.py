"""Regenerate the pinned Unicode direction table.

Download https://www.unicode.org/Public/17.0.0/ucd/extracted/DerivedBidiClass.txt
and run: python3 tool/generate_bidi_data.py /path/to/DerivedBidiClass.txt
No network access or Unicode dependency is needed at package runtime.
"""
from pathlib import Path
import re
import sys

source = Path(sys.argv[1]).read_text()
if not source.startswith("# DerivedBidiClass-17.0.0.txt"):
    raise ValueError("Expected Unicode 17.0.0 DerivedBidiClass.txt")

# Apply @missing defaults first, then explicit properties. All classes other
# than L/R/AL become zero; malformed UTF-16 halves are deliberately neutral.
values = bytearray([1]) * 0x110000
classes = {"L": 1, "R": 2, "AL": 2,
           "Left_To_Right": 1, "Right_To_Left": 2, "Arabic_Letter": 2}
patterns = [r"^# @missing: ([0-9A-F.]+); (\w+)",
            r"^([0-9A-F.]+)\s*; (\w+)"]
for pattern in patterns:
    for match in re.finditer(pattern, source, re.M):
        parts = match[1].split("..")
        start, end = int(parts[0], 16), int(parts[-1], 16)
        values[start:end + 1] = bytes([classes.get(match[2], 0)]) * (end - start + 1)
values[0xD800:0xE000] = bytes(0x800)

ranges = []
start = 0
for index in range(1, len(values) + 1):
    if index == len(values) or values[index] != values[start]:
        if values[start]:
            ranges.append((start, index - 1, values[start]))
        start = index

header = """// Generated from Unicode 17.0.0 DerivedBidiClass.txt; do not hand edit.
// Source: https://www.unicode.org/Public/17.0.0/ucd/extracted/DerivedBidiClass.txt
// Copyright Unicode, Inc. Distributed under the Unicode License v3.
// See UNICODE-LICENSE.txt. Regenerate with tool/generate_bidi_data.py.
import 'package:meta/meta.dart';

/// Unicode Bidi_Class: 1 = L, 2 = R/AL, 0 = other or malformed UTF-16.
@internal
int mreStrongBidiClass(int rune) {
  var low = 0;
  var high = _ranges.length ~/ 3 - 1;
  while (low <= high) {
    final middle = (low + high) ~/ 2;
    final offset = middle * 3;
    if (rune < _ranges[offset]) {
      high = middle - 1;
    } else if (rune > _ranges[offset + 1]) {
      low = middle + 1;
    } else {
      return _ranges[offset + 2];
    }
  }
  return 0;
}

// dart format off
const _ranges = <int>[
"""

lines = [
    "  " + " ".join(f"0x{start:X}, 0x{end:X}, {kind},"
                    for start, end, kind in ranges[index:index + 4])
    for index in range(0, len(ranges), 4)
]
Path("lib/src/text/direction/mre_bidi_data.dart").write_text(
    header + "\n".join(lines) + "\n];\n// dart format on\n"
)
