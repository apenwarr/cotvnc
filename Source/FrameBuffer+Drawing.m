//
//  FrameBuffer+Drawing.m
//  Chicken of the VNC
//
//  Created by Kurt Werle on Sat Mar 01 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "FrameBuffer+Drawing.h"


@implementation FrameBuffer(FrameBuffer_Drawing)

unsigned int cvt_pixel24(unsigned char* colorData, FrameBuffer* this)
{
    unsigned int pix = 0, col;

    if(this->pixelFormat.bigEndian) {
        pix += *colorData++; pix <<= 8;
        pix += *colorData++; pix <<= 8;
        pix += *colorData;
    } else {
        pix = *colorData++;
        pix += (((unsigned int)*colorData++) << 8);
        pix += (((unsigned int)*colorData++) << 16);
    }
    /*
    col = this->redClut[(pix >> this->pixelFormat.redShift) & this->pixelFormat.redMax];
    col += this->greenClut[(pix >> this->pixelFormat.greenShift) & this->pixelFormat.greenMax];
    col += this->blueClut[(pix >> this->pixelFormat.blueShift) & this->pixelFormat.blueMax];
     */
    return col;
}

unsigned int cvt_pixel(unsigned char* colorData, FrameBuffer *this)
{
    unsigned int pix = 0, col;

    switch(this->pixelFormat.bitsPerPixel / 8) {
        case 1:
            pix = *colorData;
            break;
        case 2:
            if(this->pixelFormat.bigEndian) {
                pix = *colorData++; pix <<= 8; pix += *colorData;
            } else {
                pix = *colorData++; pix += (((unsigned int)*colorData) << 8);
            }
            break;
        case 4:
            if(this->pixelFormat.bigEndian) {
                pix = *colorData++; pix <<= 8;
                pix += *colorData++; pix <<= 8;
                pix += *colorData++; pix <<= 8;
                pix += *colorData;
            } else {
                pix = *colorData++;
                pix += (((unsigned int)*colorData++) << 8);
                pix += (((unsigned int)*colorData++) << 16);
                pix += (((unsigned int)*colorData) << 24);
            }
            break;
    }
    col = this->redClut[(pix >> this->pixelFormat.redShift) & this->pixelFormat.redMax];
    col += this->greenClut[(pix >> this->pixelFormat.greenShift) & this->pixelFormat.greenMax];
    col += this->blueClut[(pix >> this->pixelFormat.blueShift) & this->pixelFormat.blueMax];
    return col;
}

/* --------------------------------------------------------------------------------- */
- (void) remapRect:(NSRect *) aRect
{
        aRect->origin.y = ([target size].height - aRect->origin.y) - aRect->size.height;
}

- (NSColor *)nsColorFromPixel24:(unsigned char*)pixValue
{
    return [NSColor colorWithCalibratedRed:(float) pixValue[0]/255.0 green:(float) pixValue[1]/255.0 blue:(float) pixValue[2]/255.0 alpha:1.0];
}

- (NSColor *)nsColorFromReversePixel24:(unsigned char*)pixValue
{
    return [NSColor colorWithCalibratedRed:(float) pixValue[2]/255.0 green:(float) pixValue[1]/255.0 blue:(float) pixValue[0]/255.0 alpha:1.0];
}

- (void)fillColor:(FrameBufferColor*)frameBufferColor fromPixel:(unsigned char*)pixValue
{
    *((FBColor*)frameBufferColor) = cvt_pixel(pixValue, self);
}

- (void)fillColor:(FrameBufferColor*)frameBufferColor fromTightPixel:(unsigned char*)pixValue
{
	if([self tightBytesPerPixel] == 3) {
		*((FBColor*)frameBufferColor) = cvt_pixel24(pixValue, self);
	} else {
		*((FBColor*)frameBufferColor) = cvt_pixel(pixValue, self);
	}
}

