/* LowColorFrameBuffer.m created by helmut on Wed 23-Jun-1999 */

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

#import "LowColorFrameBuffer.h"

//typedef	unsigned char			FBColor;

@implementation LowColorFrameBuffer

- (id)initWithSize:(NSSize)aSize andFormat:(rfbPixelFormat*)theFormat
{
    if (self = [super initWithSize:aSize andFormat:theFormat]) {
		unsigned int sps;
			
		rshift = 6;
		gshift = 4;
		bshift = 2;
		maxValue = 3;
		samplesPerPixel = 3;
		bitsPerColor = 2;
		[self setPixelFormat:theFormat];
	}
    return self;
}

- (int)getPixelSize
{
    return sizeof(unsigned char);
}

+ (void)getPixelFormat:(rfbPixelFormat*)aFormat
{
   aFormat->bitsPerPixel = 8;
   aFormat->redMax = aFormat->greenMax = aFormat->blueMax = 3;
   aFormat->redShift = 6;
   aFormat->greenShift = 4;
   aFormat->blueShift = 2;
   aFormat->depth = 8;
}

/*
- (void)putRect:(NSRect)aRect fromData:(unsigned char*)data
{
    unsigned char* start;
    unsigned int stride, i, lines, pix, col;
    
    #ifdef DEBUG_DRAW
    printf("put x=%f y=%f w=%f h=%f\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
    #endif
    
    #ifdef PINFO
    putRectCount++;
    putPixelCount += aRect.size.width * aRect.size.height;
    #endif
    
    start = pixels + (int)(aRect.origin.y * size.width) + (int)aRect.origin.x;
    lines = aRect.size.height;
    stride = size.width - aRect.size.width;
    
        switch(pixelFormat.bitsPerPixel / 8) {
                case 1:
                        while(lines--) {
                                for(i=aRect.size.width; i; i--) {
                                        pix = *data++;
                                        CLUT(col, pix);
                                        *start++ = col;
                                }
                                start += stride;
                        }
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
                        if(pixelFormat.bigEndian) {
                                while(lines--) {
                                        for(i=aRect.size.width; i; i--) {
                                                pix = *data++; pix <<= 8;
                                                pix += *data++; pix <<= 8;
                                                pix += *data++; pix <<= 8;
                                                pix += *data++;
                                                CLUT(col, pix);
                                                *start++ = col;
                                        }
                                        start += stride;
                                }
                        } else {
                                while(lines--) {
                                        for(i=aRect.size.width; i; i--) {
                                                pix = *data++;
                                                pix += (((unsigned int)*data++) << 8);
                                                pix += (((unsigned int)*data++) << 16);
                                                pix += (((unsigned int)*data++) << 24);
                                                CLUT(col, pix);
                                                *start = col;
                                                start += [self getPixelSize];
                                        }
                                        start += stride;
                                }
                        }
                        break;
        }
return;
}
*/

#include "FrameBufferDrawing.h"

@end
