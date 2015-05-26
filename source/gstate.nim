# Copyright (c) 2015 Andri Lim
#
# Distributed under the MIT license 
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
# graphic state

import math, basic2d, fontmanager, image

const
  PGU_K_MM = 72/25.4
  PGU_K_CM = 72/2.54
  PGU_K_IN = 72
  
  BM_NAMES* = ["Normal", "Multiply", "Screen", "Overlay", "Darken",
    "Lighten", "ColorDodge", "ColorBurn", "HardLight", "SoftLight", "Difference", "Exclusion"]
 
  NAMED_COLORS = [
    ("aliceblue", 240, 248, 255), ("antiquewhite", 250, 235, 215), ("aqua", 0, 255, 255), ("aquamarine", 127, 255, 212),
    ("azure", 240, 255, 255), ("beige", 245, 245, 220), ("bisque", 255, 228, 196), ("black", 0, 0, 0), ("blanchedalmond", 255, 235, 205),
    ("blue", 0, 0, 255), ("blueviolet", 138, 43, 226), ("brown", 165, 42, 42), ("burlywood", 222, 184, 135), ("cadetblue", 95, 158, 160),
    ("chartreuse", 127, 255, 0), ("chocolate", 210, 105, 30), ("coral", 255, 127, 80), ("cornflowerblue", 100, 149, 237), ("cornsilk", 255, 248, 220),
    ("crimson", 220, 20, 60), ("cyan", 0, 255, 255), ("darkblue", 0, 0, 139), ("darkcyan", 0, 139, 139), ("darkgoldenrod", 184, 132, 11),
    ("darkgray", 169, 169, 169), ("darkgreen", 0, 100, 0), ("darkgrey", 169, 169, 169), ("darkkhaki", 189, 183, 107), ("darkmagenta", 139, 0, 139),
    ("darkolivegreen", 85, 107, 47), ("darkorange", 255, 140, 0), ("darkorchid", 153, 50, 204), ("darkred", 139, 0, 0), ("darksalmon", 233, 150, 122),
    ("darkseagreen", 143, 188, 143), ("darkslateblue", 72, 61, 139), ("darkslategray", 47, 79, 79), ("darkslategrey", 47, 79, 79),
    ("darkturquoise", 0, 206, 209), ("darkviolet", 148, 0, 211), ("deeppink", 255, 20, 147), ("deepskyblue", 0, 191, 255), ("dimgray", 105, 105, 105),
    ("dimgrey", 105, 105, 105), ("dodgerblue", 30, 144, 255), ("firebrick", 178, 34, 34), ("floralwhite", 255, 255, 240), ("forestgreen", 34, 139, 34),
    ("fuchsia", 255, 0, 255), ("gainsboro", 220, 220, 220), ("ghostwhite", 248, 248, 255), ("gold", 255, 215, 0), ("goldenrod", 218, 165, 32),
    ("gray", 128, 128, 128), ("green", 0, 128, 0), ("greenyellow", 173, 255, 47), ("grey", 128, 128, 128), ("honeydew", 240, 255, 240),
    ("hotpink", 255, 105, 180), ("indianred", 205, 92, 92), ("indigo", 75, 0, 130), ("ivory", 255, 255, 240), ("khaki", 240, 230, 140),
    ("lavender", 230, 230, 250), ("lavenderblush", 255, 240, 245), ("lawngreen", 124, 252, 0), ("lemonchiffon", 255, 250, 205),
    ("lightblue", 173, 216, 230), ("lightcoral", 240, 128, 128), ("lightcyan", 224, 255, 255), ("lightgoldenrodyellow", 250, 250, 210),
    ("lightgray", 211, 211, 211), ("lightgreen", 144, 238, 144), ("lightgrey", 211, 211, 211), ("lightpink", 255, 182, 193),
    ("lightsalmon", 255, 160, 122), ("lightseagreen", 32, 178, 170), ("lightskyblue", 135, 206, 250), ("lightslategray", 119, 136, 153),
    ("lightslategrey", 119, 136, 153),("lightsteelblue", 176, 196, 222),("lightyellow", 255, 255, 224),("lime", 0, 255, 0),("limegreen", 50, 205, 50),
    ("linen", 250, 240, 230),("magenta", 255, 0, 255),("maroon", 128, 0, 0),("mediumaquamarine", 102, 205, 170),("mediumblue", 0, 0, 205),
    ("mediumorchid", 186, 85, 211),("mediumpurple", 147, 112, 219),("mediumseagreen", 60, 179, 113),("mediumslateblue", 123, 104, 238),
    ("mediumspringgreen", 0, 250, 154),("mediumturquoise", 72, 209, 204),("mediumvioletred", 199, 21, 133),("midnightblue", 25, 25, 112),
    ("mintcream", 245, 255, 250),("mistyrose", 255, 228, 225),("moccasin", 255, 228, 181),("navajowhite", 255, 222, 173),
    ("navy", 0, 0, 128),("oldlace", 253, 245, 230),("olive", 128, 128, 0),("olivedrab", 107, 142, 35),("orange", 255, 165, 0),
    ("orangered", 255, 69, 0),("orchid", 218, 112, 214),("palegoldenrod", 238, 232, 170),("palegreen", 152, 251, 152),
    ("paleturquoise", 175, 238, 238),("palevioletred", 219, 112, 147),("papayawhip", 255, 239, 213),("peachpuff", 255, 218, 185),
    ("peru", 205, 133, 63),("pink", 255, 192, 203),("plum", 221, 160, 203),("powderblue", 176, 224, 230),("purple", 128, 0, 128),
    ("red", 255, 0, 0),("rosybrown", 188, 143, 143),("royalblue", 65, 105, 225),("saddlebrown", 139, 69, 19),
    ("salmon", 250, 128, 114),("sandybrown", 244, 164, 96),("seagreen", 46, 139, 87),("seashell", 255, 245, 238),("sienna", 160, 82, 45),
    ("silver", 192, 192, 192),("skyblue", 135, 206, 235),("slateblue", 106, 90, 205),("slategray", 119, 128, 144),("slategrey", 119, 128, 144),
    ("snow", 255, 255, 250),("springgreen", 0, 255, 127),("steelblue", 70, 130, 180),("tan", 210, 180, 140),("teal", 0, 128, 128),
    ("thistle", 216, 191, 216),("tomato", 255, 99, 71),("turquoise", 64, 224, 208),("violet", 238, 130, 238),("wheat", 245, 222, 179),
    ("white", 255, 255, 255),("whitesmoke", 245, 245, 245),("yellow", 255, 255, 0),("yellowgreen", 154, 205, 5)]
     
