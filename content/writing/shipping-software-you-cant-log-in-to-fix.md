---
title: "Shipping Software You Can't Log In to Fix"
date: 2026-10-05
draft: false
description: "Decisions from six years of software running in customers' own data centers, and what each one taught me about assumptions."
tags: ["on-prem", "kubernetes", "release engineering"]
---

For most of the last six years, the software I've worked on has run in places I can't log in to: customer data centers, government clusters, and enterprise networks where even getting a log bundle means a ticket to someone's security team. When something goes wrong in one of those environments, I don't get to open a shell and look around. I get a description of the problem, maybe a screenshot, and whatever logs the customer is allowed to send me.

Working this way changes how you make decisions. I'm not claiming anything in this post is novel, and people who've shipped on-prem software for longer than I have will recognize most of it. I'm writing it down because, across three companies, the calls that went well were the ones grounded in what customers were actually running, and the ones that went badly rested on an assumption I hadn't noticed I was making.

The thread that ties it together is that your software is a guest on someone else's machine. The more you know about that machine, the better your decisions get, and the less you know, the more you should design for being wrong.

## Choosing the database from the queries

At MixMode I was Director of Engineering. The product analyzed network traffic and used AI to find anomalies in it, and it shipped to customers as an OVA. The main complaint was that queries were slow. Everything lived in a stateful Python monolith backed by Elasticsearch, and we stored the data inefficiently, which made the slowness worse and used more disk than it needed to.

The obvious move would have been to tune Elasticsearch. Before deciding anything, we studied how the product actually queried the data, and it turned out every query was a known query. Nothing in the product needed free-form search, which is the thing Elasticsearch is best at. That changed the question from "how do we make Elasticsearch faster?" to "what's the best store for a fixed set of queries we fully understand?" We moved storage into Postgres, with wide tables shaped around exactly those queries. What we gave up was the flexibility to run arbitrary searches later, and given what we'd learned, that was a trade I was comfortable making.

The rest of the architecture followed from the same idea. I hired a team of senior Scala engineers and directed them on the first version of the replacement, which we called MixMode Next. We broke the monolith apart into Scala microservices that ingested and stored data through Redpanda, and the AI analysis became one stage in a data pipeline instead of a piece of the monolith. Because each service could scale on its own, we were able to design for 100 Gb/s of network traffic, which wasn't realistic when the only option was making one very large process bigger.

## Doing a migration twice on purpose

The less obvious decision at MixMode was moving the old monolith onto Kubernetes at all. On paper it looked like wasted work, since MixMode Next was going to replace it. But a large deal needed it, and the customer couldn't wait for the new system. So I moved the monolith onto Kubernetes as an intermediate step, knowing we'd do a second migration later, and I built the Helm chart and release process for MixMode Next, which is part of what landed a $20M contract with a major government defense agency. We installed with KOTS, although at that point it was all done by hand rather than through an integration with Replicated.

I think this kind of call is easy to get wrong in either direction. Engineers tend to resist doing work twice, and sales tends to promise things the architecture isn't ready for. In this case the customer need was concrete, the intermediate step was bounded, and it bought time for MixMode Next to be done properly instead of rushed.

What I didn't fully appreciate at the start was who would be running all of this. The people installing our software were network and security engineers, and most of them had no interest in running Kubernetes. That's a completely reasonable position -- it's a lot of new machinery to own when your actual job is watching network traffic -- and it's the same thing I see today at NetBox Labs.

## Testing at the wrong scale

At Anchore I built Kai, a Kubernetes inventory agent that now lives on GitHub as [k8s-inventory](https://github.com/anchore/k8s-inventory). It runs inside a customer's cluster, finds every image that's deployed, and dedupes them so the platform can check that each one has been scanned and meets the customer's SLAs for CVE counts. It cut analysis time by more than 60%.

This one is a decision I'd make differently today. I developed and tested it on small clusters with a handful of namespaces, and it worked well there. Then it reached some of our largest customers, who had thousands of namespaces, and it stopped keeping up and didn't scale horizontally the way I had assumed it would. Fixing that meant rethinking how the agent talked to the Kubernetes API and being much more careful about how many calls it made and how often. My test clusters were a guess about what customers ran, and I hadn't checked how good a guess it was.

## Designing for customers you can't see

When I joined NetBox Labs, the team had already replaced a very large Helm chart, with hundreds of template files, with a Kubernetes operator written in Rust. The operator manages a custom resource and Helm only deploys the operator itself, which is much easier to maintain. I wasn't part of that decision, but combined with shipping through Replicated's Embedded Cluster and KOTS, it gives customers an install that doesn't require them to understand Kubernetes. After MixMode, that matters a lot to me.

The change I led this year was routing. In our 2.2 release we moved every install off ingress-nginx and onto Traefik and the Gateway API, and existing customers upgraded in place. Two design decisions shaped it. First, we kept a fallback: on older clusters without the Gateway API, the Helm chart falls back to ingress-nginx, because customers upgrade their clusters on their own schedule and we didn't want the upgrade to force theirs. Second, we leaned heavily on automated end-to-end testing.

We still needed a patch release. On a customer's system, the new setup claimed a port that their Prometheus needed. We didn't actually need that port, so the patch stopped claiming it. The more important change came afterward: we built out a broader test matrix that simulates the setups we see most often in customer environments, along with the ones we expect to see next. Instead of testing against our own idea of a cluster, we now test against a set of clusters modeled on our customers'.

## What I'd suggest

If you're making decisions for software that ships into environments you don't control, these are the habits I'd start with. People and teams work differently, so take whatever is useful and ignore the rest.

1. **Let the real usage pick the design.** Study what customers actually do before choosing a technology. At MixMode, one look at the query patterns made the database decision for us.
2. **Be willing to do work twice when the customer need is real.** A bounded intermediate step can buy the time to do the long-term version properly.
3. **Test against a model of your customers, not your laptop.** Build a test matrix from the setups customers run today and the ones you expect them to run next.
4. **Design fallbacks for customers who move slower than you.** They upgrade their infrastructure on their own schedule.
5. **Don't take resources you don't need, and hide Kubernetes from people who didn't ask for it.** Something else on that node may need the port, and the person installing your software probably just wants it to work.

None of these are new ideas. What I've found is that they're easy to skip when you can SSH into production and fix things by hand, and much harder to skip once you can't.
