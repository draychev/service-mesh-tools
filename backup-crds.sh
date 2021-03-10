#!/bin/bash

set -auexo pipefail

CRDS=$(kubectl get CustomResourceDefinitions --no-headers | awk -F'.' '{print $1}' | grep -v 'kube-')
NSS=$(kubectl get namespaces --no-headers | awk '{print $1}')
DIR="./crd_backup"

mkdir -p $DIR

echo -e "All CRDs are going to be in ${DIR}"

for crd in $CRDS; do
    for ns in $NSS; do
        echo "Working on $crd in $ns"
        names=$(kubectl get $crd -n $ns --no-headers | awk '{print $1}')
        for name in $names; do
            if [ ! -z "$name" ]; then
                echo "Saving ${DIR}/${crd}___${ns}___${name}.yaml"
                kubectl get $crd -n $ns $name -o yaml > "${DIR}/${crd}___${ns}___${name}.yaml"
            fi
        done
    done
done

# There are a bunch of empty YAML files - remove them
find . -size -84c -name '*.yaml' -delete
