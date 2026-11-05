# -*- coding: utf-8 -*-
"""Generate a Fluent UI v9 BrandVariants ramp (16 stops) from a seed colour,
   using CIE Lab/LCH so the steps are perceptually even and in-gamut."""
import math, json

def srgb_to_lin(c):
    c = c/255.0
    return c/12.92 if c <= 0.04045 else ((c+0.055)/1.055)**2.4

def lin_to_srgb(c):
    v = 12.92*c if c <= 0.0031308 else 1.055*(c**(1/2.4))-0.055
    return max(0.0, min(1.0, v))*255.0

M  = [[0.4124564,0.3575761,0.1804375],
      [0.2126729,0.7151522,0.0721750],
      [0.0193339,0.1191920,0.9503041]]
MI = [[ 3.2404542,-1.5371385,-0.4985314],
      [-0.9692660, 1.8760108, 0.0415560],
      [ 0.0556434,-0.2040259, 1.0572252]]
WP = (0.95047, 1.00000, 1.08883)

def rgb_to_xyz(r,g,b):
    R,G,B = srgb_to_lin(r), srgb_to_lin(g), srgb_to_lin(b)
    return [sum(M[i][j]*[R,G,B][j] for j in range(3)) for i in range(3)]

def xyz_to_rgb(x,y,z):
    v = [sum(MI[i][j]*[x,y,z][j] for j in range(3)) for i in range(3)]
    return [lin_to_srgb(c) for c in v]

def f(t):  return t**(1/3) if t > 216/24389 else (841/108)*t + 4/29
def fi(t): return t**3 if t**3 > 216/24389 else (t-4/29)*108/841

def rgb_to_lab(r,g,b):
    x,y,z = rgb_to_xyz(r,g,b)
    fx,fy,fz = f(x/WP[0]), f(y/WP[1]), f(z/WP[2])
    return 116*fy-16, 500*(fx-fy), 200*(fy-fz)

def lab_to_rgb(L,a,bb):
    fy = (L+16)/116; fx = fy + a/500; fz = fy - bb/200
    return xyz_to_rgb(fi(fx)*WP[0], fi(fy)*WP[1], fi(fz)*WP[2])

def lab_to_lch(L,a,b):
    return L, math.hypot(a,b), math.degrees(math.atan2(b,a)) % 360

def lch_to_lab(L,C,h):
    r = math.radians(h); return L, C*math.cos(r), C*math.sin(r)

def in_gamut(rgb, eps=0.35):
    return all(-eps <= c <= 255+eps for c in rgb)

def lch_to_hex(L,C,h):
    # reduce chroma until the colour fits inside sRGB
    c = C
    for _ in range(220):
        rgb = lab_to_rgb(*lch_to_lab(L,c,h))
        if in_gamut(rgb): break
        c *= 0.985
    rgb = [int(round(max(0,min(255,v)))) for v in lab_to_rgb(*lch_to_lab(L,c,h))]
    return "#%02X%02X%02X" % tuple(rgb)

def hex_to_rgb(hx):
    hx = hx.lstrip('#')
    return tuple(int(hx[i:i+2],16) for i in (0,2,4))

SHADES = [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160]

def build(seed_hex, primary_shade=80):
    r,g,b = hex_to_rgb(seed_hex)
    L0,C0,H0 = lab_to_lch(*rgb_to_lab(r,g,b))
    i0 = SHADES.index(primary_shade)
    # perceptual lightness targets, anchored on the seed at the primary stop
    lo, hi = 12.0, 97.5
    n = len(SHADES)
    Ls = []
    for i in range(n):
        if i <= i0:  t = i/i0;             Ls.append(lo + (L0-lo)*(t**0.92))
        else:        t = (i-i0)/(n-1-i0);  Ls.append(L0 + (hi-L0)*(t**1.06))
    out = {}
    for i,sh in enumerate(SHADES):
        L = Ls[i]
        # chroma falls off toward both ends so the ramp stays in gamut and calm
        if L >= L0:
            t = (L - L0) / (hi - L0)
            # tints: pull chroma down hard and swing the hue off orange
            C = C0 * (1.0 - 0.80*(t**1.02))
            Hs = H0 - 11.0*(t**0.85)
        else:
            t = (L0 - L) / (L0 - lo)
            C = C0 * (1.0 - 0.34*(t**1.45))
            Hs = H0 + 2.5*(t**1.2)
        if i == i0:
            out[sh] = seed_hex.upper()
        else:
            out[sh] = lch_to_hex(L, C, Hs)
    return out, (L0,C0,H0)

if __name__ == "__main__":
    ramp, lch = build("#DB2323")
    print("seed LCH: L*=%.2f C*=%.2f h=%.2f" % lch)
    for k,v in ramp.items(): print(f"  {k:>3}: {v}")
    json.dump(ramp, open('/mnt/workspace/working/bk/ramp.json','w'), indent=2)
