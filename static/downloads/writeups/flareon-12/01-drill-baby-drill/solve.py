"""Solve FLARE-On 12, task 1: Drill Baby Drill!"""

LEVEL_NAMES = ["California", "Ohio", "Death Valley", "Mexico", "The Grand Canyon"]
ENCODED = (
    "\xd0\xc7\xdf\xdb\xd4\xd0\xd4\xdc\xe3\xdb\xd1\xcd\x9f\xb5\xa7\xa7"
    "\xa0\xac\xa3\xb4\x88\xaf\xa6\xaa\xbe\xa8\xe3\xa0\xbe\xff\xb1\xbc\xb9"
)


def generate_flag_text(bear_sum: int) -> str:
    key = bear_sum >> 8
    return "".join(chr(ord(char) ^ (key + index)) for index, char in enumerate(ENCODED))


if __name__ == "__main__":
    bear_sum = 1
    for level_name in LEVEL_NAMES:
        bear_sum *= len(level_name)

    print(generate_flag_text(bear_sum))
