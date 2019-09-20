import sys

#todo:check for arguments
f = open(sys.argv[1], "r")
fo = open(sys.argv[2], "w")

line = f.readline()

while line:
    
    (firstWord, rest) = line.split(maxsplit=1)
    if firstWord != "sym":
        line = f.readline()
        continue

    ldict = {}
    for elem in rest[:-1].replace('"', "").split(","):
        key = elem.split("=")[0]
        value = elem.split("=")[1]
        ldict[key] = value

    #print(ldict)
    if ldict['type'] == 'lab' and ldict['seg'] == '0':
        fo.write('$' + ldict['val'][2:] + "#" + ldict['name'] + "#\n")

    line = f.readline()

f.close()
fo.close()
