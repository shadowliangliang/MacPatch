#!/bin/bash
#
# -------------------------------------------------------------
# Script: buildLinuxPKG.sh
# Version: 1.0.1
#
# Description:
# This script will create a binary distribution package for
# redhat or ubuntu
#
# History:
# 1.0.0:	Initial Creation
# 1.0.1:	Added RPM
#
# -------------------------------------------------------------

usage() { echo "Usage: $0 [-n <pkg name>] [-v <pkg version>] [-a <pkg author name>] [-e <pkg author email>]" 1>&2; exit 1; }

# Defaults
PKG_NAME="MacPatch Server"
PKG_VERSION="2.8.0"
PKG_AUTHOR="John Smith"
PKG_AUTHOR_EMAIL="jsmith@example.com"
PKG_LICENSE="GPLv2"
LNXDISTRO="NA"
XOSTYPE=`uname -s`
MPBASE="/Library/MacPatch"
MPGITDIR="${MPBASE}/tmp/MacPatch"

if [ "`whoami`" != "root" ] ; then   # If not root user,
   # Run this script again as root
   echo
   echo "You must be an admin user to run this script."
   echo "Please re-run the script using sudo."
   echo
   exit 1;
fi

if ! which fpm >/dev/null; then
    echo
  	echo "fpm must be installed in order to run this script."
    exit 1
fi

if [ $XOSTYPE == "Linux" ]; then
	if [ -f "/etc/redhat-release" ]; then
		LNXDISTRO="redhat"
	elif [[ -r /etc/os-release ]]; then
		. /etc/os-release
	    if [[ $ID = ubuntu ]]; then
	    	LNXDISTRO="ubuntu"
	    fi
	fi
else
	echo "Not a linux based system."
	exit 1;
fi

while getopts ":n:v:a:e:h" opt; do
	case $opt in
		n)
			PKG_NAME="$OPTARG"
			;;
		v)
			PKG_VERSION="$OPTARG"
			;;
		a)
			PKG_VERSION="$OPTARG"
			;;
		e)
			PKG_VERSION="$OPTARG"
			;;
		h)
			echo
			usage
			exit 1
			;;
		\?)
			echo
			echo "Invalid option: -$OPTARG" >&2
			echo
			usage
			exit 1
			;;
		:)
			echo
			echo "Option -$OPTARG requires an argument." >&2
			echo 
			usage
			exit 1
			;;
	esac
done

if [ "$LNXDISTRO" == "ubuntu" ]; then

	fpm -s dir -t deb \
	-a amd64 \
	-n "$PKG_NAME" \
	-v "$PKG_VERSION-ubuntu" \
	-m "$PKG_AUTHOR <$PKG_AUTHOR_EMAIL>" \
	--deb-no-default-config-files \
	--license "$PKG_LICENSE" \
	--category misc \
	--depends "python" \
	--depends "python-pip" \
	--depends "openjdk-8-jdk" \
	--after-install "${MPGITDIR}/MacPatch PKG/Linux/scripts/postinstall.sh" \
	--prefix /Library \
	-C /_Library MacPatch

elif [ "$LNXDISTRO" == "redhat" ]; then

	fpm -s dir -t rpm \
	-a amd64 \
	-n "$PKG_NAME" \
	-v "$PKG_VERSION-ubuntu" \
	-m "$PKG_AUTHOR <$PKG_AUTHOR_EMAIL>" \
	--license "$PKG_LICENSE" \
	--depends "python" \
	--depends "python-pip" \
	--depends "java-1.8.0-openjdk-devel" \
	--after-install "${MPGITDIR}/MacPatch PKG/Linux/scripts/postinstall.sh" \
	--prefix /Library \
	-C /_Library MacPatch
	
else
	echo
	echo "Unsupported Linux Distribution"
	echo
	exit 1
fi
