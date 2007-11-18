//
//  VNCBackgroundView.m
//  vnsea
//
//  Created by Glenn Kreisel on 10/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VNCBackgroundView.h"

#define H_PSIZE 10
#define V_PSIZE 10
#define H_PATTERN_SIZE 10
#define V_PATTERN_SIZE 10

void MyDrawColoredPattern (void *info, CGContextRef myContext)
{
    float subunit = H_PSIZE / 2; // the pattern cell itself is 16 by 18
 
    CGRect  myRect1 = {{0,0}, {subunit, subunit}},
            myRect2 = {{subunit, subunit}, {subunit, subunit}},
            myRect3 = {{0,subunit}, {subunit, subunit}},
            myRect4 = {{subunit,0}, {subunit, subunit}};
 
    CGContextSetRGBFillColor (myContext, .8, .8, .8, 1);
    CGContextFillRect (myContext, myRect1);
    CGContextSetRGBFillColor (myContext, .8, .8, .8, 1);
    CGContextFillRect (myContext, myRect2);
    CGContextSetRGBFillColor (myContext, 1, 1, 1, 1);
    CGContextFillRect (myContext, myRect3);
    CGContextSetRGBFillColor (myContext, 1, 1, 1, 1);
    CGContextFillRect (myContext, myRect4);
}

@implementation VNCBackgroundView

- (id)initWithFrame:(CGRect)frame;
{
	if ([super initWithFrame:frame])
	{
	}
	return self;
}

- (void)drawRect:(CGRect)destRect
{
	CGContextRef myContext = UICurrentContext();
	CGRect rcElipse = [self bounds];
		
    CGPatternRef    pattern;// 1
    CGColorSpaceRef patternSpace;// 2
    float           alpha = 1;
    static const    CGPatternCallbacks callbacks = {0, // 5
                                        &MyDrawColoredPattern,
                                        NULL};
 
    CGContextSaveGState (myContext);
    patternSpace = CGColorSpaceCreatePattern (NULL);// 6
    CGContextSetFillColorSpace (myContext, patternSpace);// 7
    CGColorSpaceRelease (patternSpace);// 8
 
    pattern = CGPatternCreate (NULL, // 9
                    CGRectMake (0, 0, H_PSIZE, V_PSIZE),// 10
                    CGAffineTransformMake (1, 0, 0, 1, 0, 0),// 11
                    H_PATTERN_SIZE, // 12
                    V_PATTERN_SIZE, // 13
                    kCGPatternTilingConstantSpacing,// 14
                    true, // 15
                    &callbacks);// 16
 
    CGContextSetFillPattern (myContext, pattern, &alpha);// 17
    CGPatternRelease (pattern);// 18
    CGContextFillRect (myContext, rcElipse);// 19
    CGContextRestoreGState (myContext);
}
@end
