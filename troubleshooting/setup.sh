#!/usr/bin/env bash

kubectl create ns debug
kubectl config  set contexts.$(kubectl config current-context).namespace debug
