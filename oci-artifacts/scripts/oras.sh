#!/bin/bash
set -e

# Prepare working directory
mkdir -p data
echo "dummy image data" > data/imagery.tif
echo '{ "type": "Feature", "geometry": null, "properties": { "eo:bands": ["B04"] } }' > data/stac_item.json
echo '{}' > data/config.json

# Build OCI layout
oras push --oci-layout eo-layout:eo/products:v1 \
  data/imagery.tif:image/tiff \
  data/stac_item.json:application/geo+json \
  data/config.json:application/vnd.oci.artifact.config.v1+json

# Start local registry if not running
if ! docker ps | grep -q registry; then
  docker run -d -p 5000:5000 --name registry registry:2
fi

# Push to local registry
oras cp --from-oci-layout eo-layout:eo/products:v1 \
        --to localhost:5000/eo/products:v1

# Pull back and verify
mkdir -p pulled
oras pull localhost:5000/eo/products:v1 --output pulled

echo "✅ Artifact pushed and pulled successfully."
ls -lh pulled
