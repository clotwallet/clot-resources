#!/bin/sh
set -eu

# Run on Cherry from an uploaded checkout, using its local k3s credentials.
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
stage_dir=$(mktemp -d)
trap 'rm -rf "$stage_dir"' EXIT HUP INT TERM
cp "$repo_dir"/deploy/cherry/* "$stage_dir/"
cp "$repo_dir/wallet/privacy.md" "$stage_dir/privacy.md"
kubectl apply -k "$stage_dir"
kubectl -n resources rollout status deployment/clot-resources --timeout=120s
