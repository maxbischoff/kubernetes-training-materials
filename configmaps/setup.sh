#!/usr/bin/env bash

cat <<EOF > application.properties
de.inovex.cool=true
EOF
kubectl create configmap config --from-file=application.properties --from-literal=MY_ENV_VAR=exposed
