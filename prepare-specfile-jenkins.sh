#!/bin/bash
# prepare-specfile-jenkins.sh
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
#Broken by Jenkins 1.597
#TIMESTAMP=`echo $BUILD_ID | sed 's/[_-]//g'`
TIMESTAMP=`date -u +%Y-%m-%dT%H.%M.%S`
GITSTAMP=`cut -f2 -d'/' mono/mini/version.h | sed 's/\"//'`

echo "Building spec file"
rm -f ${MONO_ROOT}/../${TIMESTAMP}
cd ${MONO_ROOT}
sed "s/%SNAPVER%/$TIMESTAMP/g" ${PACKAGING_ROOT}/mono-snapshot.spec.in > ${MONO_ROOT}/../mono-snapshot-${TIMESTAMP}.spec
sed -i "s/%GITVER%/$GITSTAMP/g" ${MONO_ROOT}/../mono-snapshot-${TIMESTAMP}.spec
sed "s/%SNAPVER%/$TIMESTAMP/g" ${PACKAGING_ROOT}/debian/environment.in > ${MONO_ROOT}/../${TIMESTAMP}
sed -i "s/%GITVER%/$GITSTAMP/g" ${MONO_ROOT}/../${TIMESTAMP}
mv ../mono*tar.bz2 ../mono-snapshot-${TIMESTAMP}.tar.bz2
