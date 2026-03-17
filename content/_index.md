---
title: "About"
---

I build systems that verify software supply chains. At Chainguard, I work on ecosystem rebuilders, tools that independently rebuild open source packages to verify they match published artifacts. When you run `chainctl libraries verify`, my code checks that the package you downloaded is what the maintainer intended to publish.

Before supply chain security, I spent a decade building infrastructure at scale. At MixMode, I designed data pipelines processing network telemetry at 100Gbps for AI-based threat detection. At Anchore, I built the Kubernetes inventory system that tracks container contents across enterprise deployments. At LogicMonitor, I led teams building metrics pipelines handling millions of data points per day.

Most of my work involves Go, Kubernetes, and distributed systems. I write code that runs in production environments where reliability matters more than novelty. The interesting problems are usually in the details: making builds reproducible, handling partial failures gracefully, keeping systems observable without drowning in data.

## Current Work

At Chainguard, I focus on the Java and JavaScript ecosystems. These are the hardest to verify because they have complex build systems, transitive dependencies, and packaging formats that weren't designed with security in mind. Building reproducible versions of npm packages or Maven artifacts requires understanding the entire toolchain from source to published artifact.

The goal is simple: give organizations confidence that the code they deploy is the code they audited. The implementation is not.

## Technical Background

**Languages:** Go, Java (primary), Python, JavaScript/TypeScript

**Infrastructure:** Kubernetes, Argo Workflows, Kafka, PostgreSQL, distributed systems

**Domain expertise:** Container security, supply chain verification, SLSA provenance, SBOMs, reproducible builds

I write about some of this in the [writing](/writing/) section.
