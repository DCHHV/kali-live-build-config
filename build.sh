#!/bin/bash

set -e
set -o pipefail  # Bashism

KALI_DIST="kali-rolling"
KALI_VERSION=""
KALI_VARIANT="default"
IMAGE_TYPE="live"
TARGET_DIR="$(dirname $0)/images"
TARGET_SUBDIR=""
SUDO="sudo"
VERBOSE=""
HOST_ARCH=$(dpkg --print-architecture)

image_name() {
	case "$IMAGE_TYPE" in
		live)
			live_image_name
		;;
		installer)
			installer_image_name
		;;
	esac
}


live_image_name() {
	case "$KALI_ARCH" in
		i386|amd64)
			echo "live-image-$KALI_ARCH.hybrid.iso"
		;;
		armel|armhf)
			echo "live-image-$KALI_ARCH.img"
		;;
	esac
}

installer_image_name() {
	if [ "$KALI_VARIANT" = "default" ]; then
		echo "simple-cdd/images/kali-$KALI_VERSION-$KALI_ARCH-DVD-1.iso"
	else
		echo "simple-cdd/images/kali-$KALI_VERSION-$KALI_ARCH-NETINST-1.iso"
	fi
}

target_image_name() {
	local arch=$1

	IMAGE_NAME="$(image_name $arch)"
	IMAGE_EXT="${IMAGE_NAME##*.}"
	if [ "$IMAGE_EXT" = "$IMAGE_NAME" ]; then
		IMAGE_EXT="img"
	fi
	if [ "$IMAGE_TYPE" = "live" ]; then
		if [ "$KALI_VARIANT" = "default" ]; then
			echo "${TARGET_SUBDIR:+$TARGET_SUBDIR/}kali-linux-$KALI_VERSION-$KALI_ARCH.$IMAGE_EXT"
		else
			echo "${TARGET_SUBDIR:+$TARGET_SUBDIR/}kali-linux-$KALI_VERSION-$KALI_VARIANT-$KALI_ARCH.$IMAGE_EXT"
		fi
	else
		if [ "$KALI_VARIANT" = "default" ]; then
			echo "${TARGET_SUBDIR:+$TARGET_SUBDIR/}kali-linux-$KALI_VERSION-installer-$KALI_ARCH.$IMAGE_EXT"
		else
			echo "${TARGET_SUBDIR:+$TARGET_SUBDIR/}kali-linux-$KALI_VERSION-installer-$KALI_VARIANT-$KALI_ARCH.$IMAGE_EXT"
		fi
	fi
}

target_build_log() {
	TARGET_IMAGE_NAME=$(target_image_name $1)
	echo ${TARGET_IMAGE_NAME%.*}.log
}

default_version() {
	case "$1" in
	    kali-*)
		echo "${1#kali-}"
		;;
	    *)
		echo "$1"
		;;
	esac
}

failure() {
	echo "Build of $KALI_DIST/$KALI_VARIANT/$KALI_ARCH $IMAGE_TYPE image failed (see build.log for details)" >&2
	exit 2
}

run_and_log() {
	if [ -n "$VERBOSE" ]; then
		"$@" 2>&1 | tee -a $BUILD_LOG
	else
		"$@" >>$BUILD_LOG 2>&1
	fi
	return $?
}

. $(dirname $0)/.getopt.sh

# Parsing command line options
temp=$(getopt -o "$BUILD_OPTS_SHORT" -l "$BUILD_OPTS_LONG,get-image-path,installer,no-clean" -- "$@")
eval set -- "$temp"
while true; do
	case "$1" in
		-d|--distribution) KALI_DIST="$2"; shift 2; ;;
		-p|--proposed-updates) OPT_pu="1"; shift 1; ;;
		-a|--arch) KALI_ARCH="$2"; shift 2; ;;
		-v|--verbose) VERBOSE="1"; shift 1; ;;
		-s|--salt) shift; ;;
		--installer) IMAGE_TYPE="installer"; shift 1 ;;
		--variant) KALI_VARIANT="$2"; shift 2; ;;
		--version) KALI_VERSION="$2"; shift 2; ;;
		--subdir) TARGET_SUBDIR="$2"; shift 2; ;;
		--get-image-path) ACTION="get-image-path"; shift 1; ;;
		--no-clean) NO_CLEAN="1"; shift 1 ;;
		--) shift; break; ;;
		*) echo "ERROR: Invalid command-line option: $1" >&2; exit 1; ;;
        esac
done

# Set default values
KALI_ARCH=${KALI_ARCH:-$HOST_ARCH}
if [ -z "$KALI_VERSION" ]; then
	KALI_VERSION="$(default_version $KALI_DIST)"
fi

# Check parameters
if [ "$HOST_ARCH" != "$KALI_ARCH" ]; then
	case "$HOST_ARCH/$KALI_ARCH" in
		amd64/i386|i386/amd64)
		;;
		*)
			echo "Can't build $KALI_ARCH image on $HOST_ARCH system." >&2
			exit 1
		;;
	esac
