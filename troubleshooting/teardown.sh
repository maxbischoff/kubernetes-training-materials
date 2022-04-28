#!/usr/bin/env bash

kubectl delete ns debug
kubectl config  set contexts.$(kubectl config current-context).namespace default
