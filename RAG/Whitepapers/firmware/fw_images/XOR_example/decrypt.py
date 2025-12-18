

enc_rom = "AWK3131A_1.7_Build_17102617.rom"

def xor(data, key):
    l = len(key)
    return bytearray(((data[i] ^ key[i % l]) for i in range(0,len(data))))


def main():

    data = bytearray(open(enc_rom, 'rb').read())
    key = bytearray("Seek AGREEMENT for the date of completion.\x00")
    dec_file = xor(data, key)

    f = open('dec.rom', 'w')
    f.write(dec_file)
    f.close()

if __name__ == "__main__":
    main()
