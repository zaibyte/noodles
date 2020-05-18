#!/usr/bin/env bash

# Copied from github.com/pingcap/kvproto

function push() {
    pushd $1 >/dev/null 2>&1
}

function pop() {
    popd $1 >/dev/null 2>&1
}

function sed_inplace()
{
	if [ `uname` == "Darwin" ]; then
		sed -i '' "$@"
	else
		sed -i "$@"
	fi
}