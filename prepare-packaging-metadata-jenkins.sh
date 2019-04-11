#!/bin/bash
# prepare-packaging-metadata-jenkins.sh
# Copyright 2012 Jo Shields
# Copyright 2014 Xamarin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


PACKAGING_ROOT="$( cd "$( dirname "$0" )" && pwd )"
MONO_ROOT=${PACKAGING_ROOT}/../../
BUILD_ARCH=$(dpkg-architecture -qDEB_BUILD_ARCH)
#Broken by Jenkins 1.597
#TIMESTAMP=`echo $BUILD_ID | sed 's/[_-]//g'`
TIMESTAMP=`date -u +%Y.%m.%d+%H.%M.%S`
GITSTAMP=`cut -f1 -d'/' mono/mini/version.h | sed 's/\"//; s/.* //'`

echo "Building debian/ folder"
rm -rf ${MONO_ROOT}/debian/
cp -r ${PACKAGING_ROOT}/debian ${MONO_ROOT}
cd ${MONO_ROOT}
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/mono-snapshot.prerm.in > debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.prerm
sed -i "s/%GITVER%/$GITSTAMP/g" debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.prerm
rm -f debian/mono-snapshot.prerm.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/mono-snapshot.postinst.in > debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.postinst
sed -i "s/%GITVER%/$GITSTAMP/g" debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.postinst
rm -f debian/mono-snapshot.postinst.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/control.in > debian/control
sed -i "s/%GITVER%/$GITSTAMP/g" debian/control
rm -f debian/control.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/environment.in > debian/${TIMESTAMP}
sed -i "s/%GITVER%/$GITSTAMP/g" debian/${TIMESTAMP}
rm -f debian/environment.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/install-unmanaged.in > debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.install
sed -i "s/%GITVER%/$GITSTAMP/g" debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}.install
rm -f debian/install-unmanaged.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/install-managed.in > debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}-assemblies.install
sed -i "s/%GITVER%/$GITSTAMP/g" debian/mono-snapshot-${GITSTAMP}-${TIMESTAMP}-assemblies.install
rm -f debian/install-managed.in
mkdir -p debian/runtimes.d
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/gacinstall.in > debian/runtimes.d/mono-${GITSTAMP}-${TIMESTAMP}
sed -i "s/%GITVER%/$GITSTAMP/g" debian/runtimes.d/mono-${GITSTAMP}-${TIMESTAMP}
chmod a+x debian/runtimes.d/mono-${GITSTAMP}-${TIMESTAMP}
rm -f debian/gacinstall.in
sed "s/%SNAPVER%/$TIMESTAMP/g" debian/rules.in > debian/rules
sed -i "s/%GITVER%/$GITSTAMP/g" debian/rules
chmod a+x debian/rules
echo "3.0 (quilt)" > debian/source/format
rm -f debian/rules.in
DEBEMAIL="Xamarin Public Jenkins <jo.shields@xamarin.com>" \
	dch --create --distribution unstable --package mono-snapshot-${GITSTAMP}-${TIMESTAMP} --newversion 1:${TIMESTAMP}-1 \
	--force-distribution --empty "Git snapshot (Pull Request ${GITSTAMP})"
#rm -fr ${PACKAGING_ROOT}/temp
#mkdir -p ${PACKAGING_ROOT}/temp
#tar xf ${MONO_ROOT}/mono*tar* -C ${PACKAGING_ROOT}/temp
#mv ${PACKAGING_ROOT}/temp/mono* ${PACKAGING_ROOT}/temp/mono-snapshot-${TIMESTAMP}
#mv debian ${PACKAGING_ROOT}/temp/mono-snapshot-${TIMESTAMP}
#cd ${MONO_ROOT}
mv ../mono*tar.xz ../mono-snapshot-${GITSTAMP}-${TIMESTAMP}_${TIMESTAMP}.orig.tar.xz
