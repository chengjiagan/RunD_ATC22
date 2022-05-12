#!/bin/bash

usage() {
    cat << EOF
Usage:
./mem_result.sh regex
EOF
}

regex=$1

smem -P "$regex" -c "name uss pss rss vss"