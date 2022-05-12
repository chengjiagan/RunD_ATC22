#!/bin/bash

usage() {
    cat << EOF
Usage:
./clean.sh namespace
EOF
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

ns=$1

for pod in $(crictl pods --namespace $ns -q); do
    crictl rmp -f $pod > /dev/null
done
# crictl rmp -f $(crictl pods --namespace $ns -q)
