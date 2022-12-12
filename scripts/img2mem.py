import os
import sys
from PIL import Image

input_file = sys.argv[1]
base_name = os.path.splitext(input_file)[0]

# 1 pixel -> 4 bits
# 1 color -> 16 bits RGB 565

# load source image
source_img = Image.open(input_file)
(width, height) = source_img.size

dest_img = []
color_palette = [(255, 255, 255)]
color_index = {}

# Go through all pixels and generate color palette
for x in range(width):
    for y in reversed(range(height)):
        this_rgba = source_img.getpixel((x, y))
        # check transparent pixel
        if len(this_rgba) == 4 and this_rgba[3] == 0:
            this_index = 0
        else:
            this_rgb = this_rgba[0:3]
            if this_rgb in color_index:
                this_index = color_index[this_rgb]
            else:
                this_index = len(color_palette)
                color_palette.append(this_rgb)
                color_index[this_rgb] = this_index
        dest_img.append(this_index)

# Generate hex image output for mem
mem_output = ["%X\n" % d for d in dest_img]
with open(base_name + '.mem', 'w') as f:
    f.writelines(mem_output)

# Generate hex image output for mi
mi_header = []
mi_header.append("#File_format=Hex\n")
mi_header.append("#Address_depth=%d\n" % len(dest_img))
mi_header.append("#Data_width=4\n")
with open(base_name + '.mi', 'w') as f:
    f.writelines(mi_header)
    f.writelines(mem_output)

# Gererate hex color palette
palette_output = []
for one_color in color_palette:
    color_r5 = one_color[0] >> 3
    color_g6 = one_color[1] >> 2
    color_b5 = one_color[2] >> 3
    color_rgb565 = (color_r5 << 11) + (color_g6 << 5) + color_b5
    palette_output.append("%4X\n" % color_rgb565)

with open(base_name + '_palette.mem', 'w') as f:
    f.writelines(palette_output)
