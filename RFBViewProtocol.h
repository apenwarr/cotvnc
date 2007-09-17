#import <CoreGraphics/CoreGraphics.h>

@class RFBConnection;

@protocol RFBViewProtocol

- (void)setRemoteDisplaySize:(CGSize)remoteSize;
- (void)setFrameBuffer:(id)aBuffer;
- (void)setConnection:(RFBConnection *)connection;
- (RFBConnection *)connection;
- (void)displayFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;
- (CGRect)contentRect;

@end


