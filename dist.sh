#!/bin/bash

if [ -e dist ]; then
    rm -rf dist
fi
if [ -e tracker.zip ]; then
    rm tracker.zip
fi
mkdir dist

cp -r src/* dist
cp README.markdown dist
cp LICENSE dist
cp doc/haxelib.xml dist
cp bin/tracker.n dist/run.n

cd dist
rm test.n
zip -r ../tracker.zip *
cd ..

