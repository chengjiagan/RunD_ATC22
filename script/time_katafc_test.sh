#! /bin/bash
DIR=$(dirname $0)
kata_config="/etc/kata-containers/configuration-fc.toml"
containerd_config="/etc/containerd/config.toml"
crictl_config="/etc/crictl.yaml"
source $DIR/time_test.conf

sed -r -i "s/default_memory = [0-9]+/default_memory = 168/g" $kata_config
sed -r -i "s/snapshotter = \".*\"/snapshotter = \"devmapper\"/g" ${containerd_config}
systemctl restart containerd
sleep 10

start_date=$(date +%m%d%H%M)
base_dir=$(printf "time_katafc_%s" $start_date)
mkdir -p ${base_dir}
version="${base_dir}/versions.txt"
uname -r >> $version
containerd --version >> $version
crictl --version >> $version
kata-runtime --version >> $version
firecracker --version >> $version
cp $kata_config $base_dir/
cp $containerd_config $base_dir/
cp $crictl_config $base_dir/

for c in ${concurency[@]}; do
    echo "--- kata-fc $c"
    export result_dir=$(printf "%s/con_%03d" $base_dir $c)
    $DIR/closedloop.sh $c 50 kata-fc
    if [[ $? != 0 ]]; then
        exit $?
    fi
done

sed -r -i "s/snapshotter = \".*\"/snapshotter = \"overlayfs\"/g" ${containerd_config}
systemctl restart containerd
sleep 10