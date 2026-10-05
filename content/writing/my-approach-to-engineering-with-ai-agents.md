---
title: "My Approach to Engineering With AI Agents"
date: 2026-10-05
draft: false
description: "How I use AI agents every day, from specs to tickets to PRs, what happened when two teams adopted them, and why our release process splits work between machines, agents, and people."
tags: ["ai", "claude code", "release engineering", "engineering leadership"]
---

When I started using AI coding tools seriously, I expected two things: I'd work a lot faster, and the code would be more correct. The first was partly right. The second was mostly wrong. How I work now is built around that gap.

I use agents every day, and they've changed how I work for the better. I also have open questions about them, which I'll get to at the end. This post follows the order work happens: specs, tickets, fixes, and the routine work around them. Then it covers two teams adopting these tools, and a release project at NetBox Labs that shaped where I think AI belongs and where it doesn't.

## Spec first

My results improved most when I slowed down at the start. Agents are very good at building the wrong thing quickly, so most of my effort now goes into getting the design right before any code exists.

For anything bigger than a small fix, I start with a spec, using the [Superpowers](https://github.com/obra/superpowers) workflow. The design gets settled in the brainstorming step, and for that I use Matt Pocock's grill-me skill. It interviews me about the design until every open question is resolved instead of glossed over. From there, Superpowers turns the design into a plan of small tasks, each with its own tests. It executes the plan task by task, with a fresh agent per task and a review at the end. The plan becomes the contract. When the agent drifts, I compare its work against the plan, not against my memory of what I meant.

It feels slower at first. The difference in what comes out the other end is large enough that I don't skip it anymore.

## Tickets as prompts

At NetBox Labs we moved the same idea one step earlier, into how we file work. We write Linear issues as prompts: the description is something another Claude session could pick up and execute without asking a question. It names the mechanism, how to reproduce the problem, and how we'll know it's fixed. A ticket good enough for an agent is also a much better ticket for a person.

I built two workflows on top of that. `/nbe-fix` takes a single issue from ticket to reviewable PR in one session. It reads the issue and everything attached to it, finds the mechanism in the code, and reproduces the failure on a real instance. Then it fixes the failure and proves the fix on that same instance before opening the PR. Each stage is gated on captured evidence, not on the agent saying it's done. No reproduction transcript, no fix. No verification transcript, no PR.

`/nbe-fleet` does the same for a batch of related tickets, in two phases. The design phase classifies each ticket, writes a design doc where the approach isn't settled yet, and rewrites the ticket into an executable prompt. It doesn't touch CI, a cluster, or a remote. The execute phase dispatches those tickets into separate git worktrees and reviews and gates each one before anything leaves my machine. Then it pushes, verifies the change live, and marks the PR ready once CI is green.

The last piece isn't mine, but I use it constantly. Our QA tooling generates a test plan for a change and runs it on the surfaces the change touches. For us, that means the different ways customers install NetBox Enterprise. It closes a gap I used to fill by hand: knowing not just that the tests passed, but that the right things were tested in the right places.

## The routine work around the work

On the tooling side, I'm proudest of Switchboard. I started it in late June, and it has about 1,270 commits as I write this. It's internal, so it isn't public, but the idea is simple. It's a local agent that carries the routine parts of an engineer's day across GitHub, Linear, and Slack, so I can run many workstreams without holding each one in my head.

On every sweep it moves my open PRs toward merge: it resolves conflicts, fixes failing CI, and drafts replies to review comments in worktrees. It drafts code reviews for PRs that request me, including requests it finds in Slack. In lead mode it triages new Linear issues and checks workflow hygiene. One dashboard shows all of it.

The most important design decision is what it doesn't do on its own. Every review, every Linear write, and every merge waits for my click. Every push stays human-initiated behind a hardware key touch. Only two low-risk writes happen automatically, and a kill switch covers those. Switchboard does the legwork. I keep the decisions.

Once writing code got cheaper, review became the slow part. So I also built [claude-review-code](https://github.com/dakaneye/claude-review-code), a review skill with 12 specialist subagents and checklists for Go, Node, Java, Python, Bash, and Terraform. It takes a first pass at the mechanical problems, so human review can focus on design and intent. That's where my early expectation of "more correct" needed the most help.

## Two teams, two adoption curves

I've now watched two teams adopt these tools. Chainguard adopted them slowly. NetBox Labs adopted them fast.

At NetBox Labs I standardized the team's Claude Code skills and workflows instead of letting everyone build their own. When every engineer has private prompts and agents, you get as many quality bars as you have engineers, and no easy way to tell them apart. Shared skills give you one bar, and improving it once improves it for everyone. Beyond the workflows above, we share agents for scoping tickets, tracking release readiness, and on-call handoff. Automated review works the same way in every repo we ship. We also changed where QA spends its time. Instead of writing a manual test plan for each ticket, QA now focuses on automated coverage and regression testing.

## Where AI belongs in a release

The project that shaped my thinking most was one I led at NetBox Labs this summer, called Release Guard Rails.

Three releases in a row, 2.1.0 through 2.1.2, failed on preventable mechanical errors. Pins were merged after a failed plan. Fixes never reached the release branch. A promotion ran and silently did nothing. None of these were hard problems, and nobody involved was careless. The process depended on people being careful at every step, every time. No process should depend on that.

The goal was to make those failures impossible, and the design split the work into three layers:

1. **Guard rails block mechanically.** Required checks, branch rulesets, and verification jobs. One check confirms that every fix labeled for a release is an ancestor of the release branch. Another validates plugin pins against the NetBox version at build time. A job after every promotion asserts that what shipped matches what was planned.
2. **A release driver handles the mechanics.** It's a Claude Code skill that runs the runbook steps and writes the release record, with evidence attached for each gate. We started it in status mode on purpose, where it reports and documents instead of acting, before letting it do more. Ship-day finalization, meaning the tag, the GitHub Release, and the appliance build, now fires automatically.
3. **Humans keep the judgment calls.** Sign-offs, scope, and demotions stay with people, and that split doesn't change as more automation lands.

Two governance rules made it stick. Every rail cites the specific failure that created it, so nobody has to guess why a check exists. And the team ratifies rails for enforcement at release retros, so people decide together what becomes mandatory instead of having rules appear on them. Releases became more reliable, with fewer errors during the release itself.

I apply this model to AI generally, and it's the same one behind Switchboard and the fix workflows. Agents are good at running mechanics and writing things down. Deterministic checks are better at blocking mistakes, because they don't get creative. People should still make the calls that need judgment.

## What I'm still unsure about

I have two open questions I can't answer yet.

The first is whether AI makes me faster in a way I could prove. It feels faster, and I get more done in parallel than I used to. But I've also spent time reviewing, correcting, and re-prompting work that I might have written correctly myself the first time. I don't have a clean measurement that settles it.

The second is what I call dark code: code that's in the repository, passes every check, and that no person wrote or fully understands. Specs, evidence gates, and guard rails reduce the risk. I'm not convinced they remove it, and I suspect the cost shows up later, not sooner.

I don't work for, invest in, or advise any AI companies. Nearly all of my experience is with Claude, so I can't speak to how other tools compare.
