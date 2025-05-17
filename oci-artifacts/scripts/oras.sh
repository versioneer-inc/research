#!/bin/bash
set -e

# Step 1: Prepare
mkdir -p data
cp my-imagery.tif data/imagery.tif
cp my-stac.json data/stac_item.json
echo '{}' > data/config.json

# Step 2: Create an OCI Layout
oras push --oci-layout my-eo-package:v1 \
  --artifact-type application/vnd.earth-observation.product.v1+json \
  data/imagery.tif:image/tiff \
  data/stac_item.json:application/geo+json \
  data/config.json:application/vnd.oci.artifact.config.v1+json

# Step 3: Start a Local Registry
docker run -d -p 5000:5000 --name registry registry:2 || true

# Step 4: Push to Registry
oras cp \
  --from-oci-layout my-eo-package:v1 \
  localhost:5000/my-eo-package:v1

# Step 5: Pull Back from Registry
oras pull localhost:5000/my-eo-package:v1 --output ./retrieved

echo "✅ Artifact pushed and pulled successfully."
