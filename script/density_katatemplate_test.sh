#! /bin/bash
DIR=$(dirname $0)
kata_config="/etc/kata-containers/configuration-template.toml"
containerd_config="/etc/containerd/config.toml"
crictl_config="/etc/crictl.yaml"
source $DIR/density_test.conf

sed -r -i "s/default_memory = [0-9]+/default_memory = 168/g" $kata_config
sed -r -i "s/snapshotter = \".*\"/snapshotter = \"overlayfs\"/g" ${containerd_config}
systemctl restart containerd
sleep 10

$DIR/gen_katatemplate.sh $kata_config

start_date=$(date +%m%d%H%M)
base_dir=$(printf "density_katatemplate_%s" $start_date)
mkdir -p ${base_dir}
version="${base_dir}/versions.txt"
uname -r >> $version
containerd --version >> $version
crictl --version >> $version
kata-runtime --version >> $version
qemu-system-x86_64 --version >> $version
echo "with template" >> $version
cp $kata_config $base_dir/
cp $containerd_config $base_dir/
cp $crictl_config $base_dir/

for d in ${density[@]}; do
    ns="density-background" $DIR/gen_container.sh $d kata-template
    for c in ${concurency[@]}; do
        echo "--- kata-template $d $c"
        export result_dir=$(printf "%s/density_%04d/con_%03d" $base_dir $d $c)
        ns="density-test" $DIR/closedloop.sh $c 20 kata-template
        if [[ $? != 0 ]]; then
            exit $?
        fi
    done
done
$DIR/clean.sh "density-background"