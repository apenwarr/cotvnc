

@class RFBConnection;

@protocol RFBViewProtocol

- (void)setRemoteDisplaySize:(CGSize)remoteSize;
- (void)setFrameBuffer:(id)aBuffer;
- (void)setConnection:(RFBConnection *)connection;
- (RFBConnection *)connection;
- (void)drawRect:(CGRect)aRect;
- (void)displayFromBuffer:(CGRect)aRect;
- (void)drawRectList:(id)aList;

@end


