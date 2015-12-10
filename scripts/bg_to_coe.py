from PIL import Image

bg = Image.open("bg_poster.png")
w, h = bg.size

to_12bit = lambda pixel: tuple([int(band/16) for band in pixel])
to_24bit = lambda pixel: tuple([band*16 for band in pixel])

last_pixel = to_12bit(bg.getpixel((0,0)))
run_table = []
color_idx_table = []
colors = {last_pixel: 0}
color_table = [last_pixel]
current_run = 0

for y in xrange(h):
    for x in xrange(w):
        pixel = bg.getpixel((x,y))
        pixel = to_12bit(pixel)
        if pixel == last_pixel and current_run < 4:
            current_run += 1;
        else:
            run_table.append(current_run)
            current_run = 1
            color_idx_table.append(colors[last_pixel])
            if pixel not in colors:
                color_table.append(pixel)
                colors[pixel] = len(color_table) - 1
        last_pixel = pixel

run_table.append(current_run)
color_idx_table.append(colors[last_pixel])

n_runs = len(run_table)
n_colors = len(color_table)
print n_runs, n_colors

bgx = Image.new("RGB", (w,h))
run_table.append(0)
HEAD = 0
run_left = run_table[HEAD]

for y in xrange(h):
    for x in xrange(w):
        pixel = color_table[color_idx_table[HEAD]]
        pixel = to_24bit(pixel)
        bgx.putpixel((x,y),pixel)
        run_left -= 1
        if run_left == 0:
            HEAD += 1
            run_left = run_table[HEAD]

#bgx.show()
COE_HEADER = """memory_initialization_radix=10;
memory_initialization_vector=
"""

RUN_LOCATION = "bg_run_table.coe"
COLOR_LOCATION = "bg_color_table.coe"
with open(RUN_LOCATION, "w") as coe:
    coe.write(COE_HEADER)
    for i in xrange(n_runs):
        run = run_table[i]-1
        color_index = color_idx_table[i]
        val = (run << 4) + color_index
        coe.write(str(val))
        if i == n_runs-1: coe.write(";")
        else: coe.write(",\n")

with open(COLOR_LOCATION, "w") as coe:
    coe.write(COE_HEADER)
    for i in color_table[:-1]:
        coe.write(str((i[0]<<8)+(i[1]<<4)+i[2]))
        coe.write(",\n")
    coe.write(str((i[0]<<8)+(i[1]<<4)+i[2]))
    coe.write(";")