from PIL import Image
import glob

fret_sprites = glob.glob("*.png")
fsxx = None

for fs in fret_sprites:
    fsi = Image.open(fs)
    w, h = fsi.size
    fsx = Image.new("RGBA", (w+2,h+2))
    with open("mif/" + fs[:-4]+".mif", "w") as mif:
        for i in xrange(32):
            mif.write("0000000000000\n")
            fsx.putpixel((i,0), (0,0,0,0))
        for y in xrange(h):
            mif.write("0000000000000\n")
            fsx.putpixel((0,y+1), (0,0,0,0))
            for x in xrange(w):
                pixel =  list(fsi.getpixel((x,y)))
                if y==1: print pixel
                #if pixel[3] > 16:
                #   pixel[1:] = [int(pixel[0]/16.*z) for z in pixel[1:]]
                #   pixel[3] = 16
                #else: pixel[3] = 0
                if pixel[3]>200: pixel[3] = 16
                else: pixel = [0,0,0,0]
                if y==1: print pixel
                pixel = [z/16 for z in pixel]
                pixel_13bit = (pixel[3]<<12)+(pixel[0]<<8)+(pixel[1]<<4)+pixel[2]
                mif.write(format(pixel_13bit, '#015b')[2:])
                mif.write("\n")
                fsx_pixel = [z*16 for z in pixel]
                #print (x,y),fsx_pixel
                fsx.putpixel((x+1,y+1), tuple(fsx_pixel))
            mif.write("0000000000000\n")
            fsx.putpixel((31,y+1), (0,0,0,0))
        for i in xrange(32):
            mif.write("0000000000000")
            if i < 31: mif.write("\n")
            fsx.putpixel((i,31), (0,0,0,0))
    fsxx = fsx

fsxx.show()