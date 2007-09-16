
CC=/usr/local/arm-apple-darwin/bin/arm-apple-darwin-cc

LD=$(CC)

LDFLAGS=-lobjc -lz -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework CoreGraphics -framework GraphicsServices

CFLAGS=-I. -Icotvnc


APP_OBJS=\
	mainapp.o \
	VnseaApp.o \
	VNCView.o \
	VNCServerInfoView.o \
	VNCServerListView.o 
#	VNCContentView.o
#	Shimmer.o

VNC_OBJS=\
	cotvnc/Profile.o \
	cotvnc/FrameBuffer.o \
	cotvnc/PrefController.o \
	cotvnc/PrefController_private.o \
	cotvnc/vncauth.o \
	cotvnc/d3des.o \
	cotvnc/RectangleList.o \
	cotvnc/debug.o \
	cotvnc/NSObject_Chicken.o \
	cotvnc/KeyChain.o \
	cotvnc/ByteReader.o \
	cotvnc/ByteBlockReader.o \
	cotvnc/CARD16Reader.o \
	cotvnc/CARD32Reader.o \
	cotvnc/CARD8Reader.o \
	cotvnc/FrameBufferUpdateReader.o \
	cotvnc/NLTStringReader.o \
	cotvnc/RFBServerInitReader.o \
	cotvnc/RFBStringReader.o \
	cotvnc/RREEncodingReader.o \
	cotvnc/ServerCutTextReader.o \
	cotvnc/SetColorMapEntriesReader.o \
	cotvnc/ZipLengthReader.o \
	cotvnc/CoRREEncodingReader.o \
	cotvnc/CopyRectangleEncodingReader.o \
	cotvnc/EncodingReader.o \
	cotvnc/HextileEncodingReader.o \
	cotvnc/RawEncodingReader.o \
	cotvnc/TightEncodingReader.o \
	cotvnc/ZRLEEncodingReader.o \
	cotvnc/ZlibEncodingReader.o \
	cotvnc/ZlibHexEncodingReader.o \
	cotvnc/FilterReader.o \
	cotvnc/CopyFilter.o \
	cotvnc/GradientFilter.o \
	cotvnc/PaletteFilter.o \
	cotvnc/TrueColorFrameBuffer.o \
	cotvnc/LowColorFrameBuffer.o \
	cotvnc/HighColorFrameBuffer.o \
	cotvnc/GrayScaleFrameBuffer.o \
	cotvnc/ServerBase.o \
	cotvnc/ServerStandAlone.o \
	cotvnc/ServerFromPrefs.o \
	cotvnc/RFBProtocol.o \
	cotvnc/RFBHandshaker.o \
	cotvnc/QueuedEvent.o \
	cotvnc/EventFilter.o \
	cotvnc/RFBConnection.o

LIBJPEG_OBJS=\
	libjpeg/jcapimin.o \
	libjpeg/jcapistd.o \
	libjpeg/jccoefct.o \
	libjpeg/jccolor.o \
	libjpeg/jcdctmgr.o \
	libjpeg/jchuff.o \
	libjpeg/jcinit.o \
	libjpeg/jcmainct.o \
	libjpeg/jcmarker.o \
	libjpeg/jcmaster.o \
	libjpeg/jcomapi.o \
	libjpeg/jcparam.o \
	libjpeg/jcphuff.o \
	libjpeg/jcprepct.o \
	libjpeg/jcsample.o \
	libjpeg/jctrans.o \
	libjpeg/jdapimin.o \
	libjpeg/jdapistd.o \
	libjpeg/jdatadst.o \
	libjpeg/jdatasrc.o \
	libjpeg/jdcoefct.o \
	libjpeg/jdcolor.o \
	libjpeg/jddctmgr.o \
	libjpeg/jdhuff.o \
	libjpeg/jdinput.o \
	libjpeg/jdmainct.o \
	libjpeg/jdmarker.o \
	libjpeg/jdmaster.o \
	libjpeg/jdmerge.o \
	libjpeg/jdphuff.o \
	libjpeg/jdpostct.o \
	libjpeg/jdsample.o \
	libjpeg/jdtrans.o \
	libjpeg/jerror.o \
	libjpeg/jfdctflt.o \
	libjpeg/jfdctfst.o \
	libjpeg/jfdctint.o \
	libjpeg/jidctflt.o \
	libjpeg/jidctfst.o \
	libjpeg/jidctint.o \
	libjpeg/jidctred.o \
	libjpeg/jmemmgr.o \
	libjpeg/jmemnobs.o \
	libjpeg/jquant1.o \
	libjpeg/jquant2.o \
	libjpeg/jutils.o

all:    vnsea

vnsea:  $(APP_OBJS) $(VNC_OBJS) $(LIBJPEG_OBJS)
	$(LD) $(LDFLAGS) -v -o $@ $^
	cp vnsea VNsea.app

%.o:    %.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o:    %.c
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
		rm -f *.o cotvnc/*.o libjpeg/*.o vnsea
