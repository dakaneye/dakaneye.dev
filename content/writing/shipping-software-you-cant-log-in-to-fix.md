---
title: "Shipping Software You Can't Log In to Fix"
date: 2026-10-05
draft: false
description: "Decisions from six years of software running in customers' own data centers, and what each one taught me about assumptions."
tags: ["on-prem", "kubernetes", "release engineering"]
---

For six years, most of the software I've built has run where I can't log in: customer data centers, government clusters, and enterprise networks where a log bundle takes a ticket to someone's security team. When it breaks, I don't get a shell. I get a description, maybe a screenshot, and whatever logs the customer is allowed to send.

That constraint has taught me more than anything else in my career. Across three companies, the calls that went well came from knowing what customers ran. The calls that went badly rested on an assumption I didn't know I was making.

Your software is a guest on someone else's machine. Learn everything you can about that machine, and design for being wrong about the rest.

## Let the queries pick the database

At MixMode I was Director of Engineering. The product analyzed network traffic and used AI to find anomalies, and it shipped to customers as an OVA. The top complaint was slow queries. Everything lived in a stateful Python monolith on Elasticsearch, and we stored the data inefficiently, which made queries slower and wasted disk.

The obvious move was to tune Elasticsearch. Before deciding, we studied how the product queried the data, and every query turned out to be a known query. Nothing needed free-form search, the one thing Elasticsearch is best at. So the question changed from "how do we make Elasticsearch faster?" to "what's the best store for a fixed set of queries we fully understand?" We moved storage to Postgres, with wide tables shaped around those queries. We gave up the option of arbitrary search later. Given what we'd learned, that was a trade worth making.

The rest of the architecture followed from the same idea. I hired a team of senior Scala engineers and directed them on the first version of the replacement, MixMode Next. We broke the monolith into Scala microservices that ingested and stored data through Redpanda, and the AI analysis became one stage in a data pipeline. Each service scaled on its own, so we could design for 100 Gb/s of network traffic. With one giant process, that number was never realistic.

## Do the migration twice when the customer is real

The less obvious call at MixMode was moving the old monolith onto Kubernetes at all. MixMode Next was going to replace it, so on paper it was wasted work. But a large deal needed it, and the customer couldn't wait. I moved the monolith onto Kubernetes as an intermediate step, knowing we'd migrate again later. I also built the Helm chart and release process for MixMode Next, which was part of what landed a $20M contract with a major government defense agency. We installed with KOTS, by hand, before any integration with Replicated.

Teams get this call wrong in both directions. Engineers resist doing work twice. Sales promises what the architecture can't deliver yet. Here the need was concrete, the intermediate step was bounded, and it bought MixMode Next the time to be done right instead of rushed.

What I underestimated was who would run all of this. Our installers were network and security engineers, and most of them had no interest in running Kubernetes. That's a fair position: it's a lot of machinery to own when your job is watching traffic. I see the same thing at NetBox Labs today.

## My test clusters were a guess

At Anchore I built Kai, a Kubernetes inventory agent that now lives on GitHub as [k8s-inventory](https://github.com/anchore/k8s-inventory). It runs inside a customer's cluster, finds every deployed image, and dedupes them so the platform can check that each one was scanned and meets the customer's SLAs for CVE counts. It cut analysis time by more than 60%.

I'd do this one differently. I developed and tested it on small clusters with a handful of namespaces, and it worked. Then it reached our largest customers, with thousands of namespaces, and it fell behind. It didn't scale horizontally the way I'd assumed. The fix meant rethinking how the agent talked to the Kubernetes API, and cutting how many calls it made and how often.

The real mistake came before any of that code. My test clusters were a guess about what customers ran, and I never checked the guess.

## Test against your customers' clusters, not yours

When I joined NetBox Labs, the team had already replaced a Helm chart with hundreds of template files with a Kubernetes operator written in Rust. The operator manages a custom resource, and Helm only deploys the operator, which is far easier to maintain. I wasn't part of that decision. Paired with Replicated's Embedded Cluster and KOTS, it gives customers an install that doesn't require them to know Kubernetes. After MixMode, I care about that a lot.

This year I led the routing change. In our 2.2 release we moved every install off ingress-nginx and onto Traefik and the Gateway API, and existing customers upgraded in place. Two decisions shaped it. First, we kept a fallback: on older clusters without the Gateway API, the Helm chart falls back to ingress-nginx. Customers upgrade their clusters on their own schedule, and our release shouldn't force theirs. Second, we leaned hard on automated end-to-end tests.

We still shipped a patch. On one customer's system, the new setup claimed a port their Prometheus needed. We didn't need that port, so the patch let it go. The bigger fix came afterward: a test matrix that simulates the setups we see most often in customer environments, plus the ones we expect next. We used to test against our idea of a cluster. Now we test against clusters modeled on our customers'.

## The habits

If you ship software into environments you don't control, start here:

1. **Let real usage pick the design.** At MixMode, one look at the query patterns made the database decision for us.
2. **Do work twice when the customer need is real.** A bounded intermediate step buys the time to build the long-term version properly.
3. **Test against a model of your customers, not your laptop.** Build the matrix from what customers run today and what they'll run next.
4. **Build fallbacks for customers who move slower than you.** They upgrade on their schedule, not yours.
5. **Don't take resources you don't need, and hide Kubernetes from people who didn't ask for it.** Something else on that node may need the port, and the person installing your software wants it to work.

These habits are easy to skip when you can SSH into production and fix things by hand. Ship as if you can't. For most of your customers, you can't.
