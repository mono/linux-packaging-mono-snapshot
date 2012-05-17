#!/bin/bash

CHECKOUT_ROOT="$HOME/Projects/mono-snapshot/monogit"
PACKAGING_ROOT="$HOME/Projects/mono-snapshot/debgit"
BUILD_ROOT="$HOME/Projects/mono-snapshot/mono-snapshot-git"
BUILD_ARCH=$(dpkg-architecture -qDEB_BUILD_ARCH)
if [ "x$BUILD_ARCH" != "xamd64" ]
then
	DEBBUILDFLAGS="-B"
fi

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

function clean
{
	echo "Removing crud"
	rm -fr $BUILD_ROOT
}

function download_mono
{
	echo "Updating Mono repository from Github"
	if [ -d $CHECKOUT_ROOT ] ; then
		cd $CHECKOUT_ROOT; git pull || error_exit "Cannot update mono"
	else
		git clone git@github.com:mono/mono $CHECKOUT_ROOT || error_exit "Cannot checkout mono"
	fi
	TIMESTAMP=`date --date="@$(git log -n1 --format="%at")" +%Y%m%d%H%M%S`
	GITSTAMP=`git log -n1 --format="%H"`
}

function download_packagecraft
{
	echo "Updating packaging repository from Github"
	if [ -d $PACKAGING_ROOT ] ; then
		cd $PACKAGING_ROOT; git pull || error_exit "Cannot update packaging"
	else
		git clone git@github.com:directhex/mono-snapshot $PACKAGING_ROOT || error_exit "Cannot checkout packaging"
	fi
}

function generate_orig
{
	echo "Generating mono-snapshot-$TIMESTAMP orig"
	cd $CHECKOUT_ROOT 
	./autogen.sh
	make
	make dist
	mv mono*tar.bz2 ../
	cd ..
	tar xvf mono*tar.bz2
	rm mono*tar.bz2
	mv mono-* mono-snapshot-git
	tar cjvf mono-snapshot-${TIMESTAMP}_${TIMESTAMP}.orig.tar.bz2 mono-snapshot-git/
}

function prep_debian_folder
{
	echo "Building debian/ folder"
	cp -r $PACKAGING_ROOT/debian $BUILD_ROOT
	cd $BUILD_ROOT
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/mono-snapshot.prerm.in > debian/mono-snapshot-${TIMESTAMP}.prerm
	rm -f debian/mono-snapshot.prerm.in
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/mono-snapshot.postinst.in > debian/mono-snapshot-${TIMESTAMP}.postinst
	rm -f debian/mono-snapshot.postinst.in
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/control.in > debian/control
	sed -i "s/%GITVER%/$GITSTAMP/g" debian/control
	rm -f debian/control.in
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/environment.in > debian/${TIMESTAMP}
	rm -f debian/environment.in
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/install.in > debian/mono-snapshot-${TIMESTAMP}.install
	rm -f debian/install.in
	mkdir -p debian/runtimes.d
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/gacinstall.in > debian/runtimes.d/mono-${TIMESTAMP}
	sed -i "s/%GITVER%/$GITSTAMP/g" debian/runtimes.d/mono-${TIMESTAMP}
	chmod a+x debian/runtimes.d/mono-${TIMESTAMP}
	rm -f debian/gacinstall.in
	sed "s/%SNAPVER%/$TIMESTAMP/g" debian/rules.in > debian/rules
	chmod a+x debian/rules
	rm -f $BUILD_ROOT/debian/rules.in
	DEBEMAIL="Xamarin MonkeyWrench <directhex@apebox.org>" \
		dch --create --distribution unstable --package mono-snapshot-${TIMESTAMP} --newversion ${TIMESTAMP}-1 \
		--force-distribution --empty "Git snapshot (commit ID ${GITSTAMP})"
}

function build_deb_src
{
	echo "Building Debian source package"
	cd $BUILD_ROOT
	debuild -S -us -uc
}

function build_deb
{
	echo "Building Debian binary package"
	cd $BUILD_ROOT
	dpkg-buildpackage ${DEBBUILDFLAGS} -us -uc -rfakeroot
}

clean
download_mono
download_packagecraft
generate_orig
prep_debian_folder
#build_deb_src
build_deb