/* --------------------------------------------------------------------------------- */
- (void)fillRect:(NSRect)aRect withColor:(NSColor *)aColor
{
    NSLog(@"Should not be here.");
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

/*
- (void)fillRect:(NSRect)aRect withColor:(FBColor)aColor
{	
    FBColor* start;
    unsigned int stride, i, lines;

#ifdef DEBUG_DRAW
printf("fill x=%f y=%f w=%f h=%f -> %d\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height, aColor);
#endif

#ifdef PINFO
	fillRectCount++;
    fillPixelCount += aRect.size.width * aRect.size.height;
#endif

    start = pixels + (int)(aRect.origin.y * size.width) + (int)aRect.origin.x;
    lines = aRect.size.height;
    stride = size.width - aRect.size.width;
    while(lines--) {
        for(i=aRect.size.width; i; i--) {
            *start++ = aColor;
        }
        start += stride;
    }
    [self remapRect:&aRect];
    [target lockFocus];
    //[[NSColor colorWithCalibratedRed:(float) aColor/27296.0 green:(float) aColor/27296.0 blue:(float) aColor/27296.0 alpha:1.0] set];
    [[NSColor whiteColor] set];
    NSRectFill(aRect);
    [target unlockFocus];
}
    */

/* --------------------------------------------------------------------------------- */
- (void)putRect:(NSRect)aRect withColors:(FrameBufferPaletteIndex*)data fromPalette:(FrameBufferColor*)palette
{
/*
	FBColor*		start;
	unsigned int	stride, i, lines;

    start = pixels + (int)(aRect.origin.y * size.width) + (int)aRect.origin.x;
    lines = aRect.size.height;
    stride = size.width - aRect.size.width;
    while(lines--) {
        for(i=aRect.size.width; i; i--) {
            *start++ = *((FBColor*)(palette + *data));
			data++;
        }
        start += stride;
    }
    */
    return;
}

/* --------------------------------------------------------------------------------- */
- (void)putRun:(FrameBufferColor*)frameBufferColor ofLength:(int)length at:(NSRect)aRect pixelOffset:(int)offset
{
/*
	FBColor*		start;
	unsigned int	stride, width;
	unsigned int	offLines, offPixels;

	offLines = offset / (int)aRect.size.width;
	offPixels = offset - (offLines * (int)aRect.size.width);
	width = aRect.size.width - offPixels;
	offLines += aRect.origin.y;
	offPixels += aRect.origin.x;
	start = pixels + (int)(offLines * size.width + offPixels);
    stride = size.width - aRect.size.width;
	if(width > length) {
		width = length;
	}
	do {
		length -= width;
		while(width--) {
			*start++ = *((FBColor*)frameBufferColor);
		}
		start += stride;
		width = aRect.size.width;
		if(width > length) {
			width = length;
		}
	} while(width > 0);
        */
        return;
}

/* --------------------------------------------------------------------------------- 
*/
- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue
{
    [self fillRect:aRect withNSColor:[self nsColorFromPixel24:pixValue]];
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
        case 4:
                return [NSColor colorWithCalibratedRed:(float) colorData[0]/255.0 green:(float) colorData[1]/255.0 blue:(float) colorData[2]/255.0 alpha:1.0];
        default:
            NSLog(@"Don't know how do to colorFromReversedChars for %d bpp", bpp);
    }
    return nil;
}

- (NSColor *) colorFromReversedChars:(unsigned char*)colorData bytesPerPixel:(int)bpp
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
        case 4:
            return [NSColor colorWithCalibratedRed:(float) colorData[2]/255.0 green:(float) colorData[1]/255.0 blue:(float) colorData[0]/255.0 alpha:1.0];
        default:
            NSLog(@"Don't know how do to colorFromReversedChars for %d bpp", bpp);
    }
    return nil;
}

- (void)fillRect:(NSRect)aRect withPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp
{
    [self fillRect:aRect withNSColor:[self colorFromChars:pixValue bytesPerPixel:bpp]];
}

- (void)fillRect:(NSRect)aRect withReversedPixel:(unsigned char*)pixValue bytesPerPixel:(int)bpp
{
    [self fillRect:aRect withNSColor:[self colorFromReversedChars:pixValue bytesPerPixel:bpp]];
}

/* --------------------------------------------------------------------------------- */
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

/* --------------------------------------------------------------------------------- */
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

/* --------------------------------------------------------------------------------- */
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

