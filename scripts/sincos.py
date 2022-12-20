import math

sin_list = []
cos_list = []

for x in range(64):
    xx = math.pi / 128 * x
    sin_res = round(math.sin(xx) * 128)
    cos_res = round(math.cos(xx) * 128)
    sin_list.append("%02X\n" % sin_res)
    cos_list.append("%02X\n" % cos_res)

with open('sin.mem', 'w') as f:
    f.writelines(sin_list)

with open('cos.mem', 'w') as f:
    f.writelines(cos_list)