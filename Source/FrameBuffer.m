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


#include "FrameBuffer.h"
#include "RFBConnectionManager.h"

@implementation FrameBuffer

- (id)initWithSize:(NSSize)aSize andFormat:(rfbPixelFormat*)theFormat
{
    originPoint.x = originPoint.y = 0.0;

    union {
        unsigned char	c[2];
        unsigned short	s;
    } x;

    if (self = [super init]) {
        x.s = 0x1234;
        isBig = (x.c[0] == 0x12);
        size = aSize;
        /*
         [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitor:)
                                        userInfo:nil repeats:YES];
         */
    }
    bitsPerPixel = 32; // Start with some default, anyway...
    return self;
}

- (void)setPixelFormat:(rfbPixelFormat*)theFormat
{
    int		i;
    double	rweight, gweight, bweight, gamma = 1.0/[RFBConnectionManager gammaCorrection];

    fprintf(stderr, "rfbPixelFormat redMax = %d\n", theFormat->redMax);
    fprintf(stderr, "rfbPixelFormat greenMax = %d\n", theFormat->greenMax);
    fprintf(stderr, "rfbPixelFormat blueMax = %d\n", theFormat->blueMax);
    if(theFormat->redMax > 255)
        theFormat->redMax = 255;		/* limit at our LUT size */
    if(theFormat->greenMax > 255)
        theFormat->greenMax = 255;	/* limit at our LUT size */
    if(theFormat->blueMax > 255)
        theFormat->blueMax = 255;	/* limit at our LUT size */
    memcpy(&pixelFormat, theFormat, sizeof(pixelFormat));

    if(samplesPerPixel == 1) {			/* greyscale */
        rweight = 0.3;
        gweight = 0.59;
        bweight = 0.11;
    } else {
        rweight = gweight = bweight = 1.0;
}

for(i=0; i<=theFormat->redMax; i++) {
    redClut[i] = (int)(rweight * pow((double)i / (double)theFormat->redMax, gamma) * maxValue + 0.5) << rshift;
}
for(i=0; i<=theFormat->greenMax; i++) {
    greenClut[i] = (int)(gweight * pow((double)i / (double)theFormat->greenMax, gamma) * maxValue + 0.5) << gshift;
}
for(i=0; i<=theFormat->blueMax; i++) {
    blueClut[i] = (int)(bweight * pow((double)i / (double)theFormat->blueMax, gamma) * maxValue + 0.5) << bshift;
}
}

+ (BOOL)bigEndian
{
    union {
        unsigned char c[2];
        unsigned short        s;
    } x;

    x.s = 0x1234;
    return (x.c[0] == 0x12);
}

- (BOOL)bigEndian
{
    return [FrameBuffer bigEndian];
}

- (void)setTarget:(NSImage *) targetView
{
    target = targetView; // Note: we don't retain the target.
}

- (int) bitsPerPixel
{
    return bitsPerPixel;
}

- (void)setBitsPerPixel:(int) newValue
{
    bitsPerPixel = newValue;
}

- (unsigned int)bytesPerPixel
{
    return (unsigned int)bitsPerPixel / 8;
}

- (unsigned int)tightBytesPerPixel
{
    if((pixelFormat.bitsPerPixel == 32) &&
       (pixelFormat.depth == 24) &&
       (pixelFormat.redMax == 0xff) &&
       (pixelFormat.greenMax == 0xff) &&
       (pixelFormat.blueMax == 0xff)) {
        return 3;
    } else {
        return [self bytesPerPixel];
    }
}

- (NSSize)size
{
    return size;
}

/* This looks like a hack for the rectlist stuff.  Should rewrite/refactor. */
- (void)getRGB:(float*)rgb fromPixel:(unsigned char*)pixValue
{
    switch([self bytesPerPixel]) {
        /*
         case 1:
             pix = *v;
             break;
         case 2:
             if([self pixelFormat].bigEndian) {
                 pix = *v++; pix <<= 8; pix += *v;
             } else {
                 pix = *v++; pix += (((unsigned int)*v) << 8);
             }
             break;
             */
        case 4:
            rgb[0] = (float) pixValue[2]/255.0;
            rgb[1] = (float) pixValue[1]/255.0;
            rgb[2] = (float) pixValue[0]/255.0;
            break;
        default:
            NSLog(@"Dunno how to ns_pixelData for %d yet", [self bytesPerPixel]);
    }
    return;
}

- (NSColor *) colorFromChars:(unsigned char*)colorData bytesPerPixel:(int)bpp
{
    switch(bpp) {
        case 1:
            return [NSColor colorWithCalibratedRed:(float) colorData[0]/255.0 green:(float) colorData[0]/255.0 blue:(float) colorData[0]/255.0 alpha:1.0];
            /*
             case 2:
                 pix = *colorData++; pix += (((unsigned int)*colorData) << 8);
                 break;
                 */
        case 3:
        case 4:
            return [NSColor colorWithCalibratedRed:(float) colorData[0]/255.0 green:(float) colorData[1]/255.0 blue:(float) colorData[2]/255.0 alpha:1.0];
        default:
            NSLog(@"Don't know how do to colorFromReversedChars for %d bpp", bpp);
    }
    return nil;
}

