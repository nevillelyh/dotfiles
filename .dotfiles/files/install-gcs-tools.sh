#/bin/bash

# fail early
set -e

VERSION="0.1.7"
PREFIX="https://github.com/spotify/gcs-tools/releases/download/v$VERSION"

DIR=/opt/gcs-tools/$VERSION

mkdir -p $DIR/bin
cd $DIR/bin
cp ~/.dotfiles/files/gcs-tools.sh .
ln -s gcs-tools.sh avro-tools
ln -s gcs-tools.sh parquet-tools
ln -s gcs-tools.sh proto-tools

mkdir -p $DIR/lib
wget -P $DIR/lib "$PREFIX/avro-tools-1.8.2.jar"
wget -P $DIR/lib "$PREFIX/parquet-tools-1.9.0.jar"
wget -P $DIR/lib "$PREFIX/proto-tools-3.4.0.jar"

cd /opt/gcs-tools
ln -s $VERSION default
