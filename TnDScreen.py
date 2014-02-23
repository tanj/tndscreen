import sys
import re
from struct import *

import pprint

import pdb as debug

class Screen:
    def __init__(self, file_name):
        self.scr = []
        self.bom = '\xff\xfe' # bom in utf-16-le
        line = []
        with open(file_name, 'rb') as fn:
            f = fn.read()
            self.scr = f.split('\r\x00\n\x00')

    def findall(self, pattern):
        ixs = []
        for i, line in enumerate(self.scr):
            ix = [m.start() for m in re.finditer(pattern, line)]
            if len(ix) > 0:
                ixs.append((i,ix))
        return ixs

    def splitall(self, pattern):
        sp = []
        for line in self.scr:
            s = line.split(pattern)
            sp.append(s)
        return sp

    def typeall(self):
        self.typed = []
        self.gtype = {}
        for line in self.scr:
            typeline = []
            for part in line.split(self.bom):
                t = None
                v = None
                try:
                    if part[0] == '\xff':
                        t = part[:2]
                        try:
                            v = unicode(part[2:], 'utf-16-le')
                        except:
                            v = part[2:]
                        typeline.append((t,v))
                        if self.gtype.has_key(t):
                            self.gtype[t].append(v)
                        else:
                            self.gtype.update({t : [v]})
                    else:
                        try:
                            v = unicode(part, 'utf-16-le')
                        except:
                            v = part
                        typeline.append((t,v))
                        if self.gtype.has_key(t):
                            self.gtype[t].append(v)
                        else:
                            self.gtype.update({t : [v]})
                except:
                    print repr(part)
            self.typed.append(typeline)

        
# DC1 (\x13) seems to break scr[1] between unicode data and header
# Seeing a lot of \xfe\xff\xff around 
# \xfe\ff is BOM
# 
# Text is encoded utf-16-le (little endian)

# We have some illegal characters coming up with \xDE.  Code points
# U+D800 to U+DFFF are reserved for encoding lead and trail
# surrogates.  Might be able to isolate these areas by splitting the
# sections up using the BOMs scattered through out.


def findtot(findres):
    c = 0
    for f in findres:
        c = c + len(f[1])
    return c

def get_types(splitline):
    new = []
    for p in splitline:
        t = p[:2]
        v = None
        try:
            v = unicode(p[2:], 'utf-16-le')
        except:
            v = p[2:]
        new.append((t,v))

    return new

def pp(flname, obj):
    with open(flname, 'wb') as fl:
        p = pprint.PrettyPrinter(indent=4, stream=fl)
        p.pprint(obj)
