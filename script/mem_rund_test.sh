#! /bin/bash
DIR=$(dirname $0)
kata_config="/etc/kata-containers2/configuration.toml"
containerd_config="/etc/containerd/config.toml"
crictl_config="/etc/crictl.yaml"
source $DIR/mem_test.conf

sed -r -i "s/snapshotter = \".*\"/snapshotter = \"overlayfs\"/g" ${containerd_config}
sed -r -i "s/#?boot_type = \".*\"/boot_type = \"BootFromTemplate\"/g" ${kata_config}
systemctl restart containerd
sleep 10

start_date=$(date +%m%d%H%M)
base_dir=$(printf "mem_rund_%s" $start_date)
mkdir -p ${base_dir}
version="${base_dir}/versions.txt"
uname -r >> $version
containerd --version >> $version
crictl --version >> $version
echo "with template" >> $version
cp $containerd_config $base_dir/
cp $crictl_config $base_dir/
cp $kata_config $base_dir/

export ns="mem-test"
for mem in ${memory[@]}; do
    sed -r -i "s/default_memory = [0-9]+/default_memory = $(($mem + 180))/g" $kata_config
    $DIR/gen_rundtemplate.sh

    for c in ${density[@]}; do
        echo "--- rund ${mem}MB $c"
        result_fn=$(printf "%s/result_%sMB_%04d.txt" $base_dir $mem $c)
        $DIR/gen_container.sh $c rund
        $DIR/smem_result.sh "^/usr/local/bin/containerd-shim-rund-v2" > $result_fn
    done
    echo "Cleaning ..."
    $DIR/clean.sh $ns
done