type
  PageUnitType* = enum
    PGU_PT, PGU_MM, PGU_CM, PGU_IN
  
  PageUnit* = object
    unitType*: PageUnitType
    k*: float64
  
  LineCap* = enum
    BUTT_END, ROUND_END, SQUARE_END

  LineJoin* = enum
    MITER_JOIN, ROUND_JOIN, BEVEL_JOIN
    
  DashMode* = object
    ptn*: array[0..7, int]
    num_ptn*: int
    phase*: int

  TextRenderingMode* = enum
    TR_FILL, TR_STROKE, TR_FILL_THEN_STROKE, TR_INVISIBLE, TR_FILL_CLIPPING,
    TR_STROKE_CLIPPING, TR_FILL_STROKE_CLIPPING, TR_CLIPPING
  
  ColorSpace* = enum
    CS_DEVICE_GRAY, CS_DEVICE_RGB, CS_DEVICE_CMYK, CS_CAL_GRAY,
    CS_CAL_RGB, CS_LAB, CS_ICC_BASED, CS_SEPARATION, CS_DEVICE_N,
    CS_INDEXED, CS_PATTERN,
    CS_GRADIENT, CS_IMAGE #fill type
    
  RGBColor* = object
    r*, g*, b* : float64
    
  Coord* = object
    x1*, y1*, x2*, y2*: float64
  
  CoordRadial* = object
    x1*, y1*, r1*, x2*, y2*, r2*: float64
    
  CMYKColor* = object
    c*, m*, y*, k* : float64
  
  WritingMode = enum
    WMODE_HORIZONTAL, WMODE_VERTICAL
  
  BlendMode* = enum
    BM_NORMAL, BM_MULTIPLY, BM_SCREEN, BM_OVERLAY, BM_DARKEN, BM_LIGHTEN
    BM_COLOR_DODGE, BM_COLOR_BURN, BM_HARD_LIGHT, BM_SOFT_LIGHT, BM_DIFFERENCE, BM_EXCLUSION
  
  GradientType* = enum
    GDT_LINEAR, GDT_RADIAL
  
  Gradient* = ref object
    ID*, objID*: int
    a*, b*: RGBColor
    case gradType*: GradientType
    of GDT_LINEAR:
      axis* : Coord
    of GDT_RADIAL:
      radCoord*: CoordRadial
 
  GState* = ref object
    trans_matrix*: TMatrix2d
    line_width*: float64
    line_cap*: LineCap
    line_join*: LineJoin
    miter_limit*: float64
    dash*: DashMode
    flatness*: float64
    char_space*, word_space*, h_scaling*, text_leading*: float64
    rendering_mode*: TextRenderingMode  
    text_rise*: float64
    cs_fill*, cs_stroke*: ColorSpace
    rgb_fill*, rgb_stroke*: RGBColor
    cmyk_fill*, cmyk_stroke*: CMYKColor
    alpha_fill*, alpha_stroke*: float64
    gray_stroke*, gray_fill*:float64
    blend_mode*: BlendMode
    gradient_fill*: Gradient
    image_fill*: PImage
    font*: Font
    font_size*: float64
    writing_mode*: WritingMode
    prev: GState
    
proc init*(c: var RGBColor; r,g,b: float64) =
  c.r = r
  c.g = g
  c.b = b

proc makeRGB*(r,g,b: float64): RGBColor =
  result.r = r
  result.g = g
  result.b = b