- (NSColor *)colorFromReversedChars:(unsigned char*)colorData bytesPerPixel:(int)bpp
{
    switch(bpp) {
        case 1:
            return [NSColor colorWithCalibratedRed:(float) colorData[0]/255.0 green:(float) colorData[0]/255.0 blue:(float) colorData[0]/255.0 alpha:1.0];
            break;
            /*
             case 2:
                 pix = *colorData++; pix += (((unsigned int)*colorData) << 8);
                 break;
                 */
        case 3:
        case 4:
            return [NSColor colorWithCalibratedRed:(float) colorData[2]/255.0 green:(float) colorData[1]/255.0 blue:(float) colorData[0]/255.0 alpha:1.0];
        default:
            NSLog(@"Don't know how do to colorFromReversedChars for %d bpp", bpp);
    }
    return nil;
}

- (NSColor *)nsColorFromPixel24:(unsigned char*)pixValue
{
    return [self colorFromChars:pixValue bytesPerPixel:3];
}

- (NSColor *)nsColorFromReversePixel24:(unsigned char*)pixValue
{
    return [self colorFromReversedChars:pixValue bytesPerPixel:3];
}

- (void) remapRect:(NSRect *) aRect
{
    aRect->origin.y = ([target size].height - aRect->origin.y) - aRect->size.height;
}

- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp
{
    [self fillRect:aRect withNSColor:[self colorFromChars:pixValue bytesPerPixel:bpp]];
}

- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue
{
    [self fillRect:aRect withNSColor:[self nsColorFromPixel24:pixValue]];
}

- (void)fillRect:(NSRect)aRect withReversedPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp
{
    [self fillRect:aRect withNSColor:[self colorFromReversedChars:pixValue bytesPerPixel:bpp]];
}

- (void)fillRect:(NSRect)aRect tightPixel:(unsigned char*)pixValue
{
    if([self tightBytesPerPixel] == 3) {
        [self fillRect:aRect withNSColor:[self nsColorFromPixel24:pixValue]];
    } else {
        char oneChar = *pixValue;
        NSColor *pixelColor = [NSColor colorWithCalibratedRed:(float) (oneChar & 192)/192.0 green:(float) (oneChar & 48)/48.0 blue:(float) (float) (oneChar & 12)/12.0 alpha:1.0];
        [self fillRect:aRect withNSColor:pixelColor];
    }
}

