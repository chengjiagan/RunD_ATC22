#! /bin/bash

usage() {
    cat << EOF
Usage:
./gen_katatemplate.sh config
EOF
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

config=$1

kata-runtime --kata-config $config factory destroy
kata-runtime --kata-config $config factory init
sleep 5