proc makeRGB*(name:string): RGBColor =
  for c in NAMED_COLORS:
    if name == c[0]: return makeRGB(c[1]/255, c[2]/255, c[3]/255)
  result = makeRGB(0,0,0)
  
proc makeCMYK*(c,m,y,k: float64): CMYKColor =
  result.c = c
  result.m = m
  result.y = y
  result.k = k

proc makeLinearGradient*(a, b: RGBColor, axis: Coord): Gradient =
  new(result)
  result.gradType = GDT_LINEAR
  result.a = a
  result.b = b
  result.axis = axis

proc makeRadialGradient*(a, b: RGBColor, coord: CoordRadial): Gradient =
  new(result)
  result.gradType = GDT_RADIAL
  result.a = a
  result.b = b
  result.radCoord = coord
  
proc init*(cc: var CMYKColor; c,m,y,k: float64) =
  cc.c = c
  cc.m = m
  cc.y = y
  cc.k = k
   
proc makeCoord*(x1,y1,x2,y2: float64): Coord =
  result.x1 = x1
  result.y1 = y1
  result.x2 = x2
  result.y2 = y2

proc makeCoord*(x1,y1,r1,x2,y2,r2: float64): CoordRadial =
  result.x1 = x1
  result.y1 = y1
  result.r1 = r1
  result.x2 = x2
  result.y2 = y2
  result.r2 = r2

proc init*(c: var DashMode) =
  for i in 0..high(c.ptn): c.ptn[i] = 0
  c.num_ptn = 0
  c.phase = 0
  
proc setUnit*(this: var PageUnit, v: PageUnitType) : int {.discardable.} =
  this.unitType = v
  case v
    of PGU_PT: this.k = 1.0
    of PGU_MM: this.k = PGU_K_MM
    of PGU_CM: this.k = PGU_K_CM
    of PGU_IN: this.k = PGU_K_IN

proc fromMM*(mm: float64) : float64 = PGU_K_MM * mm
proc fromCM*(cm: float64) : float64 = PGU_K_CM * cm
proc fromIN*(inch: float64) : float64 =  PGU_K_IN * inch

proc fromUser*(this: PageUnit, val: float64) : float64 =  this.k * val
proc toUser*(this: PageUnit, val: float64) : float64 = val / this.k

proc newGState*(): GState =
  let black = makeRGB(0,0,0)
  let cmyk_black = makeCMYK(0,0,0,0)
  new(result)
  
  result.trans_matrix   = IDMATRIX
  result.line_width   = fromMM(1.0)
  result.line_cap     = BUTT_END
  result.line_join    = MITER_JOIN
  result.miter_limit  = fromMM(10)
  result.dash.init()
  result.flatness     = fromMM(1.0)

  result.char_space   = 0
  result.word_space   = 0
  result.h_scaling    = 100
  result.text_leading   = 0
  result.rendering_mode = TR_FILL
  result.text_rise    = 0

  result.cs_stroke    = CS_DEVICE_RGB
  result.cs_fill    = CS_DEVICE_RGB
  result.rgb_fill     = black
  result.rgb_stroke   = black
  result.cmyk_fill    = cmyk_black
  result.cmyk_stroke  = cmyk_black
  result.alpha_fill   = 1.0
  result.alpha_stroke   = 1.0
  result.gray_fill    = 0.0
  result.gray_stroke  = 0.0
  result.blend_mode   = BM_NORMAL
  result.gradient_fill  = nil
  result.image_fill   = nil

  result.font       = nil
  result.font_size    = fromMM(10)
  result.writing_mode   = WMODE_HORIZONTAL
  result.prev       = nil
  
proc newGState*(gs: GState): GState =
  new(result)
  
  result.trans_matrix   = gs.trans_matrix
  result.line_width   = gs.line_width
  result.line_cap     = gs.line_cap
  result.line_join    = gs.line_join
  result.miter_limit  = gs.miter_limit
  result.dash       = gs.dash
  result.flatness     = gs.flatness

  result.char_space   = gs.char_space
  result.word_space   = gs.word_space
  result.h_scaling    = gs.h_scaling
  result.text_leading   = gs.text_leading
  result.rendering_mode = gs.rendering_mode
  result.text_rise    = gs.text_rise

  result.cs_stroke    = gs.cs_stroke
  result.cs_fill    = gs.cs_fill
  result.rgb_fill     = gs.rgb_fill
  result.rgb_stroke   = gs.rgb_stroke
  result.cmyk_fill    = gs.cmyk_fill
  result.cmyk_stroke  = gs.cmyk_stroke
  result.alpha_fill   = gs.alpha_fill
  result.alpha_stroke   = gs.alpha_stroke
  result.gray_fill    = gs.gray_fill
  result.gray_stroke  = gs.gray_stroke
  result.blend_mode   = gs.blend_mode
  result.gradient_fill  = gs.gradient_fill
  result.image_fill   = gs.image_fill

  result.font       = gs.font
  result.font_size    = gs.font_size
  result.writing_mode   = gs.writing_mode
  result.prev       = gs
 
proc freeGState*(gs: GState): GState =
  result = gs
  if gs.prev != nil: result = gs.prev