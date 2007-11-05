#!/bin/bash

# Script to build the PXL package for vnsea.
#
# Usage: build_pxl.sh <version>

if [ $# -ne 1 ]; then
	echo "Usage: build_pxl.sh <version>"
	exit
fi

# generate package name
package="vnsea_$1.pxl"

# clean up from last build
rm -rf app icon.png

# copy icon file
cp ../VNsea.app/icon.png .

# copy latest build into the app directory
mkdir app
cp -r ../VNsea.app app
find app -name .svn -exec rm -rf '{}' ';' -prune

# delete a previous package with the same name
if [ -e "$package" ]; then
	echo "Deleting old package"
	rm -f $package
fi

# create the package file
zip -r $package icon.png app PxlPkg.plist


