import os
import sys
from PIL import Image

input_file = sys.argv[1]
base_name = os.path.splitext(input_file)[0]

palette_file = sys.argv[2]

# 1 pixel -> 4 bits
# 1 color -> 16 bits RGB 565

# load source image
source_img = Image.open(input_file)
(width, height) = source_img.size

dest_img = []
color_palette = []
color_index = {}

with open(palette_file, 'r') as f:
    for line in f:
        this_rgb = int(line, 16)
        this_index = len(color_palette)
        color_palette.append(this_rgb)
        color_index[this_rgb] = this_index


# Go through all pixels and generate color palette
for x in range(width):
    for y in reversed(range(height)):
        this_rgba = source_img.getpixel((x, y))
        # check transparent pixel
        if len(this_rgba) == 4 and this_rgba[3] == 0:
            this_index = 0
        else:
            this_rgb = this_rgba[0:3]
            color_r5 = this_rgb[0] >> 3
            color_g6 = this_rgb[1] >> 2
            color_b5 = this_rgb[2] >> 3
            color_rgb565 = (color_r5 << 11) + (color_g6 << 5) + color_b5
            if color_rgb565 in color_index:
                this_index = color_index[color_rgb565]
            else:
                print("ERROR: palette not fit.")
                exit(1)
        dest_img.append(this_index)

# Generate hex image output for mem
img_mem = ["%X\n" % d for d in dest_img]
with open(base_name + '.mem', 'w') as f:
    f.writelines(img_mem)

# Generate hex image output for mi
# img_mi_header = []
# img_mi_header.append("#File_format=Hex\n")
# img_mi_header.append("#Address_depth=%d\n" % len(dest_img))
# img_mi_header.append("#Data_width=4\n")
# with open(base_name + '.mi', 'w') as f:
#     f.writelines(img_mi_header)
#     f.writelines(img_mem)
