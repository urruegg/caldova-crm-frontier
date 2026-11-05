# -*- coding: utf-8 -*-
"""Illustrative warm neutral ramp adapted from legacy reference anchor
   #484445 and paper tones; not approved Caldova corporate identity."""
import json
from ramp import rgb_to_lab, lab_to_lch, lch_to_hex, hex_to_rgb

def contrast(h1, h2):
    def lum(hx):
        r,g,b = hex_to_rgb(hx)
        def ch(c):
            c/=255.0
            return c/12.92 if c<=0.03928 else ((c+0.055)/1.055)**2.4
        return 0.2126*ch(r)+0.7152*ch(g)+0.0722*ch(b)
    a,b = lum(h1), lum(h2)
    hi,lo = max(a,b), min(a,b)
    return (hi+0.05)/(lo+0.05)

STOPS = [2,4,6,8,10,12,16,20,24,28,32,36,38,40,44,48,52,56,60,68,76,84,88,92,94,96,98]

if __name__ == "__main__":
    L0,C0,H0 = lab_to_lch(*rgb_to_lab(*hex_to_rgb("#484445")))
    print("neutral seed #484445 -> L*=%.2f C*=%.2f h=%.1f" % (L0,C0,H0))
    # warm, very low chroma; slightly warmer in the light range (paper tones)
    ramp = {}
    for s in STOPS:
        L = s
        # retained legacy reference measurements: papers sit at h≈91° (warm
        # ochre), mid/dark neutrals are near-achromatic with a faint warm cast
        if L >= 84:
            C = 0.85 + 2.30*((L-84)/14.0)**0.55
            C = min(C, 3.10)
            h = 91.0
        elif L >= 55:
            C = 0.55 + 1.10*((L-55)/29.0)
            h = 94.0
        else:
            C = 0.55 + 1.35*(1.0-(L/55.0))**1.2
            h = 20.0
        ramp[s] = lch_to_hex(L, C, h)
    for k,v in ramp.items(): print(f"  {k:>3}: {v}   on-white {contrast(v,'#FFFFFF'):.2f}")
    json.dump(ramp, open('neutrals.json','w'), indent=2)

    print("\nBRAND CONTRAST CHECK (vs #FFFFFF / vs #171717)")
    br = json.load(open('ramp.json'))
    for k,v in br.items():
        print(f"  {k:>3}: {v}  white {contrast(v,'#FFFFFF'):5.2f}   ink {contrast(v,'#171717'):5.2f}")
