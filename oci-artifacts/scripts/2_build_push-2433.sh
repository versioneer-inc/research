#!/bin/bash

set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <provider>"
  echo "Provider must be one of: docker, quay, harbor, aws, local"
  exit 1
fi

provider="$1"
data_dir="../data/pastis"
config_path="../data/config-2433.json"
match_pattern="^[0-9]{5}\.tar$"

case "$provider" in
  docker)
    registry="docker.io"
    repo_name="versioneer/pastis-2433"
    ;;
  quay)
    registry="quay.io"
    repo_name="versioneer-inc/pastis-2433"
    ;;
  harbor)
    registry="qr2wz4td.c1.de1.container-registry.ovh.net"
    repo_name="/versioneer/pastis-2433"
    ;;
  aws)
    registry="767397985165.dkr.ecr.eu-central-1.amazonaws.com"
    repo_name="versioneer/pastis-2433"
    ;;
  local)
    registry="localhost:5000"
    repo_name="pastis-2433"
    ;;
  *)
    echo "Invalid provider: '$provider'. Must be one of: docker, quay, harbor, aws, local"
    exit 1
    ;;
esac

repo="${registry}/${repo_name}:full"

echo "Using data_dir: $data_dir to push to repo: $repo"
echo "Logging into registry: $registry"

oras login "$registry"

layers=()
shopt -s nullglob
for tar in "$data_dir"/*.tar; do
  filename=$(basename "$tar")
  if [[ $filename =~ $match_pattern ]]; then
    layers+=("${tar}:application/vnd.oci.image.layer.v1.tar")
  fi
done

layer_count=${#layers[@]}
if [[ $layer_count -eq 0 ]]; then
  echo "No matching tar files found in $data_dir (pattern: $match_pattern)"
  exit 1
fi

echo "Found $layer_count layer(s) to include:"
for l in "${layers[@]}"; do
  echo "  - $(basename "${l%%:*}")"
done

oras push --verbose "$repo" \
  --artifact-type application/vnd.whatever.v1+tar \
  --config "${config_path}:application/vnd.oci.image.config.v1+json" \
  "${layers[@]}"
