tar xvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config --prefix="$PWD"/out --openssldir="$PWD"/out -static -static-libgcc && make && make install



