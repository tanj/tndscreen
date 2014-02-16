import sys
import re
import codecs

class Screen:
    def __init__(self, file_name):
        self.scr = []
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

        
