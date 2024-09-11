dx=/c/Users/simon/source/repos/libp11
if [ 0 -eq 1 ]; then
	less $dx/README.md 
fi

unset OPENSSL_CONF
unset PKCS11_MODULE_PATH

echo ""
echo "[WHICH: openssl]"
which openssl

echo ""
echo "[OPENSSL: version -a]"
openssl version -a

echo ""
echo "[OPENSSL: engine -t]"
#openssl engine -t
openssl engine -t pkcs11

pkcs11=/usr/lib/openssl/engines-3/pkcs11.dll
ykcs11=/usr/lib/ossl-modules/libykcs11.dll 
#ykcs11=/usr/lib/ossl-modules/opensc-pkcs11.dll 


echo ""
echo "[OPENSSL: engine dynamic: SO_PATH:$pkcs11 MODULE_PATH:$ykcs11]"
openssl engine dynamic -pre SO_PATH:$pkcs11 -pre ID:pkcs11 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:$ykcs11

dp=/c/Users/simon/OneDrive/Dokumente/PowerShell; 
ENGINE=pkcs11; 
TOKEN=0; 
OBJECT=root_ca_key; 
TYPE=private; 

export OPENSSL_CONF="$(pwd)/x4.cnf"
export PKCS11_MODULE_PATH=$ykcs11

echo "[EXPORT: OPENSSL_CONF:$OPENSSL_CONF PKCS11_MODULE_PATH:$PKCS11_MODULE_PATH]"

#pushd /c/Program\ Files/Yubico/Yubico\ PIV\ Tool/bin
pushd  /usr/lib/ossl-modules

if [ 0 -eq 0 ]; then
	openssl x509 \
		-req \
		-in $dp/xykca_winrm.csr \
		-CA $dp/xykca_certificate.pem \
		-CAkeyform engine \
		-engine $ENGINE \
		-CAkey "pkcs11:token=${TOKEN};object=${OBJECT};type=${TYPE}" \
		-CAcreateserial \
		-out $dp/xykca_winrm.crt \
		-days 365 \
		-sha256

else
	set -x
	windbg.exe \
		-o 'C:\msys64\usr\bin\openssl.exe' \
			x509 \
				-req \
				-in $dp/xykca_winrm.csr \
				-CA $dp/xykca_certificate.pem \
				-CAkeyform engine \
				-engine $ENGINE \
				-CAkey "pkcs11:token=${TOKEN};object=${OBJECT};type=${TYPE}" \
				-CAcreateserial \
				-out $dp/xykca_winrm.crt \
				-days 365 \
				-sha256

	set +x
fi


popd
