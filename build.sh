#/bin/bash
#CONFIGURATION
export SERVER="server.ip.or.fqdm"
export PORT="1194"

export KEYSIZE=4096
export CIPHER="AES-256-CBC"
export AUTH="SHA256" #HMAC
export SERVERNAME="vpnserver"
export CERTDIGEST="sha512"
export CANAME="vpnca"
export CERTDAYS=3650
export CLIENTS="client1 client2 client3 client4"


echo "set_var EASYRSA_DN	\"cn_only\"" >vars
echo "set_var EASYRSA_KEY_SIZE	$KEYSIZE" >>vars
echo "set_var EASYRSA_ALGO		rsa" >>vars
echo "set_var EASYRSA_CA_EXPIRE	$CERTDAYS" >>vars
echo "set_var EASYRSA_CERT_EXPIRE	$CERTDAYS" >>vars
echo "set_var EASYRSA_REQ_CN		\"$CANAME\"" >>vars
echo "set_var EASYRSA_DIGEST		\"$CERTDIGEST\"" >>vars
echo "set_var EASYRSA_BATCH		\"asdf\"" >>vars

export OUTPUTFOLDER=out
time nice -n20 ./easyrsa init-pki
echo "Building CA"
time nice -n20 ./easyrsa build-ca nopass

echo "Building server"
time nice -n20 ./easyrsa build-server-full $SERVERNAME nopass

echo "Building TLS-KEY"
mkdir $OUTPUTFOLDER
openvpn --genkey --secret $OUTPUTFOLDER/tls.key


echo "Building base config"
export BASEFILE="$OUTPUTFOLDER/baseclient.base"
cp base $BASEFILE
echo "remote $SERVER $PORT" >>$BASEFILE
echo "cipher $CIPHER" >>$BASEFILE
echo "auth $AUTH" >>$BASEFILE
echo "<ca>" >>$BASEFILE
cat pki/ca.crt >>$BASEFILE
echo "</ca>" >>$BASEFILE
echo "<tls-auth>" >>$BASEFILE
cat $OUTPUTFOLDER/tls.key >>$BASEFILE
echo "</tls-auth>" >>$BASEFILE


echo "Bulding keys and configs"
for actual in $CLIENTS
	do echo "Building $actual";
	time nice -n20 ./easyrsa build-client-full $actual nopass
	CLIENTFILE="$OUTPUTFOLDER/$actual.conf"
	cp $BASEFILE $CLIENTFILE
	echo "<key>" >>$CLIENTFILE
	cat pki/private/$actual.key >>$CLIENTFILE
	echo "</key>" >>$CLIENTFILE
	echo "<cert>" >>$CLIENTFILE
	cat pki/issued/$actual.crt | grep -A 100 "BEGIN CERTIFICATE" >>$CLIENTFILE
	echo "</cert>" >>$CLIENTFILE
	echo "Finished building $actual"
done;
echo "Finished building keys and configs"

echo "Building server files"
export SERVERFOLDER="$OUTPUTFOLDER/server"
mkdir $SERVERFOLDER
export SERVERCONFIG="$SERVERFOLDER/server.conf"
cp serverbase $SERVERCONFIG
echo "cipher $CIPHER" >>$SERVERCONFIG
echo "auth $AUTH" >>$SERVERCONFIG
echo "port $PORT" >>$SERVERCONFIG
cp pki/ca.crt $SERVERFOLDER/ca.crt
cp pki/issued/$SERVERNAME.crt $SERVERFOLDER/server.crt
cp pki/private/$SERVERNAME.key $SERVERFOLDER/server.key
cp $OUTPUTFOLDER/tls.key $SERVERFOLDER/tls.key
echo "Last part. Building DH parameters"
openssl dhparam -out $SERVERFOLDER/dh.pem $KEYSIZE
echo "Finished"
