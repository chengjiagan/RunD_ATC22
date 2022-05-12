#!/bin/bash

usage() {
    cat << EOF
Usage:
./gen_container.sh num_container runtime
EOF
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

container_num=$1
runtime=$2

namespace=${ns:-"test"}
tmp_dir="/tmp/pod_test"

gen_config() {
    if [[ -d $tmp_dir ]]; then
        clean_config
    fi
    mkdir -p $tmp_dir

    pod_config=()
    for i in $(seq ${container_num}); do
        local iii=$(printf "%03d" ${i})
        pod_config[$i]="${tmp_dir}/_pod_config_${iii}.yaml"
        cat > ${pod_config[$i]} << EOF
metadata:
  name: sandbox-${iii}
  namespace: ${namespace}
  uid: busybox-sandbox
  attempt: 1
linux:
  security_context:
    namespace_options:
      network: 2
EOF
    done
}

clean_config() {
    rm -r ${tmp_dir}
}

gen_one() {
    local i=$1
    pid=$(crictl runp --runtime=$runtime ${pod_config[$i]})
    while true; do # wait for pod ready
        if crictl inspectp $pid | grep -q "SANDBOX_READY"; then
            break
        else
            sleep 1
        fi
    done
}

# generate container concurrently
gen_concurrent() {
    local num=$1
    local current_num=$(crictl pods -q --namespace $namespace | wc -l)
    for c in $(seq $(($current_num + 1)) $(($current_num + $num))); do
        gen_one $c &
    done
    wait
}

gen_container() {
    local current_num=$(crictl pods -q --namespace $namespace | wc -l)
    local new_num=$(($container_num - $current_num))
    while [[ $new_num -gt 10 ]]; do
        gen_concurrent 10
        local new_num=$(($new_num - 10))
    done
    if [[ $new_num -gt 0 ]]; then
        gen_concurrent $new_num
    fi
}

echo "generate $container_num container"
gen_config
gen_container
clean_config
