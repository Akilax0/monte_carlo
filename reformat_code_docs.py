# TODO: list
# Delete first 2 lines
# Delete ## On lines starting with it.
# Change line above --- to ### Something
# Put > before the lines starting with ** until line starting with < or #

import os
os.chdir("docs/code/.")

for file_name in os.listdir():
    if file_name.split('.')[-1] != "md":
        continue

    arq = open(file_name, 'r')
    arq_str = arq.read()
    arq.close()

    # Delete first 2 lines
    lines = arq_str.split('\n')[2:]
    blocking = False

    for ind, line in enumerate(lines):
        if line == "" or line == " ":
            continue
        # Put > before the lines starting with ** until line starting with < or #
        if blocking:
            if line[0] != "<" and line[0] != "#":
                lines[ind] = ">" + line
            else:
                blocking = False

        # Delete ## On lines starting with it.
        if line[:2] == "##":
            lines[ind] = line[2:]
        # Put > before the lines starting with ** until line starting with < or #
        elif line[:2] == "**":
            lines[ind] = ">" + line
            blocking = True
        # Change line above -- to ### Something
        elif line[:2] == "--":
            lines[ind-1] = "### " + lines[ind-1]
            lines[ind] = ""

    arq = open(file_name, 'w')
    arq.write('\n'.join(lines))
