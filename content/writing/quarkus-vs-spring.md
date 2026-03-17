---
title: "Quarkus vs. Spring Boot"
date: 2020-07-01
description: "How LogicMonitor evaluated and migrated from Spring Boot to Quarkus, achieving 85% CPU and 88% memory reductions"
tags: ["java", "quarkus", "kafka", "kubernetes"]
---

At LogicMonitor, I led the evaluation and migration from Spring Boot to Quarkus for our microservice architecture. The results: 85% reduction in CPU usage, 88% reduction in memory, and startup times dropping from 15 seconds to 2 seconds.

The article covers our technology stack evaluation (Quarkus vs. Micronaut vs. Helidon), Kubernetes integration, Kafka producer/consumer challenges with SmallRye Reactive Messaging, and the metrics we used to validate the migration.

[Read the full article on LogicMonitor's blog →](https://www.logicmonitor.com/blog/quarkus-vs-spring)
