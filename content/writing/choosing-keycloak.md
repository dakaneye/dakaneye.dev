---
title: "Choosing Keycloak for an On-Prem Platform"
date: 2026-10-04
draft: true
description: "How we chose an identity provider to bundle with NetBox Enterprise, why SAML decided it, and what it took to make a login survive losing a node."
tags: ["identity", "keycloak", "saml", "oidc", "on-prem"]
---

This summer I owned a decision about which identity provider to bundle with NetBox Enterprise, the version of NetBox our customers run in their own data centers. We chose Keycloak. I want to write up how we got there, because identity is one of those decisions that's expensive to change later, and most of the comparisons I found while researching it were written for SaaS products, where the constraints are very different.

I'm not recommending that everyone use Keycloak. Our requirements were specific, and I'll try to be clear about which of them drove the decision, so that if yours are different you can tell where your answer would change. I'll also be clear about which parts were my work and which weren't, because a lot of good engineering by other people made this decision easier.

## What we needed

Our new platform apps sit behind an authorization service that another team at NetBox Labs built. It accepts OIDC tokens, and in our cloud product those tokens come from a hosted login service. On-prem, we needed something we could ship alongside the product to play that role. Written down, the requirement was a self-hostable, permissively licensed, HA-capable identity provider that accepts SAML and LDAP from the customer's own identity systems and issues OIDC tokens our authorization service accepts.

Two facts about our customers shaped most of that sentence.

The first is that most of them don't run an OIDC-compatible identity provider. They run SAML or LDAP. An earlier plan had been to let customers bring their own OIDC provider, and that would have worked for a minority of them and not for everyone else.

The second is that some of them are air-gapped. A login flow that redirects the browser to an external identity service can't work offline, so whatever we chose had to run entirely inside the customer's environment. Shipping bundled identity that only works when connected would remove the reason we were building it.

## What we looked at

We had a good starting point. A colleague on the authorization team had already written an RFC proposing Keycloak, and there was earlier research on what customers needed, so this wasn't a cold start. My job was to test that proposal against the alternatives seriously enough that we'd trust the answer.

I ran a hands-on spike comparing Keycloak with kanidm, and a separate canvass of SAML support across the field. The rest of the options mostly fell out quickly once the requirements were written down:

- **kanidm** was the most interesting alternative. It's a single Rust binary with an embedded database and good defaults, and I liked a lot about it. But it can't act as a SAML identity provider, and SAML was the deciding requirement. Its high availability story also needed manual replication that we'd have had to build around.
- **authentik** was the closest peer to Keycloak. It lost on maturity, scale, and governance, and on an open-core split that puts some features under an enterprise license.
- **ZITADEL** is AGPL-licensed, which our open source policy rules out for software we bundle.
- **FusionAuth** is proprietary, which fails the premise of bundling an open source component.
- **Ory Hydra and Kratos** are OAuth2 and OIDC only, with no SAML identity provider.
- **Authelia** is a forward-auth proxy that needs a separate user backend.
- **LemonLDAP::NG** is capable, but it's less container-native, and its GPL license is a less clean fit for redistribution.
- Several newer projects were libraries or UI layers rather than standalone identity providers that could run air-gapped.

## Why Keycloak won

In order of weight, the reasons were:

1. **It was the only option with full SAML, LDAP, and OIDC federation.** That alone narrowed the field to one.
2. **It's Apache-2.0 licensed,** which is clean to redistribute.
3. **It has CNCF governance and a large community,** which matters for something we'll be shipping and patching for years.
4. **It can run highly available on the Postgres we already ship,** so it doesn't add a new database to every install.
5. **It had already worked with our authorization service.** In the spike, a real Keycloak token was initially rejected because it was missing an organization claim, and it was accepted after adding a single protocol mapper. That was the kind of result I wanted from a spike: a real failure, a small fix, and confidence that the integration wasn't going to be a project of its own.

## Keeping login separate from permissions

The architecture around Keycloak wasn't my design, but it's a big part of why the choice was low-risk, so it's worth explaining.

Our platform separates authentication from authorization very strictly. The login service has one job: proving who someone is. After that first token exchange, nothing reads from it again. Everything about what that person is allowed to do lives in the authorization service, and the tokens it issues carry identity, never permissions, because permissions can be large and go stale the moment they're copied into a token.

The practical consequence is that the login service is swappable. Our cloud product uses a hosted login service, and NetBox Enterprise uses Keycloak, and the authorization service treats them the same way because an adapter normalizes every provider to one identity shape. That's what turned "which identity provider should we bundle?" into a configuration decision rather than a rewrite, and it's a big reason I was comfortable making the call on the strength of a spike.

## Surviving a lost node

For on-prem customers, a login that breaks when a node goes down is a support ticket waiting to happen, so high availability was part of the requirement, not an afterthought.

The good news was that recent Keycloak versions already cluster by default, discovering each other through a table in the shared Postgres database. When I did the design pass, the real change turned out to be small: our deployment had a hardcoded single instance, which we replaced with up to three replicas depending on the number of nodes.

The more interesting work was proving it, because the failure mode is subtle. If clustering silently fails, a login flow issues an authorization code on one replica and redeems it on another, and that replica has never seen the code. Roughly two logins in three would fail, and every health indicator could still be green. On top of that, recent Keycloak versions persist user sessions to the database, so a test that only checks whether a session survives doesn't actually prove clustering works.

So the tests check three things. First, that every replica reports the same cluster membership. Second, that a login started on one replica and finished on another succeeds after the first replica is killed mid-flow. Third, that the same login survives a full node power loss.

A few problems turned up before any of that ran. An adversarial review of my design found that with three replicas, losing one pod would have made our status reporting mark single sign-on as unhealthy, even though logins still worked; an HTTP-only test would have passed while the status was wrong. We also found that one installation path could silently stay pinned to a single replica forever, which we fixed by adding an explicit replica setting. Neither of those would have shown up in a test that only checked whether login worked.

One thing high availability doesn't cover is upgrades. Our upgrade testing showed that a Keycloak version change recreates all replicas, so there's a short window with no ready replicas. Three replicas protect you from losing a node, not from a version bump, and it was better to measure that than to assume it.

## What it costs

Keycloak isn't free to run, and I think a decision write-up that skips the costs isn't worth much.

- **It's the heaviest component in our stack.** Each replica wants around 2 GB of memory, so a highly available setup needs roughly 4 to 6 GB, and it needs explicit memory limits because the JVM sizes itself from them.
- **Upgrades include irreversible database migrations,** so every upgrade needs a snapshot first and a rollback that's been tested.
- **Only the latest release gets patches.** There's no community long-term support line, and minor releases come out roughly four times a year, so we commit to re-pinning on a schedule rather than whenever we get around to it.
- **Air-gapped customers get patches later,** because a fix has to be re-pinned, re-bundled, and installed offline.
- **It adds security surface:** a login endpoint, an admin console, and federation endpoints. We mitigate that with a hardened, low-CVE container image and a security review before general availability.

## Was it really a choice?

Honestly, it wasn't much of a decision. Once the requirements were written down, Keycloak was the only option that checked every box, and I would have had to choose it whether or not I liked it.

I think that's the most useful thing to take from this. The hard work wasn't picking between finalists. It was writing down what our customers actually needed, testing the leading proposal seriously enough to trust it, and then proving that the result held up when a node went away. If you do the first part well, the decision often makes itself.
