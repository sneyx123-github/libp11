export PATH=/usr/bin:$PATH
export PKG_CONFIG_PATH=/mingw64/lib/pkgconfig:$PKG_CONFIG_PATH

if [ 0 -eq 1 ]; then
	make distclear
fi
if [ 0 -eq 1 ]; then
	# TODO: INSTALLROOT from / to /usr
	# 		/lib to /usr/lib
	#
	LIBS="-lssl -lcrypto" LDFLAGS="-L/mingw64/lib" CFLAGS="-I/mingw64/include -g -O0" CXXFLAGS="-g -O0" ./configure
	###	./configure CFLAGS="-g -O0" CXXFLAGS="-g -O0"
	make
	make install
fi
if [ 0 -eq 0 ]; then
	ldd /lib/engines-3/libpkcs11.dll
fi

if [ 0 -eq 0 ]; then
	cp src/.libs/pkcs11.dll /usr/lib/openssl/engines-3/
fi
if [ 0 -eq 0 ]; then
	openssl engine pkcs11 -t
fi

if [ 0 -eq 1 ]; then
	cat <<-END > x3.cnf
	openssl_conf = openssl_init
	
	[openssl_init]
	engines = engine_section
	
	[engine_section]
	pkcs11 = pkcs11_section
	
	[pkcs11_section]
	engine_id = pkcs11
	dynamic_path = /usr/lib/openssl/engines-3/pkcs11.dll 
	MODULE_PATH = /c/Program Files/Yubico/Yubico PIV Tool/bin/libykcs11.dll
	PIN = 654321
	END
elif [ 0 -eq 0 ]; then
	cat <<-END > x3.cnf
	openssl_conf = openssl_init
	
	[openssl_init]
	engines = engine_section
	
	[engine_section]
	pkcs11 = pkcs11_section
	
	[pkcs11_section]
	engine_id = pkcs11
	dynamic_path = pkcs11.dll
	MODULE_PATH = /c/Program Files/Yubico/Yubico PIV Tool/bin/libykcs11.dll
	PIN = 654321
	END
fi


if [ 0 -eq 0 ]; then
	openssl engine dynamic \
		-pre "SO_PATH:/usr/lib/openssl/engines-3/pkcs11.dll" \
		-pre "ID:pkcs11" \
		-pre "LIST_ADD:1" \
		-pre "LOAD" \
		-pre "MODULE_PATH:/c/Program Files/Yubico/Yubico PIV Tool/bin/libykcs11.dll"
fi

if [ 0 -eq 1 ]; then
	openssl req \
		-engine pkcs11 \
		-new \
		-key "pkcs11:object=test-key;type=private;pin-value=654321" \
		-keyform engine \
		-out req.pem \
		-text \
		-x509 \
		-subj "/CN=Simon Y. Ney" \
		-verbose
fi
if [ 0 -eq 1 ]; then
	OBJ_LABEL="test-key"
	OBJ_LABEL="X.509 Certificate for PIV Authentication"
	OBJ_LABEL="Authentication"
	openssl x509 \
		-engine pkcs11 \
		-signkey "pkcs11:object=$OBJ_LABEL;type=private;pin-value=654321" \
		-keyform engine \
		-in req.pem \
		-out cert.pem
fi
if [ 0 -eq 1 ]; then
	OBJ_LABEL="test-key"
	OBJ_LABEL="X.509 Certificate for PIV Authentication"
	OBJ_LABEL="Authentication"
	openssl pkeyutl \
		-engine pkcs11 \
		-keyform engine \
		-inkey "pkcs11:object=$OBJ_LABEL;type=private" \
		-sign \
		-in data.txt \
		-out signature.bin
fi
if [ 0 -eq 1 ]; then
	cp $dp/xykca_certificate.pem .
	cp $dp/xykca_public_key.pem .
	cp $dp/xykca_data.txt .
	cp $dp/xykca_data_signature.bin .
fi

if [ 0 -eq 1 ]; then
	openssl x509 \
		-in xykca_certificate.pem \
		-pubkey \
		-out xykca_public_key.pem 
fi

if [ 0 -eq 1 ]; then
	openssl dgst \
		-verify xykca_public_key.pem \
		-signature xykca_data_signature.bin \
		xykca_data.txt
fi

if [ 0 -eq 1 ]; then
	openssl <<- END
	req -engine pkcs11 -new -key "pkcs11:object=test-key;type=private;pin-value=XXXX" \
			-keyform engine -out req.pem -text -x509 -subj "/CN=Simon Y. Ney"
	x509 -engine pkcs11 -signkey "pkcs11:object=test-key;type=private;pin-value=XXXX" \
			-keyform engine -in req.pem -out cert.pem
	END
fi

# does G_CB works here?

