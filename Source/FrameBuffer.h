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

- (id)initWithSize:(NSSize)aSize andFormat:(rfbPixelFormat*)theFormat;
- (void)setPixelFormat:(rfbPixelFormat*)theFormat;

+ (BOOL)bigEndian;
- (BOOL)bigEndian;

- (void)setTarget:(NSImage *) targetView; // Note: we don't retain the target.

/* How much data is there in the pixels we want? */
- (int) bitsPerPixel;
- (void)setBitsPerPixel:(int) newValue;
- (unsigned int)bytesPerPixel;
- (unsigned int)tightBytesPerPixel;

- (NSSize)size;

/* Methods to get color values from char data. */
- (void)getRGB:(float*)rgb fromPixel:(unsigned char*)pixValue;
- (NSColor *) colorFromChars:(unsigned char*)colorData bytesPerPixel:(int)bpp;
- (NSColor *)colorFromReversedChars:(unsigned char*)colorData bytesPerPixel:(int)bpp;
- (NSColor *)nsColorFromPixel24:(unsigned char*)pixValue;
- (NSColor *)nsColorFromReversePixel24:(unsigned char*)pixValue;

- (void) remapRect:(NSRect *) aRect;

- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp;
- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue;
- (void)fillRect:(NSRect)aRect withReversedPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp;
- (void)fillRect:(NSRect)aRect tightPixel:(unsigned char*)pixValue;
- (void)fillRect:(NSRect)aRect withNSColor:(NSColor *)aColor;

- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data;
- (void)putRect:(NSRect)aRect fromReversedData:(unsigned char*)data;
- (void)putRect:(NSRect)aRect fromTightData:(unsigned char*)data;
- (void)splitRGB:(unsigned char*)pixValue pixels:(unsigned)length into:(int*)rgb;
- (void)combineRGB:(int*)rgb pixels:(unsigned)length into:(unsigned char*)pixValue;

- (void)copyRect:(NSRect)aRect to:(NSPoint)aPoint;

@end

#endif /* __FRAMEBUFFER_H_INCLUDED__ */

 