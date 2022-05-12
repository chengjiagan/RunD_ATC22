#!/bin/bash

usage() {
    cat << EOF
Usage:
./gen_rundtemplate.sh 
EOF
}

rund_toml="/etc/kata-containers2/configuration.toml"
sed -r -i 's/#?boot_type = .*/boot_type = "BootToBeTemplate"/g' $rund_toml
sed -i '/guest_hook_path/d' $rund_toml

TEMPLATE_POD_CONFIG=/tmp/template_pod.json
cat > $TEMPLATE_POD_CONFIG << EOF
{
    "metadata": {
        "name": "template",
        "namespace": "default",
        "attempt": 1,
        "uid": "template"
    },
    "linux": {
        "security_context": {
            "namespace_options": {
                "network" : 2
            }
        }
    }
}
EOF

rm -rf /run/rund/*

pid=$(crictl runp -r rund $TEMPLATE_POD_CONFIG)
crictl rmp -f $pid > /dev/null
echo "generate rund template"

sed -r -i 's/BootToBeTemplate/BootFromTemplate/g' $rund_toml
sed -i '/enable_sandbox_builtin_storage/i guest_hook_path="/"' $rund_toml