fi
if [ ! -d "$(dirname $0)/kali-config/variant-$KALI_VARIANT" ]; then
	echo "ERROR: Unknown variant of Kali configuration: $KALI_VARIANT" >&2
fi

# Build parameters for lb config
KALI_CONFIG_OPTS="--distribution $KALI_DIST -- --variant $KALI_VARIANT"
CODENAME=$KALI_DIST  # for simple-cdd/debian-cd
if [ -n "$OPT_pu" ]; then
	KALI_CONFIG_OPTS="$KALI_CONFIG_OPTS --proposed-updates"
	KALI_DIST="$KALI_DIST+pu"
fi

# Set sane PATH (cron seems to lack /sbin/ dirs)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

case "$IMAGE_TYPE" in
	live)
		ver_live_build=$(dpkg-query -f '${Version}' -W live-build)
		if dpkg --compare-versions "$ver_live_build" lt 1:20151215kali1; then
			echo "ERROR: You need live-build (>= 1:20151215kali1), you have $ver_live_build" >&2
			exit 1
		fi
		ver_debootstrap=$(dpkg-query -f '${Version}' -W debootstrap)
		if dpkg --compare-versions "$ver_debootstrap" lt "1.0.97"; then
			echo "ERROR: You need debootstrap (>= 1.0.97), you have $ver_debootstrap" >&2
			exit 1
		fi
	;;
	installer)
		ver_debian_cd=$(dpkg-query -f '${Version}' -W debian-cd)
		if dpkg --compare-versions "$ver_debian_cd" lt 3.1.28~kali1; then
			echo "ERROR: You need debian-cd (>= 3.1.28~kali1), you have $ver_debian_cd" >&2
			exit 1
		fi
		ver_simple_cdd=$(dpkg-query -f '${Version}' -W simple-cdd)
		if dpkg --compare-versions "$ver_simple_cdd" lt 0.6.8~kali1; then
			echo "ERROR: You need simple-cdd (>= 0.6.8~kali1), you have $ver_simple_cdd" >&2
			exit 1
		fi

	;;
esac

# We need root rights at some point
if [ "$(whoami)" != "root" ]; then
	if ! which $SUDO >/dev/null; then
		echo "ERROR: $0 is not run as root and $SUDO is not available" >&2
		exit 1
	fi
else
	SUDO="" # We're already root
fi

if [ "$ACTION" = "get-image-path" ]; then
	echo $(target_image_name $KALI_ARCH)
	exit 0
fi

cd $(dirname $0)
mkdir -p $TARGET_DIR/$TARGET_SUBDIR

IMAGE_NAME="$(image_name $KALI_ARCH)"
set +e
BUILD_LOG=$(pwd)/build.log
: > $BUILD_LOG

case "$IMAGE_TYPE" in
	live)
		if [ "$NO_CLEAN" = "" ]; then
			run_and_log $SUDO lb clean --purge
		fi
		[ $? -eq 0 ] || failure
		run_and_log lb config -a $KALI_ARCH $KALI_CONFIG_OPTS "$@"
		[ $? -eq 0 ] || failure
		run_and_log $SUDO lb build
		if [ $? -ne 0 ] || [ ! -e $IMAGE_NAME ]; then
			failure
		fi
	;;
	installer)
		if [ "$NO_CLEAN" = "" ]; then
			run_and_log $SUDO rm -rf simple-cdd/tmp
		fi

		# Override some debian-cd environment variables
		export ARCHES=$KALI_ARCH
		export ARCH=$KALI_ARCH
		export DEBVERSION=$KALI_VERSION

		if [ "$KALI_VARIANT" = "netinst" ]; then
		    export DISKTYPE="NETINST"
		else
		    export DISKTYPE="DVD"
		fi
		if [ -e .mirror ]; then
		    kali_mirror=$(cat .mirror)
		else
		    kali_mirror=http://archive.kali.org/kali/
		fi
		if ! echo "$kali_mirror" | grep -q '/$'; then
		    kali_mirror="$kali_mirror/"
		fi

		# Configure the kali profile with the packages we want
		grep -v '^#' kali-config/variant-$KALI_VARIANT/package-lists/kali.list.chroot \
		    >simple-cdd/profiles/kali.downloads

		# Run simple-cdd
		cd simple-cdd
		run_and_log build-simple-cdd \
		    --verbose \
		    --debug \
		    --force-root \
		    --conf simple-cdd.conf \
		    --dist $CODENAME \
		    --debian-mirror $kali_mirror
		res=$?
		cd ..
		if [ $res -ne 0 ] || [ ! -e $IMAGE_NAME ]; then
			failure
		fi
	;;
esac

set -e
mv -f $IMAGE_NAME $TARGET_DIR/$(target_image_name $KALI_ARCH)
mv -f $BUILD_LOG $TARGET_DIR/$(target_build_log $KALI_ARCH)
