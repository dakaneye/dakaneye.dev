---
title: "Proof Over Trust: How Rebuilt Packages, SLSA 3, and Cosign Fit Together"
date: 2026-10-04
draft: true
description: "What rebuilding 500k+ open source artifacts from source at Chainguard taught me about SLSA 3 provenance, cosign, and why 'nearly reproducible' still needs proof."
tags: ["supply chain security", "slsa", "sigstore", "cosign"]
---

When you add a dependency from Maven Central or npm, you're trusting a lot of things you can't see. You're trusting that the artifact was built from the source code in the project's repository, that nobody tampered with it between the maintainer's laptop and the registry, and that the maintainer's laptop wasn't compromised in the first place. Most of the time that trust is justified. When it isn't, there's usually no way to find out from the artifact itself.

For two years at Chainguard I worked on replacing that trust with evidence. I built and maintained the Java and JavaScript ecosystem rebuilders, which rebuilt popular open source packages from source and shipped each one with SLSA 3 provenance and an SBOM. By the time I left, that covered more than 500,000 artifacts across 44+ enterprise customers.

I want to explain how the pieces actually fit together, because I found that a lot of writing about SLSA and Sigstore stays at the level of acronyms. I'm not going to cover anything that isn't already public, and I'll try to be clear about which parts are general and which were specific to what we built.

## The real value is the rebuild

The most important thing we did wasn't the signature. It was rebuilding the package from source in an environment we controlled, instead of redistributing whatever binary the maintainer happened to upload.

That distinction matters because most registry artifacts are built somewhere you can't inspect. A JAR on Maven Central might have been built on a CI system, or it might have been built on someone's laptop the night before a release. Rebuilding from source means the only inputs are the source code and a build environment you know, so if something malicious was slipped into an upstream binary without being in the source, it doesn't make it into the rebuilt artifact.

Our builds ran on Chainguard's own container images, which are minimal and built with the same supply chain discipline Chainguard sells. The build orchestration ran on Argo Workflows. A colleague had chosen Argo for the Python rebuilder, and I moved the Java rebuilder from container-based builds onto it so that the ecosystems ran the same way. That consistency paid off: it let us automate more than 2,000 of the most popular Java libraries, and it made it straightforward to add data aggregation and reporting pipelines that tracked rebuild coverage against what our customers actually used. Most of the difficulty was learning Argo Workflows well, not fighting it. I also added rebuild configuration for complex builds that needed custom steps, since plenty of real libraries don't build with the defaults.

## Why "nearly reproducible" isn't enough

In an ideal world, every build would be reproducible: the same source and the same toolchain would produce byte-for-byte identical output, and anyone could verify an artifact by rebuilding it and comparing hashes.

In practice, our builds were nearly reproducible, which is a different thing. Builds sometimes produce different bytes from the same inputs. Timestamps get embedded inside packages, and some tools write randomly generated values into their output. The result is functionally identical, but the hash is different, so "rebuild it and compare" doesn't work as a verification method on its own.

That's where provenance comes in. If you can't prove where an artifact came from by reproducing it, you need a trustworthy record of how it was built.

## What SLSA 3 actually requires

SLSA (Supply-chain Levels for Software Artifacts) defines levels for how much you can trust a build's provenance. At Build Level 3, the important requirements are roughly these:

1. **The build runs on a hosted build platform,** not on a developer's machine.
2. **Builds are isolated** from each other, so one build can't influence another.
3. **The platform generates the provenance,** not the build steps themselves.
4. **The signing material is out of reach of the build.** User-defined build steps can't access the keys used to sign the provenance, so a compromised build can't forge its own paperwork.

The provenance itself is an [in-toto](https://in-toto.io/) attestation: a JSON document that names the artifact by its digest and describes how it was built. Trimmed down, it looks something like this:

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    { "name": "example-lib-1.2.3.jar", "digest": { "sha256": "…" } }
  ],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "…",
      "externalParameters": { "source": "git+https://github.com/example/lib@refs/tags/v1.2.3" }
    },
    "runDetails": {
      "builder": { "id": "…" }
    }
  }
}
```

The key fields are the subject digest, which ties the document to one exact artifact, the source reference, which says what it was built from, and the builder ID, which says what built it.

## Where cosign fits

A provenance document is only useful if you can tell it hasn't been forged. That's the job of [Sigstore](https://www.sigstore.dev/) and its CLI, cosign.

The part of Sigstore that I think is clever is keyless signing. Instead of managing a long-lived private key, the signer authenticates with an OIDC identity, such as a CI workload's identity. Sigstore's certificate authority, Fulcio, issues a short-lived certificate bound to that identity, the signature is made, and the event is recorded in Rekor, a public transparency log. Verification then checks three things: that the signature is valid, that the certificate was issued to the identity you expect, and that the signing event is in the transparency log.

In general terms, verifying a signed provenance attestation looks like this:

```sh
cosign verify-attestation \
  --type slsaprovenance1 \
  --certificate-identity "<the builder identity you expect>" \
  --certificate-oidc-issuer "<the issuer you expect>" \
  <artifact reference>
```

The identity flags are the important part. A valid signature from the wrong identity proves nothing.

## Letting customers check without asking us

All of this only matters if customers actually verify. They needed to be able to prove that a Chainguard library was actually a Chainguard library, without opening a ticket and taking our word for it.

That's why I built LibCheck, which shipped as `chainctl libraries verify`. It's a Go CLI that checks a package's provenance and compares a customer's container images against Chainguard's base images. The rebuilders produce the evidence; LibCheck is how a customer checks it on their own terms.

## From rebuilding to remediation

Once you can rebuild a package from source with trustworthy provenance, you can also change what you build. That's the direction the work evolved: Chainguard started backporting fixes for critical and high-severity CVEs into older versions of Python libraries, so customers could take a security fix without a disruptive upgrade. Java was next when I left, and Chainguard has since [made CVE remediation for Java generally available](https://www.chainguard.dev/unchained/chainguard-libraries-for-java-is-now-ga-and-includes-cve-remediation), starting with the Spring Boot ecosystem.

It's the same foundation doing more work. A remediated package is still rebuilt from source, still ships with provenance and an SBOM, and is still verifiable the same way.

## What I'd suggest

If you're thinking about supply chain security for your own software, these are the things I'd keep in mind. Your situation will differ, so take what's useful.

1. **Rebuild from source where you can.** The signature is the receipt. The rebuild is what you're actually paying for.
2. **Chase reproducibility, but don't depend on it.** Timestamps and random values will keep showing up. Provenance covers the gap.
3. **Keep signing material away from build steps.** If the build can sign its own provenance, a compromised build can forge it.
4. **Always verify identity, not just signatures.** Pin the builder identity and issuer you expect.
5. **Give your users a way to verify without you.** Evidence that only the vendor can check is still just trust.
