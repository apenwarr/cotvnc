//
//  FrameBuffer+Drawing.h
//  Chicken of the VNC
//
//  Created by Kurt Werle on Sat Mar 01 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FrameBuffer.h"

@interface FrameBuffer(Drawing)


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
