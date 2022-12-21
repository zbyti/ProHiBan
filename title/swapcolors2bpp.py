import sys

infile = sys.argv[1]
outfile = sys.argv[2]
col1 = int(sys.argv[3])
col2 = int(sys.argv[4])

outBytes = []
count = 0

def swapBitPairs(inbyte, col1, col2):
    mask = 0b00000011
    outByte = 0
#    print(ord(inbyte));
    while mask < 256:
        col = ord(inbyte) & mask
        if col == col1:
            outByte |= col2
        elif col == col2:
            outByte |= col1
        else:
            outByte |= col
                
#        print(col, col1, col2, outByte)
        mask = mask << 2
        col1 = col1 << 2
        col2 = col2 << 2
        
#    print(outByte);
    return outByte


with open(infile, "rb") as f:
    inbyte = f.read(1)
    while inbyte:
        count+=1
        outBytes.append(swapBitPairs(inbyte, col1, col2))
        inbyte = f.read(1)

print('bytes converted:', count)

with open(outfile, "wb") as f:
    f.write(bytearray(outBytes))


    


