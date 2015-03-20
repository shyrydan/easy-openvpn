# easy-openvpn

`easy-openvpn` is a collection of bash scripts for generating the keys and config files for OpenVPN
This is the first version. There is a lot of room for improvement.
# Usage

*	 `$ sudo apt-get install`
*	 First you should review the variables in build.sh. You may want to change the defaults
*	 `$ ./build.sh`  This will generate the full PKI and the config files
*	 `$ sudo ./install.sh`	This will copy the server files to /etc/openvpn

*	 If you want to generate the config files for another client you use `./buildclient.sh clientname`