/* --------------------------------------------------------------------------------- */
- (void)putRect:(NSRect)aRect fromRGBBytes:(unsigned char*)rgb
{
/*
	FBColor* start;
	unsigned int stride, i, lines, col;

#ifdef PINFO
	putRectCount++;
	pubPixelCount += aRect.size.width * aRect.size.height;
#endif

    start = pixels + (int)(aRect.origin.y * size.width) + (int)aRect.origin.x;
    lines = aRect.size.height;
    stride = size.width - aRect.size.width;
	while(lines--) {
        for(i=aRect.size.width; i; i--) {
			col = redClut[(maxValue * *rgb++) / 255];
			col += greenClut[(maxValue * *rgb++) / 255];
			col += blueClut[(maxValue * *rgb++) / 255];
			*start++ = col;
		}
		start += stride;
	}
        */
        return;
}

/* --------------------------------------------------------------------------------- */

- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data
{
    FBColor* start;
    unsigned int stride, i, lines, pix, col;

    [self remapRect:&aRect];
    [target lockFocus];

#ifdef DEBUG_DRAW
    printf("put x=%f y=%f w=%f h=%f\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
#endif

#ifdef PINFO
    putRectCount++;
    putPixelCount += aRect.size.width * aRect.size.height;
#endif

    switch(pixelFormat.bitsPerPixel / 8) {
        case 1:
            NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 2, 1, 8, aRect.size.width * 1, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
            break;
        case 2:
            if(pixelFormat.bigEndian) {
                while(lines--) {
                    for(i=aRect.size.width; i; i--) {
                        pix = *data++; pix <<= 8; pix += *data++;
                        CLUT(col, pix);
                        *start++ = col;
                    }
                    start += stride;
                }
            } else {
                while(lines--) {
                    for(i=aRect.size.width; i; i--) {
                        pix = *data++; pix += (((unsigned int)*data++) << 8);
                        CLUT(col, pix);
                        *start++ = col;
                    }
                    start += stride;
                }
            }
            break;
        case 4:
            NSDrawBitmap(aRect, aRect.size.width, aRect.size.height, 8, 4, 8 * 4, aRect.size.width * 4, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&data);
            break;
    }
    [target unlockFocus];
}

- (void)putRect:(NSRect)aRect fromReversedData:(unsigned char*)data
{
    unsigned char *fixedData;
    int charCount = aRect.size.width * aRect.size.height * 4;
    int i;
    
    fixedData = malloc(sizeof(unsigned char) * charCount);
    for (i = 0; i < aRect.size.width * aRect.size.height; i++) {
        fixedData[i * 4] = data[i * 4 + 2];
        fixedData[i * 4 + 1] = data[i * 4 + 1];
        fixedData[i * 4 + 2] = data[i * 4 + 0];
    }
    [self putRect:aRect fromData:fixedData];
    free(fixedData);
}

/* --------------------------------------------------------------------------------- */
- (void)drawRect:(NSRect)aRect at:(NSPoint)aPoint
{
/*
    NSRect r;
    int bpr;
    FBColor* start;

#ifdef DEBUG_DRAW
printf("draw x=%f y=%f w=%f h=%f at x=%f y=%f\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height, aPoint.x, aPoint.y);
#endif

#ifdef PINFO
    drawRectCount++;
    drawPixelCount += aRect.size.width * aRect.size.height;
#endif
    //return;
    r = aRect;
    if(NSMaxX(r) >= size.width) {
        r.size.width = size.width - r.origin.x;
    }
    if(NSMaxY(r) >= size.height) {
        r.size.height = size.height - r.origin.y;
    }
    start = pixels + (int)(aRect.origin.y * size.width) + (int)aRect.origin.x;
    r.origin = aPoint;
    if((aRect.size.width * aRect.size.height) > SCRATCHPAD_SIZE) {
        bpr = size.width * [self getPixelSize];
        NSDrawBitmap(r, r.size.width, r.size.height, bitsPerColor, samplesPerPixel, [self getPixelSize] * 8, bpr, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&start);
    } else {
        FBColor* sp = scratchpad;
        int lines = r.size.height;
        int stride = (unsigned int)size.width - (unsigned int)r.size.width;

        while(lines--) {
            memcpy(sp, start, r.size.width * sizeof(sp));
            start += (unsigned int) r.size.width;
            sp += (unsigned int) r.size.width;
            start += stride;
        }
        bpr = r.size.width * [self getPixelSize];
        NSDrawBitmap(r, r.size.width, r.size.height, bitsPerColor, samplesPerPixel, [self getPixelSize] * 8, bpr, NO, NO, NSDeviceRGBColorSpace, (const unsigned char**)&scratchpad);
    }
*/
return;
}


/*
NSDrawBitmap

Summary: This function draws a bitmap image.

Declared in: AppKit/NSGraphics.h

Synopsis: void NSDrawBitmap(const NSRect *rect, int pixelsWide, int
pixelsHigh, int bitsPerSample, int
samplesPerPixel, int bitsPerPixel, int bytesPerRow, BOOL isPlanar, BOOL
hasAlpha, NSColorSpace colorSpace,
const unsigned char *const data[5])


Warning: This function is marginally obsolete. Most applications are better
served using the NSBitmapImageRep class to read
and display bitmap images.


Description: The NSDrawBitmap function renders an image from a bitmap, binary
data that describes the pixel values for the
image (this function replaces NSImageBitmap).

NSDrawBitmap renders a bitmap image using an appropriate PostScript
operator-image, colorimage, or alphaimage. It puts
the image in the rectangular area specified by its first argument, rect; the
rectangle is specified in the current coordinate system
and is located in the current window. The next two arguments, pixelsWide and
pixelsHigh, give the width and height of the
image in pixels. If either of these dimensions is larger or smaller than the
corresponding dimension of the destination rectangle,
the image will be scaled to fit.

The remaining arguments to NSDrawBitmap describe the bitmap data, as explained
in the following paragraphs.

bitsPerSample is the number of bits per sample for each pixel and
samplesPerPixel is the number of samples per pixel.
bitsPerPixel is based on samplesPerPixel and the configuration of the bitmap:
if the configuration is planar, then the value
of bitsPerPixel should equal the value of bitsPerSample; if the configuration
isn't planar (is meshed instead),
bitsPerPixel should equal bitsPerSample * samplesPerPixel.

bytesPerRow is calculated in one of two ways, depending on the configuration
of the image data (data configuration is
described below). If the data is planar, bytesPerRow is (7 + (pixelsWide *
bitsPerSample)) / 8. If the data is meshed,
bytesPerRow is (7 + (pixelsWide * bitsPerSample * samplesPerPixel)) / 8.

A sample is data that describes one component of a pixel. In an RGB color
system, the red, green, and blue components of a
color are specified as separate samples, as are the cyan, magenta, yellow, and
black components in a CMYK system. Color
values in a gray scale are a single sample. Alpha values that determine
transparency and opaqueness are specified as a coverage
sample separate from color. In bitmap images with alpha, the color (or gray)
components have to be premultiplied with the
alpha. This is the way images with alpha are displayed, this is the way they
are read back, and this is the way they are stored in
TIFFs.

isPlanar refers to the way data is configured in the bitmap. This flag should
be set YES if a separate data channel is used for
each sample. The function provides for up to five channels, data1, data2,
data3, data4, and data5. It should be set NO
if sample values are interwoven in a single channel (meshed); all values for
one pixel are specified before values for the next
pixel.

Gray-scale windows store pixel data in planar configuration; color windows
store it in meshed configuration. NSDrawBitmap
can render meshed data in a planar window, or planar data in a meshed window.
However, it's more efficient if the image has a
depth (bitsPerSample) and configuration (isPlanar) that matches the window.

hasAlpha indicates whether the image contains alpha. If it does, the number of
samples should be 1 greater than the number of
color components in the model (e.g., 4 for RGB).

colorSpace can be NS_CustomColorSpace, indicating that the image data is to be
interpreted according to the current color
space in the PostScript graphics state. This allows for imaging using custom
color spaces. The image parameters supplied as the
other arguments should match what the color space is expecting.

If the image data is planar, data[0] through data[samplesPerPixel-1] point to
the planes; if the data is meshed, only
data[0] needs to be set.
*/


@end
