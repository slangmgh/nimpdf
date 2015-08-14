# Copyright (c) 2015 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
#
# this module act as an incomplete wrapper for LodePNG and uJPEG
# also provide zcompress to compress nimPDF streams
# currently, identify file format only by it's file name extension
# eg: .png, .jpg, .jpeg, .bmp

import bmp, os, strutils, png, nimz

#{.deadCodeElim: on.}
#{.passC: "-D LODEPNG_NO_COMPILE_CPP".}
#{.passL: "-lstdc++" .}
#{.compile: "lodepng.c".}
{.compile: "ujpeg.c".}

type
  Image* = ref object
    width*, height*, ID*: int
    data*, mask*: string
#  TCompressFunc = proc(outdata: ptr ptr cuchar, outsize: ptr int, indata: ptr cuchar, insize: int, settings: ptr LodePNGCompressSettings)
#  LodePNGCompressSettings {.final, pure.} = object
#    #LZ77 related settings
#    btype: int #the block type for LZ (0, 1, 2 or 3, see zlib standard). Should be 2 for proper compression.
#    use_lz77: int #whether or not to use LZ77. Should be 1 for proper compression.
#    windowsize: int #must be a power of two <= 32768. higher compresses more but is slower. Default value: 2048.
#    minmatch: int #mininum lz77 length. 3 is normally best, 6 can be better for some PNGs. Default: 0
#    nicematch: int #stop searching if >= this length found. Set to 258 for best compression. Default: 128
#    lazymatching: int #use lazy matching: better compression but a bit slower. Default: true
#    #use custom zlib encoder instead of built in one (default: null)
#    custom_zlib: TCompressFunc
#    #use custom deflate encoder instead of built in one (default: null)
#    #if custom_zlib is used, custom_deflate is ignored since only the built in
#    #zlib function will call custom_deflate
#    custom_deflate: TCompressFunc
#    custom_context: ptr cuchar #optional custom settings for custom functions

  ujImage = pointer

#proc lodepng_decode32_file(data: ptr ptr cuchar, w: ptr int, h: ptr int, filename : cstring) : int {.header: "lodepng.h", importc: "lodepng_decode32_file".}
#proc lodepng_zlib_compress(outdata: ptr ptr cuchar, outsize: ptr int, indata: pointer, insize: int, settings: ptr LodePNGCompressSettings): int {.header: "lodepng.h", importc: "lodepng_zlib_compress".}
#proc lodepng_compress_settings_init(settings: ptr LodePNGCompressSettings) {.header: "lodepng.h", importc: "lodepng_compress_settings_init".}
#proc c_free(data: ptr cuchar) {.header: "<stdlib.h>", importc: "free".}

proc ujCreate() : ujImage {.header: "ujpeg.h", importc: "ujCreate".}
proc ujDecode(img: ujImage, data: ptr cuchar, size: int) : ujImage {.header: "ujpeg.h", importc: "ujDecode".}
proc ujDecodeFile(img: ujImage, filename: cstring) : ujImage {.header: "ujpeg.h", importc: "ujDecodeFile".}
proc ujGetWidth(img: ujImage) : int {.header: "ujpeg.h", importc: "ujGetWidth".}
proc ujGetHeight(img: ujImage) : int {.header: "ujpeg.h", importc: "ujGetHeight".}
proc ujGetImageSize(img: ujImage) : int {.header: "ujpeg.h", importc: "ujGetImageSize".}
proc ujGetImage(img: ujImage, dest: cstring) : cstring {.header: "ujpeg.h", importc: "ujGetImage".}
proc ujDestroy(img: ujImage) {.header: "ujpeg.h", importc: "ujDestroy".}

proc loadImagePNG(fileName: string): Image =
  var png = loadPNG32(fileName)
  if png == nil: return nil
  new(result)
  let size = png.width*png.height
  result.width = png.width
  result.height = png.height
  result.data = newString(size * 3)
  result.mask = newString(size)
  for i in 0..size-1:
    result.data[i * 3]     = png.data[i*4]
    result.data[i * 3 + 1] = png.data[i*4 + 1]
    result.data[i * 3 + 2] = png.data[i*4 + 2]
    result.mask[i] = png.data[i*4 + 3]
  
proc loadImageJPG(fileName:string): Image =
  var jpg = ujCreate()
  if jpg == nil: return nil

  if ujDecodeFile(jpg, cstring(fileName)) != nil:
    new(result)
    let size = ujGetImageSize(jpg)
    result.width = ujGetWidth(jpg)
    result.height = ujGetHeight(jpg)
    result.data = newString(size * 3)
    result.mask = ""
    discard ujGetImage(jpg, cstring(result.data))
    ujDestroy(jpg)
  else:
    result = nil

proc loadImageBMP(fileName:string): Image =
  var bmp: BMP
  bmp.init()
  if bmp.ReadFromFile(fileName):
    new(result)
    let size=bmp.Width*bmp.Height
    result.width = bmp.Width
    result.height = bmp.Height
    result.data = newString(size * 3)
    result.mask = ""
    var pos = 0
    for y in 0..bmp.Height-1:
      for x in 0..bmp.Width-1:
        let px = y * bmp.Width + x
        result.data[pos] = char(bmp.Pixels[px].Red)
        result.data[pos + 1] = char(bmp.Pixels[px].Green)
        result.data[pos + 2] = char(bmp.Pixels[px].Blue)
        pos += 3
  else:
    result = nil

proc loadImage*(fileName:string): Image =
  let path = splitFile(fileName)
  if path.ext.len() > 0:
    let ext = toLower(path.ext)
    if ext == ".png": return loadImagePNG(fileName)
    if ext == ".bmp": return loadImageBMP(fileName)
    if ext == ".jpg" or ext == ".jpeg": return loadImageJPG(fileName)
  result = nil

proc haveMask*(img: Image): bool =
  result = img.mask.len() > 0

proc clone*(img: Image): Image =
  new(result)
  result.width = img.width
  result.height = img.height
  result.data = img.data
  result.mask = img.mask

proc adjustTransparency*(img: Image, alpha:float) =
  if img.haveMask():
    for i in 0..high(img.mask):
      img.mask[i] = char(float(img.mask[i]) * alpha)
  else:
    img.mask = newString(img.width*img.height)
    for i in 0..high(img.mask):
      img.mask[i] = char(255.0 * alpha)

proc zcompress*(data: string): string =
  var nz = nzDeflateInit(data)
  result = nz.zlib_compress()

when isMainModule:
  var img = loadImage("pngbar.png")
  var x = loadImage("24bit.bmp")
  if img != nil : echo "width: ", img.width
  if x != nil : echo "width: ", x.width
  let sss = "mau kemana dong? engk ink engk? weleh weleh mmmmmm sangkamu aku mau kemana sih gitu aja ngedumel, weleh weleh, sinting"
  var res = zcompress(sss)
  echo "ori: ", sss.len(), " len: ", res.len()