- (void)fillRect:(NSRect)aRect withNSColor:(NSColor *)aColor
{

#ifdef DEBUG_DRAW
    printf("fill x=%f y=%f w=%f h=%f -> %d\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height, aColor);
#endif

#ifdef PINFO
    fillRectCount++;
    fillPixelCount += aRect.size.width * aRect.size.height;
#endif

    [self remapRect:&aRect];
    [target lockFocus];
    [aColor set];
    NSRectFill(aRect);
    [target unlockFocus];
}

- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data
{
    //unsigned int stride, i, lines, pix, col;

    [self remapRect:&aRect];
    [target lockFocus];

#ifdef DEBUG_DRAW
    printf("put x=%f y=%f w=%f h=%f\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
#endif

#ifdef PINFO
    putRectCount++;
    putPixelCount += aRect.size.width * aRect.size.height;
#endif

    switch([self bytesPerPixel]) {
        case 1:
            NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 2, 1, 8, aRect.size.width * 1, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
            break;
        case 2:
            NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 4, [self bytesPerPixel], 8 * [self bytesPerPixel], aRect.size.width * [self bytesPerPixel], NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
            break;
        case 3:
        case 4:
            NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 8, [self bytesPerPixel], 8 * [self bytesPerPixel], aRect.size.width * [self bytesPerPixel], NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
            break;
        default:
            NSLog(@"Don't know how to - (void)putRect:(NSRect)aRect fromData:(unsigned char*)data in %d yet.", [self bytesPerPixel]);
    }
    [target unlockFocus];
}

- (void)putRect:(NSRect)aRect fromReversedData:(unsigned char*)data
{
    unsigned char *fixedData;
    int bpp = [self bytesPerPixel];
    int charCount = aRect.size.width * aRect.size.height * bpp;
    int i;

    fixedData = malloc(sizeof(unsigned char) * charCount);
    for (i = 0; i < aRect.size.width * aRect.size.height; i++) {
        fixedData[i * bpp] = data[i * bpp + 3];
        fixedData[i * bpp + 1] = data[i * bpp + 2];
        fixedData[i * bpp + 2] = data[i * bpp + 1];
    }
    [self putRect:aRect fromData:fixedData];
    free(fixedData);
}

- (void)putRect:(NSRect)aRect fromTightData:(unsigned char*)data
{
    if([self tightBytesPerPixel] == 3) {
        [self remapRect:&aRect];
        [target lockFocus];
        NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 8, 3, 8 * 3, aRect.size.width * 3, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
        [target unlockFocus];
    } else {
        [self putRect:aRect fromData:data];
    }
}

#define TO_RGB(d,c) 						\
*d++ = (c >> pixelFormat.redShift) & pixelFormat.redMax; 	\
*d++ = (c >> pixelFormat.greenShift) & pixelFormat.greenMax;	\
*d++ = (c >> pixelFormat.blueShift) & pixelFormat.blueMax
/* What is this stuff, and why is it here? */
- (void)splitRGB:(unsigned char*)v pixels:(unsigned)length into:(int*)rgb
{
    unsigned char c;
    int pix;

    switch([self tightBytesPerPixel]) {
        case 1:
            while(length--) {
                c = *v++;
                TO_RGB(rgb, c);
            }
            break;
        case 2:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    pix = *v++; pix <<= 8; pix += *v++;
                    TO_RGB(rgb, pix);
                }
            } else {
                while(length--) {
                    pix = *v++; pix += (((unsigned int)*v++) << 8);
                    TO_RGB(rgb, pix);
                }
            }
            break;
        case 3:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    pix = *v++; pix <<= 8;
                    pix += *v++; pix <<= 8;
                    pix += *v++;
                    TO_RGB(rgb, pix);
                }
            } else {
                while(length--) {
                    pix = *v++;
                    pix += (((unsigned int)*v++) << 8);
                    pix += (((unsigned int)*v++) << 16);
                    TO_RGB(rgb, pix);
                }
            }
            break;
        case 4:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    pix = *v++; pix <<= 8;
                    pix += *v++; pix <<= 8;
                    pix += *v++; pix <<= 8;
                    pix += *v++;
                    TO_RGB(rgb, pix);
                }
            } else {
                while(length--) {
                    pix = *v++;
                    pix += (((unsigned int)*v++) << 8);
                    pix += (((unsigned int)*v++) << 16);
                    pix += (((unsigned int)*v++) << 24);
                    TO_RGB(rgb, pix);
                }
            }
            break;
        default:
            NSLog(@"HELP - I'M LOST");
    }
}

#define TO_PIX(p,s)						\
p = (*s++ & pixelFormat.redMax) << pixelFormat.redShift;	\
p |= (*s++ & pixelFormat.greenMax) << pixelFormat.greenShift;	\
p |= (*s++ & pixelFormat.blueMax) << pixelFormat.blueShift
/* What is this stuff, and why is it here? */
- (void)combineRGB:(int*)rgb pixels:(unsigned)length into:(unsigned char*)v
{
    int pix, bpp = [self tightBytesPerPixel];

    switch(bpp) {
        case 1:
            while(length--) {
                TO_PIX(pix, rgb);
                *v++ = pix;
            }
            break;
        case 2:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = (pix >> 8) & 0xff;
                    *v++ = pix & 0xff;
                }
            } else {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = pix & 0xff;
                    *v++ = (pix >> 8) & 0xff;
                }
            }
            break;
        case 3:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = (pix >> 16) & 0xff;
                    *v++ = (pix >> 8) & 0xff;
                    *v++ = pix & 0xff;
                }
            } else {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = pix & 0xff;
                    *v++ = (pix >> 8) & 0xff;
                    *v++ = (pix >> 16) & 0xff;
                }
            }
            break;
        case 4:
            if(pixelFormat.bigEndian) {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = (pix >> 24) & 0xff;
                    *v++ = (pix >> 16) & 0xff;
                    *v++ = (pix >> 8) & 0xff;
                    *v++ = pix & 0xff;
                }
            } else {
                while(length--) {
                    TO_PIX(pix, rgb);
                    *v++ = pix & 0xff;
                    *v++ = (pix >> 8) & 0xff;
                    *v++ = (pix >> 16) & 0xff;
                    *v++ = (pix >> 24) & 0xff;
                }
            }
            break;
        default:
            NSLog(@"HELP - I'M LOST");
    }
}

- (void)copyRect:(NSRect)aRect to:(NSPoint)aPoint
{
    NSBitmapImageRep *copyRect;
    NSRect targetRect = aRect;
    targetRect.origin = aPoint;

    [self remapRect:&aRect];
    [self remapRect:&targetRect];

    [target lockFocus];
    copyRect = [[NSBitmapImageRep alloc] initWithFocusedViewRect:aRect];
    [copyRect drawAtPoint:targetRect.origin];
    [copyRect autorelease];
    [target unlockFocus];
}

@end

 