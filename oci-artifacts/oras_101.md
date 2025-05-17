---
title: OCI Registry As Storage 101
date: 2025-05-15
author: Stefan Achtsnit
---

# OCI Artifacts Everywhere

The Open Container Initiative (OCI) established a widely adopted set of standards ([OCI Image Layout Spec](https://github.com/opencontainers/image-spec), [OCI Distribution Spec](https://github.com/opencontainers/distribution-spec) for interacting with container registries. Originally popularized by Docker for managing container images, this framework has since evolved into the broader concept of OCI artifacts. [ORAS](https://oras.land/) (OCI Registry As Storage) is a versatile toolkit that enables the pushing and pulling of arbitrary OCI artifacts to and from OCI-compliant registries.

While initially regarded as a workaround, the use of OCI registries for non-container content has gained mainstream acceptance—particularly for distributing configuration bundles, authorization policies, and more recently, AI/ML models. These artifacts benefit from standardized, content-addressable storage that ensures immutability, traceability, and efficient distribution.

Our own journey with OCI artifacts began through Helm charts, Kubernetes manifests in GitOps workflows (e.g., FluxCD), and Open Policy Agent (OPA) rules. Later, the growing importance of AI and large language models (LLMs) reintroduced us to this approach through KServe's OCI-based model serving ([Modelcars](https://kserve.github.io/website/latest/modelserving/storage/oci/)) and now [Docker Model Runner](https://docs.docker.com/model-runner). This experience significantly influenced our thinking: instead of merely providing guarded access to data, we began exploring scalable strategies for distributing curated, self-contained, and verifiable data packages.

## Artifact Structure

Each OCI artifact consists of immutable blobs stored by their SHA256 digest:

```
oci-layout/
├── oci-layout
├── index.json
└── blobs/
    └── sha256/
        ├── <config>
        ├── <data>
        ├── <metadata>
```

This layout directly maps to:

- **Layer blobs** – the actual data (e.g., `.tar`, `.tar.gz` `.json`, `.tif`)
- **Config blob** – small JSON metadata object
- **Manifest** – a JSON file referencing the config and layers

This ensures deduplication, integrity, and compatibility across all OCI-compliant registries.

## Domain-Specific Examples

While the core structure of OCI artifacts is standardized, the introduction of arbitrary custom media types has made media type definitions and content semantics inherently domain-specific. This extensibility has enabled the ecosystem to evolve beyond container images, supporting diverse use cases such as Helm charts, AI/ML models, and Earth Observation (EO) datasets.

### Docker Image
[OCI Spec](https://github.com/opencontainers/image-spec/blob/main/media-types.md) fictitious example

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.image.config.v1+json",
    "digest": "sha256:1111aaaa2222bbbb3333cccc4444dddd5555eeee6666ffff7777gggg8888hhhh",
    "size": 7023
  },
  "layers": [
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "digest": "sha256:aaaabbbbccccddddeeeeffff0000111122223333444455556666777788889999",
      "size": 32654
    },
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "digest": "sha256:9999888877776666555544443333222211110000fffeddeeddbbccaa99887766",
      "size": 98765
    }
  ]
}
```

### Helm Chart
[Helm Docs](https://helm.sh/docs/topics/registries/) listed example with provenance file

```json
{
  "schemaVersion": 2,
  "config": {
    "mediaType": "application/vnd.cncf.helm.config.v1+json",
    "digest": "sha256:8ec7c0f2f6860037c19b54c3cfbab48d9b4b21b485a93d87b64690fdb68c2111",
    "size": 117
  },
  "layers": [
    {
      "mediaType": "application/vnd.cncf.helm.chart.content.v1.tar+gzip",
      "digest": "sha256:1b251d38cfe948dfc0a5745b7af5ca574ecb61e52aed10b19039db39af6e1617",
      "size": 2487
    },
    {
      "mediaType": "application/vnd.cncf.helm.chart.provenance.v1.prov",
      "digest": "sha256:3e207b409db364b595ba862cdc12be96dcdad8e36c59a03b7b3b61c946a5741a",
      "size": 643
    }
  ]
}
```

### AI/ML Model
[Docker Docs - Beta](https://docs.docker.com/model-runner/) fictitious example

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

### EO Data
invented example

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

> Note: STAC metadata can be embedded in a layer or placed in the config blob. This is a design decision and should align with intended use cases.

To summarize, the following table highlights the high extensibility of the OCI artifact format. While the manifest structure is standardized, key elements such as media types, config contents, and layer annotations can be customized to support domain-specific needs.

| Feature                  | Standardized by OCI | Customizable by Domain        |
|--------------------------|----------------------|-------------------------------|
| Manifest structure       | ✔                   | —                             |
| Media types              | —                   | ✔                             |
| Config blob content      | —                   | ✔                             |
| Layer annotations        | —                   | ✔                             |
| Tagging convention       | ✔                   | ✔ (e.g., `ref.name`)          |

## OCI Registry API Overview

The [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec/) defines a minimal HTTP API for interacting with registries:

| Endpoint                              | Purpose                     |
|---------------------------------------|-----------------------------|
| `GET /v2/`                             | Ping registry               |
| `GET /v2/<name>/manifests/<tag>`      | Fetch manifest              |
| `PUT /v2/<name>/manifests/<tag>`      | Upload manifest             |
| `GET /v2/<name>/blobs/<digest>`       | Download blob               |
| `HEAD /v2/<name>/blobs/<digest>`      | Check blob existence        |
| `POST /v2/<name>/blobs/uploads/`      | Begin blob upload           |
| `PUT /v2/<name>/blobs/uploads/<uuid>` | Complete blob upload        |

The familiar pull and push operations in OCI are composed of multiple lightweight API calls, internally optimized through digest-based de-duplication. Before uploading a blob, registries check whether it already exists using its content-derived SHA256 digest. If it does, the blob is skipped—ensuring that redundant transfers are avoided. Similarly, during pulls, only missing blobs are fetched, allowing for highly efficient reuse and incremental synchronization.

This architecture makes OCI artifacts not only portable and immutable, but also inherently efficient and scalable. Thanks to their adherence to the OCI Distribution Specification, these artifacts are broadly interoperable across a wide range of registry platforms—including Docker Hub, Quay.io, AWS Elastic Container Registry (ECR), Harbor, and local self-hosted registries.

More on this approach, real-world use cases, and a detailed evaluation of registry behavior across implementations can be found in our accompanying paper.

---

## Practical Workflow

### Step 1: Prepare

```bash
mkdir -p data
cp my-imagery.tif data/imagery.tif
cp my-stac.json data/stac_item.json
echo '{}' > data/config.json
```

### Step 2: Create an OCI Layout

```bash
oras push --oci-layout eo-layout:eo/products:v1 \
  --artifact-type application/vnd.my-earth-observation-product.v1 \
  data/imagery.tif:image/tiff \
  data/stac_item.json:application/geo+json \
  data/config.json:application/vnd.oci.artifact.config.v1+json
```

### Step 3: Push to a Registry

Start a local registry:

```bash
docker run -d -p 5000:5000 --name registry registry:2
```

Push the layout:

```bash
oras cp \
  --from-oci-layout eo-layout:eo/products:v1 \
  --to localhost:5000/eo/products:v1
```

Note: oras also supports to push directly!

Pull back:

```bash
oras pull localhost:5000/eo/products:v1 --output ./retrieved
```

Please find the full example as shell script [here](./scripts/oras.sh).