#!/bin/bash

# 参考
# https://www.cnblogs.com/popsuper1982/p/3843772.html

set -ex

info='none'
suffix="$RANDOM"
domain='*.google.com'
[ -n "$1" ] && domain="$1"
[ -n "$2" ] && suffix="$2"


if [ ! -f "./demoCA/cacert.pem" ]; then
	# 建立 CA 目录结构
	mkdir -p ./demoCA/{private,newcerts}
	touch ./demoCA/index.txt
	echo 01 > ./demoCA/serial

	# 生成 CA 的 RSA 密钥对
	openssl genrsa -out ./demoCA/private/cakey.pem 2048

	# 生成 CA 证书请求
	# openssl req -new -days 3650 -key ./demoCA/private/cakey.pem -out careq.pem
	# 自签发 CA 证书
	# openssl ca -selfsign -in careq.pem -out ./demoCA/cacert.pem

	# 以上两步可以合二为一
	openssl req -subj "/C=CN/ST=$info/L=$info/O=$info/OU=$info/CN=$info/emailAddress=$RANDOM@$RANDOM.com" -new -x509 -days 3650 -key ./demoCA/private/cakey.pem -out ./demoCA/cacert.pem
fi

# 生成用户的 RSA 密钥对
openssl genrsa -out "userkey_$suffix.pem"

# 生成用户证书请求
openssl req -subj "/C=CN/ST=$info/L=$info/O=$info/OU=$info/CN=$domain/emailAddress=$RANDOM@$RANDOM.com" -new -key "userkey_$suffix.pem" -out "userreq_$suffix.pem"

# 使用 CA 签发用户证书
openssl ca -batch -in "userreq_$suffix.pem" -out "usercert_$suffix.pem"

set +ex
realpath "userkey_$suffix.pem"
realpath "usercert_$suffix.pem"

exit
