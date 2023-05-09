#!/bin/sh
set -eu

kubectl annotate --overwrite clusterversion version argocd.argoproj.io/sync-options='Prune=false,Delete=false'
kubectl label clusterversion version argocd.argoproj.io/instance-
