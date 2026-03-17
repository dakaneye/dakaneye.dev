---
title: "Verifying Software Supply Chains: Beyond Checksums"
date: 2024-01-15
description: "Why checksums aren't enough to verify software packages, and what reproducible builds offer instead"
tags: ["supply-chain-security", "reproducible-builds", "slsa"]
---

When you download a package from npm or Maven Central, you probably check the checksum. Your package manager does this automatically. The SHA-256 matches, so the file is verified. Right?

Not exactly.

A checksum proves one thing: the file you downloaded is identical to the file on the registry. It says nothing about whether that file was built from the source code you reviewed, by the maintainer you trust, on a system that wasn't compromised.

## The Gap Between Source and Artifact

Consider what happens when a maintainer publishes a package. They run `npm publish` or `mvn deploy` from their laptop. The build tool compiles the source, bundles dependencies, maybe transpiles some code, and uploads the result. The registry records a checksum.

Months later, you download that package. The checksum matches. But you have no way to verify:

- Was this built from the tagged release in the git repo?
- Did the build include any local modifications?
- Was the maintainer's machine compromised at build time?
- Did the build process inject anything not in the source?

The checksum only tells you the file hasn't changed since it was uploaded. It doesn't tell you what went into building it.

## Real Attacks Exploit This Gap

This isn't theoretical. The SolarWinds attack injected malicious code during the build process. The source repository looked clean. The checksums matched. But the build system had been compromised to inject a backdoor that wasn't visible in source control.

Codecov was similar. Attackers modified the build process to exfiltrate credentials, then distributed the compromised artifact through normal channels. Checksums verified perfectly because the registry received exactly what the compromised build produced.

Event-stream demonstrated a simpler version: a maintainer with commit access added malicious code that passed review, then built and published it normally. The checksum matched because there was nothing wrong with the file transfer. The problem was what got built in the first place.

## Reproducible Builds Change the Verification Model

A reproducible build produces identical output given identical inputs. Same source code, same compiler version, same build flags, same everything produces byte-for-byte identical artifacts. If you can rebuild a package and get the same result, you know what went into it.

This sounds simple. In practice, it's hard.

Builds embed timestamps. Compilers order operations non-deterministically. Filesystems report metadata differently across systems. Dependencies resolve to slightly different versions. Any of these variations produces a different checksum, even from identical source.

Making builds reproducible requires controlling all of these factors. The [Reproducible Builds](https://reproducible-builds.org/) project has been working on this for years, primarily in the Debian ecosystem. They've made significant progress, but many packages still aren't reproducible because their build systems weren't designed with this in mind.

## SLSA Provides a Framework

The [SLSA framework](https://slsa.dev/) (Supply chain Levels for Software Artifacts) defines security levels for build systems. At the higher levels, it requires:

- Builds run on dedicated, isolated infrastructure
- Build process is defined in version control
- Provenance attestations cryptographically link artifacts to source
- Build systems are hardened against tampering

SLSA doesn't require reproducibility, but it complements it. Provenance attestations tell you where an artifact claims to come from. Reproducibility lets you verify that claim by rebuilding it yourself.

## What This Means in Practice

At Chainguard, we rebuild open source packages from source in controlled environments. When the rebuild matches the published artifact, we can attest that the package contains what the source code specifies. When it doesn't match, we investigate why.

The mismatches are usually mundane: timestamps, build ordering, dependency resolution. Sometimes they reveal packaging mistakes. Occasionally they expose real problems that wouldn't be visible from source inspection alone.

The goal isn't to distrust package maintainers. Most are doing their best with limited resources. The goal is to verify without trusting any single point in the supply chain. If the maintainer's laptop is compromised, the build system catches it. If the build system is compromised, independent rebuilds catch it.

## The Current State

Perfect supply chain verification isn't achievable yet. Too many packages have non-reproducible builds. Too many ecosystems lack provenance infrastructure. But the situation is improving.

npm now supports provenance attestations through Sigstore. Maven Central is working on it. More projects are prioritizing reproducible builds. Security researchers and companies are investing in this infrastructure.

For now, organizations can:

1. **Verify provenance** where available. Prefer packages with attestations over those without.
2. **Rebuild critical dependencies** in controlled environments and compare results.
3. **Pin dependencies** to specific versions rather than ranges.
4. **Monitor for unexpected changes** between versions of dependencies.
5. **Contribute to reproducibility** by reporting non-reproducible builds upstream.

None of this is a complete solution. But each step reduces the attack surface and makes supply chain attacks harder to execute undetected.

The checksum verifies the download. The provenance verifies the build. The reproducibility verifies the source. All three together give you confidence that the code you deploy is the code you audited.
