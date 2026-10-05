---
title: "Proof Over Trust: How Rebuilt Packages, SLSA 3, and Cosign Fit Together"
date: 2026-10-05
draft: false
description: "What rebuilding 500k+ open source artifacts from source at Chainguard taught me about SLSA 3 provenance, cosign, and why 'nearly reproducible' still needs proof."
tags: ["supply chain security", "slsa", "sigstore", "cosign"]
---

When you add a dependency from Maven Central or npm, you trust a lot of things you can't see. You trust that the artifact was built from the source in the project's repository, that nobody tampered with it between the maintainer's laptop and the registry, and that the maintainer's laptop wasn't compromised in the first place. Most of the time that trust holds. When it doesn't, the artifact itself gives you no way to find out.

For two years at Chainguard I worked on replacing that trust with evidence. I built and maintained the Java and JavaScript ecosystem rebuilders, which rebuilt popular open source packages from source and shipped each one with SLSA 3 provenance and an SBOM. By the time I left, that covered more than 500,000 artifacts across 44+ enterprise customers.

Most writing about SLSA and Sigstore stays at the level of acronyms. This post shows how the pieces fit together. Everything here is public, and I'll say which parts are general and which were specific to what we built.

## The rebuild is the point

The most important thing we did wasn't the signature. It was rebuilding each package from source in an environment we controlled, instead of redistributing whatever binary the maintainer happened to upload.

Most registry artifacts are built somewhere you can't inspect. A JAR on Maven Central might come from a CI system, or from someone's laptop the night before a release. A rebuild has two inputs: the source code and a build environment you know. If someone slipped something malicious into an upstream binary without putting it in the source, it doesn't make it into the rebuilt artifact.

Our builds ran on Chainguard's own container images, which are minimal and built with the same supply chain discipline Chainguard sells. Argo Workflows ran the build orchestration. A colleague had chosen Argo for the Python rebuilder, and I moved the Java rebuilder from container-based builds onto it so every ecosystem ran the same way. That consistency paid off. It let us automate more than 2,000 of the most popular Java libraries, and it made it easy to add data aggregation and reporting pipelines that tracked rebuild coverage against what our customers used. The hard part was learning Argo Workflows well. I also added rebuild configuration for complex builds that needed custom steps, because plenty of real libraries don't build with the defaults.

## "Nearly reproducible" isn't enough

In an ideal world, every build is reproducible. The same source and toolchain produce byte-for-byte identical output, and anyone can verify an artifact by rebuilding it and comparing hashes.

Our builds were nearly reproducible, which is a different thing. Timestamps get embedded inside packages, and some tools write random values into their output. The result works the same, but the hash differs, so "rebuild it and compare" can't verify anything on its own.

Provenance fills that gap. If you can't prove where an artifact came from by reproducing it, you need a trustworthy record of how it was built.

## What SLSA 3 requires

SLSA (Supply-chain Levels for Software Artifacts) defines levels for how much you can trust a build's provenance. At Build Level 3, the requirements that matter most are roughly these:

1. **The build runs on a hosted build platform,** not on a developer's machine.
2. **Builds are isolated** from each other, so one build can't influence another.
3. **The platform generates the provenance,** not the build steps themselves.
4. **The signing material is out of reach of the build.** User-defined build steps can't access the keys that sign the provenance, so a compromised build can't forge its own paperwork.

The provenance itself is an [in-toto](https://in-toto.io/) attestation: a JSON document that names the artifact by its digest and describes how it was built. Trimmed down, it looks like this:

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

Three fields carry the weight. The subject digest ties the document to one exact artifact. The source reference says what it was built from. The builder ID says what built it.

## Where cosign fits

A provenance document is only useful if you can tell it hasn't been forged. That's the job of [Sigstore](https://www.sigstore.dev/) and its CLI, cosign.

The clever part of Sigstore is keyless signing. Instead of managing a long-lived private key, the signer authenticates with an OIDC identity, such as a CI workload's identity. Fulcio, Sigstore's certificate authority, issues a short-lived certificate bound to that identity. The signer signs, and Rekor, a public transparency log, records the event. Verification checks three things: the signature is valid, the certificate was issued to the identity you expect, and the signing event is in the transparency log.

In general terms, verifying a signed provenance attestation looks like this:

```sh
cosign verify-attestation \
  --type slsaprovenance1 \
  --certificate-identity "<the builder identity you expect>" \
  --certificate-oidc-issuer "<the issuer you expect>" \
  <artifact reference>
```

The identity flags are what matter. A valid signature from the wrong identity proves nothing.

## Customers check without asking us

None of this matters unless customers verify. They needed to prove that a Chainguard library was a Chainguard library, without opening a ticket and taking our word for it.

So I built LibCheck, which shipped as `chainctl libraries verify`. It's a Go CLI that checks a package's provenance and compares a customer's container images against Chainguard's base images. The rebuilders produce the evidence. LibCheck lets customers check it on their own terms.

## From rebuilding to remediation

Once you can rebuild a package from source with trustworthy provenance, you can also change what you build. The work moved in that direction. Chainguard started backporting fixes for critical and high-severity CVEs into older versions of Python libraries, so customers could take a security fix without a disruptive upgrade. Java was next when I left, and Chainguard has since [made CVE remediation for Java generally available](https://www.chainguard.dev/unchained/chainguard-libraries-for-java-is-now-ga-and-includes-cve-remediation), starting with the Spring Boot ecosystem.

It's the same foundation doing more work. A remediated package is still rebuilt from source, still ships with provenance and an SBOM, and still verifies the same way.

## The habits

If you care about supply chain security for your own software, start here:

1. **Rebuild from source where you can.** The signature is the receipt. The rebuild is what you're paying for.
2. **Chase reproducibility, but don't depend on it.** Timestamps and random values will keep showing up. Provenance covers the gap.
3. **Keep signing material away from build steps.** If the build can sign its own provenance, a compromised build can forge it.
4. **Verify identity, not just signatures.** Pin the builder identity and issuer you expect.
5. **Give your users a way to verify without you.** Evidence that only the vendor can check is still just trust.
