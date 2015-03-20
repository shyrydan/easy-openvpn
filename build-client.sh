#!/bin/bash
if [ "$1" != "" ]; then
	OUTPUTFOLDER=$PWD/out/
	export BASEFILE="$OUTPUTFOLDER/baseclient.base"
	echo "Building $1";
	time nice -n20 ./easyrsa build-client-full $1 nopass
	CLIENTFILE="$OUTPUTFOLDER/$1.conf"
	cp $BASEFILE $CLIENTFILE
	echo "<key>" >>$CLIENTFILE
	cat pki/private/$1.key >>$CLIENTFILE
	echo "</key>" >>$CLIENTFILE
	echo "<cert>" >>$CLIENTFILE
	cat pki/issued/$1.crt | grep -A 100 "BEGIN CERTIFICATE" >>$CLIENTFILE
	echo "</cert>" >>$CLIENTFILE
	echo "Finished building $1"
else
	echo "Use ./build-client.sh clientname"
fi
