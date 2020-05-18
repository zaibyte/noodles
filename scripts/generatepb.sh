#!/usr/bin/env bash

# Copied from github.com/pingcap/kvproto

SCRIPTS_DIR=$(dirname "$0")
source $SCRIPTS_DIR/commonpb.sh

push $SCRIPTS_DIR/..
PBROOT=`pwd`
pop

PROGRAM=$(basename "$0")
GOPATH=${GOPATH%%:*}

if [ -z $GOPATH ]; then
    printf "Error: the environment variable GOPATH is not set, please set it before running %s\n" $PROGRAM > /dev/stderr
    exit 1
fi

GO_PREFIX_PATH=github.com/zaibyte/noodles/pkg
export PATH=$PBROOT/_tools/bin:$GOPATH/bin:$PATH

#echo "go get dep..."
#GO111MODULE=off go get github.com/grpc-ecosystem/grpc-gateway

echo "install tools..."
GO111MODULE=off go get github.com/twitchtv/retool
GO111MODULE=off retool sync || exit 1

function collect() {
    file=$(basename $1)
    base_name=$(basename $file ".proto")
    mkdir -p ../pkg/$base_name
    if [ -z $GO_OUT_M ]; then
        GO_OUT_M="M$file=$GO_PREFIX_PATH/$base_name"
    else
        GO_OUT_M="$GO_OUT_M,M$file=$GO_PREFIX_PATH/$base_name"
    fi
}

cd proto
for file in `ls *.proto`
    do
    collect $file
done

echo "generate go code..."
ret=0

function gen() {
    base_name=$(basename $1 ".proto")
    protoc -I.:../include -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis --grpc-gateway_out=logtostderr=true:../pkg/$base_name --gofast_out=plugins=grpc,$GO_OUT_M:../pkg/$base_name $1 || ret=$?
    cd ../pkg/$base_name
    sed_inplace -E 's/import _ \"gogoproto\"//g' *.pb*.go
    sed_inplace -E 's/import fmt \"fmt\"//g' *.pb*.go
    sed_inplace -E 's/import io \"io\"//g' *.pb*.go
    sed_inplace -E 's/import math \"math\"//g' *.pb*.go
    goimports -w *.pb*.go
    cd ../../proto
}

for file in `ls *.proto`
    do
    gen $file
done
exit $ret
