#!/bin/bash

rm -rf dist
rm tracker.zip
mkdir dist

cp -r src/* dist
cp README.markdown dist
cp LICENSE dist
cp doc/haxelib.xml dist

cd dist
mv tracker.n run.n
rm test.n
zip -r ../tracker.zip *
cd ..

