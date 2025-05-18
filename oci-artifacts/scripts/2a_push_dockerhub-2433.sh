#!/bin/bash

set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <mode>"
  echo "Mode must be one of: sample, full"
  exit 1
fi

mode="$1"

if [[ "$mode" != "sample" && "$mode" != "full" ]]; then
  echo "Invalid mode: '$mode'. Must be 'sample' or 'full'."
  exit 1
fi

if [[ "$mode" == "sample" ]]; then
  data_dir="../data/sample"
else
  data_dir="../data/pastis"
fi

registry="docker.io"
repo="$registry/versioneer/pastis-2433:$mode"

echo "Using mode: $mode with data_dir: $data_dir to push to repo: $repo"

echo "Logging into registry: $registry"
oras login "$registry"

layers=()
shopt -s nullglob
for tar in "$data_dir"/*.tar; do
  filename=$(basename "$tar")
  if [[ $filename =~ ^[0-9]{5}\.tar$ ]]; then
    layers+=("$tar:application/vnd.oci.image.layer.v1.tar")
  fi
done

layer_count=${#layers[@]}
if [[ $layer_count -eq 0 ]]; then
  echo "No valid 5-digit tar files found in $data_dir"
  exit 1
fi

echo "Found $layer_count layer(s) to include:"
for l in "${layers[@]}"; do
  echo "  - $(basename "${l%%:*}")"
done

oras push --verbose "$repo" \
  --artifact-type application/vnd.whatever.v1+tar \
  --config "$data_dir/config.json:application/vnd.oci.image.config.v1+json" \
  "${layers[@]}"