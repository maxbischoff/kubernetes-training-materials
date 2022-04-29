#!/usr/bin/env bash

kubectl delete ns debug
kubectl config set-context --current --namespace=default
