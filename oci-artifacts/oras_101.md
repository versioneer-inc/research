---
title: OCI Registry As Storage 101
---

# Packaging and Distributing Domain-Specific Artifacts via OCI Registries

ORAS (OCI Registry As Storage) is a powerful set of tools that enables you to package, distribute, and version any digital asset using OCI-compliant registries. While originally built for container images, the Open Container Initiative (OCI) specifications support a much broader set of use cases including:

- Earth Observation data (e.g., GeoTIFFs, STAC metadata)
- Machine Learning models
- Helm charts
- Software documentation and binary artifacts

This guide outlines the core principles, practical usage, and customization strategies for applying ORAS to data workflows beyond containers.

---

## 1. Key Concepts

### OCI Artifact Structure

An OCI artifact consists of:

- **Config blob** – a small JSON object, typically used for metadata
- **Layer blobs** – your actual files (e.g., `.tif`, `.json`, `.tar.gz`)
- **Manifest** – a JSON document referencing config and layers
- **Index** – used in OCI layout to reference manifests via tags

### Content-Addressable Storage

OCI artifacts are composed of immutable blobs stored by digest:

```
oci-layout/
├── oci-layout
├── index.json
└── blobs/
    └── sha256/
        ├── <config>
        ├── <image>
        ├── <metadata>
        └── <manifest>
```

This guarantees deduplication, integrity, and traceability.

---

## 2. Domain-Specific Customization

| Feature                  | Standardized by OCI | Customizable by Domain |
|--------------------------|----------------------|-------------------------|
| Manifest structure       | ✔                   | ─                       |
| Media types              | ─                   | ✔                       |
| Config blob content      | ─                   | ✔                       |
| Layer annotations        | ─                   | ✔                       |
| Tagging convention       | ✔                   | ✔ (e.g. `org.opencontainers.ref.name`) |

### Example: Earth Observation

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.artifact.config.v1+json",
    "digest": "sha256:abcd1234...",
    "size": 256
  },
  "layers": [
    {
      "mediaType": "image/tiff",
      "digest": "sha256:deadbeef...",
      "size": 10485760,
      "annotations": {
        "eo:band": "B04"
      }
    },
    {
      "mediaType": "application/geo+json",
      "digest": "sha256:feedface...",
      "size": 2048,
      "annotations": {
        "type": "stac-item"
      }
    }
  ]
}
```

### Example: Helm Chart

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.cncf.helm.config.v1+json",
    "digest": "sha256:aaaabbbb...",
    "size": 123
  },
  "layers": [
    {
      "mediaType": "application/vnd.cncf.helm.chart.content.v1.tar+gzip",
      "digest": "sha256:cccddd...",
      "size": 123456
    }
  ]
}
```

### Example: ML Model (Docker Model Registry Proposal)

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.docker.model.config.v1+json",
    "digest": "sha256:abc123...",
    "size": 512
  },
  "layers": [
    {
      "mediaType": "application/octet-stream",
      "digest": "sha256:def456...",
      "size": 104857600,
      "annotations": {
        "framework": "PyTorch"
      }
    }
  ]
}
```

---

## 3. Practical Workflow

### Step 1: Prepare Files

```bash
mkdir -p data
cp your-imagery.tif data/imagery.tif
cp your-stac.json data/stac_item.json
echo '{}' > data/config.json
```

### Step 2: Create an OCI Layout

```bash
oras push --oci-layout eo-layout:eo/products:v1   data/imagery.tif:image/tiff   data/stac_item.json:application/geo+json   data/config.json:application/vnd.oci.artifact.config.v1+json
```

### Step 3: Push to a Registry

#### Start a Local Registry:

```bash
docker run -d -p 5000:5000 --name registry registry:2
```

#### Push the Layout to the Registry:

```bash
oras cp --from-oci-layout eo-layout:eo/products:v1         --to localhost:5000/eo/products:v1
```

#### Pull Back:

```bash
oras pull localhost:5000/eo/products:v1 --output ./retrieved
```

---

## 4. Companion Shell Script

You can find an automated version of the workflow described above in:

📄 [`scripts/oras.sh`](./scripts/oras.sh)

This script:
- Prepares example data files
- Builds an OCI layout
- Starts a local registry (if not already running)
- Pushes the layout
- Pulls it back and lists the results

---

## 5. OCI Registry API Overview

The [OCI Distribution Spec](https://github.com/opencontainers/distribution-spec/) defines how clients interact with registries.

| Endpoint                             | Purpose                         |
|--------------------------------------|----------------------------------|
| `GET /v2/`                            | Ping the registry                |
| `GET /v2/<name>/manifests/<tag>`     | Fetch manifest by tag            |
| `PUT /v2/<name>/manifests/<tag>`     | Upload manifest                  |
| `GET /v2/<name>/blobs/<digest>`      | Download blob                    |
| `HEAD /v2/<name>/blobs/<digest>`     | Check if blob exists             |
| `POST /v2/<name>/blobs/uploads/`     | Begin blob upload                |
| `PUT /v2/<name>/blobs/uploads/<uuid>`| Complete blob upload             |

---

## References

- ORAS CLI Documentation – https://oras.land/
- OCI Image Layout Spec – https://github.com/opencontainers/image-spec/blob/main/image-layout.md
- OCI Distribution Spec – https://github.com/opencontainers/distribution-spec/
- STAC Specification – https://stacspec.org/
- Helm OCI Chart Spec – https://helm.sh/docs/topics/registries/
- Docker Model Artifacts – https://www.docker.com/blog/publish-discover-models-on-docker-hub/

