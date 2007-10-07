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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <rfbproto.h>

#define SCRATCHPAD_SIZE			(384*384)

typedef union _FrameBufferColor {
    unsigned char	_u8;
    unsigned short	_u16;
    unsigned int	_u32;
} FrameBufferColor;

typedef unsigned char	FrameBufferPaletteIndex;

@interface FrameBuffer : NSObject
{
    BOOL		isBig;
    CGSize		size;
    int			bytesPerPixel;
    
@public
    unsigned int	redClut[256];
    unsigned int	greenClut[256];
    unsigned int	blueClut[256];
    rfbPixelFormat	pixelFormat;
    unsigned int	rshift, gshift, bshift;
    unsigned int	samplesPerPixel, maxValue;
    unsigned int	bitsPerColor;

    unsigned		fillRectCount;
    unsigned		drawRectCount;
    unsigned		copyRectCount;
    unsigned		putRectCount;
    unsigned		fillPixelCount;
    unsigned		drawPixelCount;
    unsigned		copyPixelCount;
    unsigned		putPixelCount;
    BOOL			*forceServerBigEndian;
	BOOL			currentReaderIsTight;
	int				serverMajorVersion;
	int				serverMinorVersion;
	unsigned int	*tightBytesPerPixelOverride;
	
	CGColorSpaceRef _colorspace;
}

+ (BOOL)bigEndian;
+ (void)getPixelFormat:(rfbPixelFormat*)pf;

- (id)initWithSize:(CGSize)aSize andFormat:(rfbPixelFormat*)theFormat;
- (unsigned int)bytesPerPixel;
- (unsigned int)tightBytesPerPixel;
- (void)setTightBytesPerPixelOverride: (unsigned int)count;
- (BOOL)bigEndian;
- (BOOL)serverIsBigEndian;
- (void)setCurrentReaderIsTight: (BOOL)flag;
- (void)setServerMajorVersion: (int)major minorVersion: (int)minor;
- (void)getRGB:(float*)rgb fromPixel:(unsigned char*)pixValue;
- (CGSize)size;
- (void)setPixelFormat:(rfbPixelFormat*)theFormat;

- (void)fillColor:(FrameBufferColor*)fbc fromPixel:(unsigned char*)pixValue;
- (void)fillRect:(CGRect)aRect withPixel:(unsigned char*)pixValue;
- (void)fillRect:(CGRect)aRect withFbColor:(FrameBufferColor*)fbc;
- (void)copyRect:(CGRect)aRect to:(CGPoint)aPoint;
- (void)putRect:(CGRect)aRect fromData:(unsigned char*)data;
- (void)drawRect:(CGRect)aRect at:(CGPoint)aPoint;

- (void)fillColor:(FrameBufferColor*)fbc fromTightPixel:(unsigned char*)pixValue;
- (void)fillRect:(CGRect)aRect tightPixel:(unsigned char*)pixValue;
- (void)putRect:(CGRect)aRect fromTightData:(unsigned char*)data;
- (void)getMaxValues:(int*)m;
- (void)splitRGB:(unsigned char*)pixValue pixels:(unsigned)length into:(int*)rgb;
- (void)combineRGB:(int*)rgb pixels:(unsigned)length into:(unsigned char*)pixValue;

- (void)putRect:(CGRect)aRect withColors:(FrameBufferPaletteIndex*)data fromPalette:(FrameBufferColor*)palette;
- (void)putRun:(FrameBufferColor*)fbc ofLength:(int)length at:(CGRect)aRect pixelOffset:(int)offset;
- (void)putRect:(CGRect)aRect fromRGBBytes:(unsigned char*)rgb;

- (CGColorSpaceRef)colorspace;

@end

#endif /* __FRAMEBUFFER_H_INCLUDED__ */

 