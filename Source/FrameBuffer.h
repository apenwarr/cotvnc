/* Copyright (C) 1998-2000  Helmut Maierhofer <helmut.maierhofer@chello.at>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#ifndef __FRAMEBUFFER_H_INCLUDED__
#define __FRAMEBUFFER_H_INCLUDED__

#import <AppKit/AppKit.h>
#import <rfbproto.h>

#define SCRATCHPAD_SIZE			(384*384)

#define CLUT(c,p) \
c = redClut[(p >> pixelFormat.redShift) & pixelFormat.redMax]; \
c += greenClut[(p >> pixelFormat.greenShift) & pixelFormat.greenMax]; \
c += blueClut[(p >> pixelFormat.blueShift) & pixelFormat.blueMax]

typedef union _FrameBufferColor {
    unsigned char	_u8;
    unsigned short	_u16;
    unsigned int	_u32;
} FrameBufferColor;

typedef unsigned char	FrameBufferPaletteIndex;
typedef	unsigned int	FBColor;


@interface FrameBuffer : NSObject
{
    NSPoint 		originPoint; // AppKit doesn't define this for me?
    BOOL		isBig;
    NSSize		size;
    int			bitsPerPixel;
    //unsigned int	*pixels;
    NSImage 		*target; // Do not retain - I'm am retained by the target
@public
    unsigned int	redClut[256];
    unsigned int	greenClut[256];
    unsigned int	blueClut[256];
    rfbPixelFormat	pixelFormat;
    unsigned int	rshift, gshift, bshift;
    unsigned int	samplesPerPixel, maxValue;
    unsigned int	bitsPerColor;

    unsigned	fillRectCount;
    unsigned	drawRectCount;
    unsigned	copyRectCount;
    unsigned	putRectCount;
    unsigned	fillPixelCount;
    unsigned	drawPixelCount;
    unsigned	copyPixelCount;
    unsigned	putPixelCount;
    
}

//+ (BOOL)bigEndian;

- (void)setTarget:(NSImage *) targetView;

- (id)initWithSize:(NSSize)aSize andFormat:(rfbPixelFormat*)theFormat;

+ (BOOL)bigEndian;
- (BOOL)bigEndian;

- (unsigned int)bytesPerPixel;
- (unsigned int)tightBytesPerPixel;
- (void)getRGB:(float*)rgb fromPixel:(unsigned char*)pixValue;
- (NSSize)size;
- (void)setPixelFormat:(rfbPixelFormat*)theFormat;

- (void)fillColor:(FrameBufferColor*)fbc fromPixel:(unsigned char*)pixValue;
- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue;
- (void)copyRect:(NSRect)aRect to:(NSPoint)aPoint;
- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data;
- (void)drawRect:(NSRect)aRect at:(NSPoint)aPoint;

- (void)fillColor:(FrameBufferColor*)fbc fromTightPixel:(unsigned char*)pixValue;
- (void)fillRect:(NSRect)aRect tightPixel:(unsigned char*)pixValue;
- (void)putRect:(NSRect)aRect fromTightData:(unsigned char*)data;
//- (void)getMaxValues:(int*)m;
- (void)splitRGB:(unsigned char*)pixValue pixels:(unsigned)length into:(int*)rgb;
- (void)combineRGB:(int*)rgb pixels:(unsigned)length into:(unsigned char*)pixValue;

- (void)putRect:(NSRect)aRect withColors:(FrameBufferPaletteIndex*)data fromPalette:(FrameBufferColor*)palette;
- (void)putRun:(FrameBufferColor*)fbc ofLength:(int)length at:(NSRect)aRect pixelOffset:(int)offset;
- (void)putRect:(NSRect)aRect fromRGBBytes:(unsigned char*)rgb;


    /* ############################################################### */
    unsigned int cvt_pixel24(unsigned char* v, FrameBuffer* this);


    unsigned int cvt_pixel(unsigned char* v, FrameBuffer *this);


    /* --------------------------------------------------------------------------------- */
- (void) remapRect:(NSRect *) aRect;

//- (FBColor)colorFromPixel:(unsigned char*)pixValue;

- (NSColor *)nsColorFromReversePixel24:(unsigned char*)pixValue;

- (void)fillColor:(FrameBufferColor*)frameBufferColor fromPixel:(unsigned char*)pixValue;
- (void)fillColor:(FrameBufferColor*)frameBufferColor fromTightPixel:(unsigned char*)pixValue;

- (void)fillRect:(NSRect)aRect withNSColor:(NSColor *)aColor;
- (void)fillRect:(NSRect)aRect withReversedPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp;

- (void)putRect:(NSRect)aRect withColors:(FrameBufferPaletteIndex*)data fromPalette:(FrameBufferColor*)palette;

- (void)putRun:(FrameBufferColor*)frameBufferColor ofLength:(int)length at:(NSRect)aRect pixelOffset:(int)offset;

- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue;
- (void)fillRect:(NSRect)aRect tightPixel:(unsigned char*)pixValue;

- (void)copyRect:(NSRect)aRect to:(NSPoint)aPoint;

- (void)putRect:(NSRect)aRect fromTightData:(unsigned char*)data;
- (void)putRect:(NSRect)aRect fromRGBBytes:(unsigned char*)rgb;

- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data;
- (void)putRect:(NSRect)aRect fromReversedData:(unsigned char*)data;

- (void)drawRect:(NSRect)aRect at:(NSPoint)aPoint;



@end

#endif /* __FRAMEBUFFER_H_INCLUDED__ */

 