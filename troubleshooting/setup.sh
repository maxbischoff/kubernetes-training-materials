#!/usr/bin/env bash

kubectl create ns debug
kubectl config set-context --current --namespace=debug
