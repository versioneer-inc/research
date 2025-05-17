---
title: OCI Artifacts for Data Supply Chains
date: 2025-05-15
author: Stefan Achtsnit
---
# Introduction

The [Open Container Initiative](https://opencontainers.org) (OCI) —originally developed to standardize container images and registries—has evolved into a powerful, open-ended platform for managing and distributing data artifacts. The introduction of the [OCI Artifact extension](https://github.com/opencontainers/image-spec/blob/main/artifacts-guidance.md) opened the door for entirely new use cases beyond traditional software deployment.

We see the true strength of this ecosystem not just in its design, but in its **ubiquity**: millions of OCI-compliant registries like [Docker Hub](https://hub.docker.com/), [AWS Elastic Container Registry (ECR)](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html), [Quay.io](https://quay.io/), [Harbor](https://goharbor.io/), and others are already in operation, battle-tested at scale, and supported across clouds, platforms, and tools. This makes OCI a natural foundation for solving long-standing challenges in data packaging, distribution, and reproducibility.


# Why ORAS Matters

As a key enabler, [OCI Registry As Storage](https://oras.land) (ORAS) brings first-class support for pushing and pulling arbitrary data artifacts to and from OCI registries. It extends the OCI model to general-purpose content—code, models, datasets, and more.

To help others get started, we’ve published an [ORAS 101 guide](/link/to/oras101), which introduces the core concepts of OCI and ORAS, explains how artifacts are structured, and provides practical examples for packaging and distributing data.

# From Containers to Data Supply Chains

As data workflows grow more complex and critical, the need for trustworthy, reproducible, and context-aware data handling has never been greater. In scientific computing, AI, and domain-specific analytics alike, it's no longer enough to store raw files—we must build structured, versioned, and verifiable data supply chains.

The OCI model offers a powerful foundation for this. Originally designed for containerized software, OCI registries support:

- Layered, content-addressable storage
- Immutable references based on cryptographic digests
- Manifest-driven composition of complex artifacts  
- Standardized APIs and ubiquitous registry support

These same features that transformed software distribution now prove just as relevant for data management—especially when versioning, partitioning, reproducibility, and remote access are required.

But it doesn’t stop there.

Borrowing from the software world, OCI supports attestations—structured metadata tied to artifacts that prove something has been checked or verified. In the software supply chain, this includes automated test results, vulnerability scans, and license checks. In the data world, the same mechanism can be used to attach:

- Data integrity checksums  
- Validation reports and schema compliance  
- Provenance information  
- Quality assurance metrics  
- Workflow audit trails

These attestations turn OCI data packages into **verifiable, trusted building blocks**—not just blobs in storage. Combined with the existing OCI ecosystem, they unlock a path toward scalable, transparent, and automated data operations.

OCI artifacts shift the paradigm: from data *as storage* to data *as supply chain*.

# Deep Dive: Earth Observation as a Case Study

With our background in Earth Observation (EO), we conducted a focused study to assess how well OCI can serve as a packaging and distribution framework for complex EO data products. The result is our research paper:

**_“Towards Standardization of the Earth Observation Data Product Supply Chain – Are OCI Artifacts the Key to Ubiquitous and Scalable EO Data Handling?”_**  
To be presented at **[FOSS4G Europe 2025](https://talks.osgeo.org/foss4g-europe-2025/talk/HNZK37/)**.

The paper explores how OCI-based registries can act as a unifying layer for distributing EO products, including metadata, partitioned assets, and lineage. It also presents a  benchmark setup, registry compatibility analysis, and trade-offs across multiple implementations.

→ Read the [full paper](/papers/oci-supply-chain_draft.pdf) (PDF) 
→ Explore our [evaluation setup](paper-evaluation-setup.ipynb) and [results](paper-results.ipynb)

# Beyond Data Supply Chains: Toward a Trusted, Reproducible Data Ecosystem

We believe that the architecture and principles behind OCI artifacts are not only suitable for data packaging—they provide a strong foundation for building modern, domain-independent data ecosystems that emphasize traceability, reproducibility, and reusability.

Our objective—both in research and in building production-ready, commercial-grade infrastructure—is to demonstrate that OCI registries, when combined with standardized artifact formats, layered storage, and rich domain metadata (such as [STAC](https://stacspec.org/) in Earth Observation), can support complete data lifecycles: from raw asset ingestion to structured packaging, distribution, and validation. This enables a Lakehouse-style architecture where versioned, immutable data packages coexist with flexible and efficient storage and access to both structured and unstructured mutable content.

With capabilities like digest-based addressing, partial access, and artifact referrers, OCI supports packaging models that are not only portable and interoperable, but also verifiable and policy-aware. Its decentralized infrastructure with centralized governance offers a compelling foundation for implementing **data mesh principles**—empowering data teams to take ownership of their products, much like microservices** and DevOps** transformed software development.

These ideas are further explored in our concept paper:

**_“Building a Trusted and Reproducible Data Ecosystem with OCI”_** → [Read more](data-ecosystem-with-oci.md)

