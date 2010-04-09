VERBOSE=0
SDKVER=3.1
PLATFORM=/Developer/Platforms/iPhoneSimulator.platform/Developer
SDK=$(PLATFORM)/SDKs/iPhoneSimulator$(SDKVER).sdk
SIM=../iphonesim/build/Release/iphonesim
IBC_MINIMUM_COMPATIBILITY_VERSION=$(SDKVER)
export IBC_MINIMUM_COMPATIBILITY_VERSION

CC=${PLATFORM}/usr/bin/gcc
CFLAGS=-Wall -g -std=c99 -arch i386 \
	-I${SDK}/usr/include -I. -I../Source \
	-F$(SDK)/System/Library/Frameworks \
	-miphoneos-version-min=3.1
LDFLAGS=-g \
	-arch i386 \
	-F$(SDK)/System/Library/Frameworks \
	-framework CoreFoundation \
	-framework Foundation \
	-framework UIKit \
	-framework CoreGraphics \
	-lz

all: $(SIM) cotvnc-iphone.app

test: all

sim: cotvnc-iphone.sim

clean:
	rm -f *~ .*~ ../.*~ ../*/.*~ ../*/*~ \
		*.o */*.o ../*/*.o \
		*.nib cotvnc-iphone \
		*.xcodeproj/*.mode1v3 *.xcodeproj/*.pbxuser
	rm -rf cotvnc-iphone.app *.dSYM build
	git clean -fdX ../iphonesim

cotvnc-iphone: \
	$(patsubst %.c,%.o, \
		$(shell cat ../libjpeg/FILES | sed 's,^,../libjpeg/,')) \
	$(patsubst %.c,%.o, $(wildcard ../Source/*.c)) \
	$(patsubst %.m,%.o, $(wildcard ../Source/*.m)) \
	$(patsubst %.m,%.o, $(wildcard *.m))

cotvnc-iphone.app: cotvnc-iphone \
	MainWindow.nib \
	Info.plist

$(SIM): $(wildcard ../iphonesim/Source/*.h ../iphonesim/Source/*.m)
	cd ../iphonesim && xcodebuild
	
%.nib: %.xib
	ibtool --errors --warnings --notices \
		--output-format human-readable-text \
		--compile \
		$@ \
		$<
	

ifeq (${VERBOSE},1)
define compile
	$(CC) $(CFLAGS) -c -o $@ $<
endef
else
define compile
	@echo " CC  $@"
	@$(CC) $(CFLAGS) -c -o $@ $<
endef
endif

%.o: %.m
	$(compile)

%.o: %.c
	$(compile)

%: %.o
ifeq (${VERBOSE},1)
	$(CC) $(LDFLAGS) -o $@ $^
else
	@echo "LINK $@"
	@$(CC) $(LDFLAGS) -o $@ $^
endif
	
%.app: %
	rm -rf $@ $@.new $@.dSYM
	mkdir $@.new $@.dSYM
	dsymutil $< -o $@.dSYM
	cp $^ $@.new/
	mv $@.new $@

%.sim: %.app $(SIM)
	$(SIM) launch ${PWD}/$*.app $(SDKVER) &
	sleep 2
