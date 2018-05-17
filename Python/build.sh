tar xvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config --prefix="$PWD"/out --openssldir="$PWD"/out -static -static-libgcc && make && make install
cd ..

tar xvf Python-3.5.5.tar.xz
cd Python-3.5.5
./configure --prefix="$PWD"/out LDFLAGS="-static -static-libgcc" CPPFLAGS=-static CXXFLAGS=-static CFLAGS="-Os -static" --without-ensurepip --disable-shared

cp Modules/Setup Modules/Setup.bak
cp ../Setup Modules/Setup

make LDFLAGS="-static" LINKFORSHARED=" " && make install && make clean && cp -R out out_orig && cd out/lib/python3.5 && rm -rf distutils ensurepip idlelib lib2to3 && zip -r ../python35.zip * && cd .. && rm -rf python3.5 && cd .. && cd .. && echo done

# note: then run with LANG=C.utf-8 PYTHONIOENCODING=utf-8 PYTHONUTF8=1 PYTHONHOME=. ./python3.5
# where PYTHONHOME is the path to the lib directory






