#!/bin/python3

import sys

def hue(v1, v2, vH):
    if vH < 0.0:
        vH += 1.0
    if vH > 1.0: 
        vH -= 1.0

    if (6.0 * vH) < 1.0:
        return v1 + (v2 - v1) * 6.0 * vH
    if (2.0 * vH) < 1.0:
        return v2
    if (3.0 * vH) < 2.0:
        return v1 + (v2 - v1) * ((2.0/3.0) - vH) * 6.0
    else:
        return v1

def hsl2rgb(h, s, l):
    h = h/360
    s = s/100
    l = l/100
        
    r = 0
    g = 0
    b = 0
    v1 = 0
    v2 = 0

    if s == 0:
        r = l * 255
        g = l * 255
        b = l * 255
    else:
        if l < 0.5:
            v2 = l * (1.0 + s)
        else:
            v2 = (l + s) - (s * l)

        v1 = 2.0 * l - v2

        r = 255 * hue(v1, v2, h + (1.0/3.0))
        g = 255 * hue(v1, v2, h)
        b = 255 * hue(v1, v2, h - (1.0/3.0))
    
    return r, g, b

if __name__ == "__main__":
    if len(sys.argv) < 4:
        exit(1)

    try:
        h = int(sys.argv[1])
    except ValueError:
        exit(1)

    if h < 0 or h > 360:
        exit(1)

    try:
        s = int(sys.argv[2])
    except ValueError:
        exit(1)

    if s < 0 or s > 100:
        exit(1)

    try: 
        v = int(sys.argv[3])
    except ValueError:
        exit(1)

    if s < 0 or s > 100:
        exit(1)

    r, g, b = hsl2rgb(h, s, v)

    r = round(r)
    g = round(g)
    b = round(b)

    hexcode = "{0:02X}{1:02X}{2:02X}".format(r, g, b)
    print(hexcode)
