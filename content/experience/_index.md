---
title: "Experience"
description: "11 years of distributed systems, infrastructure, and security engineering"
---

## Staff Software Engineer at Chainguard
*2023 - Present*

**Context:** Organizations struggle to verify that open source packages haven't been tampered with between when a maintainer builds them and when they're deployed. Checksums only prove a file hasn't changed since download, not that it matches what was built from source.

**Approach:**
- Built reproducible build pipelines for Java and JavaScript ecosystems using Argo Workflows
- Implemented signature verification in `chainctl libraries verify` for ecosystem package validation
- Designed artifact comparison systems that detect divergence between published and rebuilt packages
- Worked with upstream projects to understand and document build processes for reproducibility

**Outcome:** Customers can verify package integrity before deployment, catching supply chain attacks that would bypass traditional checksum validation.

**Stack:** Go, Kubernetes, Argo Workflows, Sigstore, container runtimes

---

## Director of Engineering at MixMode
*2021 - 2023*

**Context:** AI-based network security requires processing massive data volumes in real-time. The existing pipeline couldn't keep up with enterprise network traffic, limiting the product's applicability to large deployments.

**Approach:**
- Redesigned ingestion pipeline to handle 100Gbps network telemetry
- Scaled engineering team and established development practices
- Led architecture for government contract requiring classified environment deployment
- Implemented distributed processing with Kafka for buffering and load distribution

**Outcome:** 10x throughput improvement. Successfully delivered on $20M government contract with strict performance and security requirements.

**Stack:** Go, Kafka, Kubernetes, distributed systems

---

## Senior Software Engineer at Anchore
*2019 - 2021*

**Context:** Enterprise customers running thousands of containers across multiple Kubernetes clusters needed visibility into what software was actually running. Existing approaches required manual inventory or couldn't keep up with container churn.

**Approach:**
- Built Kubernetes-native inventory system using custom controllers
- Implemented intelligent scheduling to prioritize analysis of new or changed containers
- Designed integration points with existing container analysis pipelines
- Created efficient storage and querying for inventory data at scale

**Outcome:** 60% reduction in time to complete container analysis across customer deployments. Improved accuracy by eliminating gaps in inventory coverage.

**Stack:** Go, Kubernetes controllers, container runtimes, PostgreSQL

---

## Lead Engineer / Engineering Manager at LogicMonitor
*2013 - 2019*

**Context:** SaaS infrastructure monitoring platform needed to scale metrics ingestion as customer base grew. The existing single-node architecture was approaching its limits.

**Approach:**
- Designed distributed metrics pipeline architecture
- Led team through design, implementation, and production rollout
- Implemented Kafka-based buffering and load balancing
- Built monitoring and alerting for the monitoring system itself

**Outcome:** Pipeline handled 2M+ metrics per day with sub-minute latency. Architecture supported continued growth as customer base expanded.

**Stack:** Java, Quarkus, Kafka, distributed systems

---

## Timeline

| Years | Role | Company |
|-------|------|---------|
| 2023-Present | Staff Software Engineer | Chainguard |
| 2021-2023 | Director of Engineering | MixMode |
| 2019-2021 | Senior Software Engineer | Anchore |
| 2013-2019 | Lead Engineer → Engineering Manager | LogicMonitor |
