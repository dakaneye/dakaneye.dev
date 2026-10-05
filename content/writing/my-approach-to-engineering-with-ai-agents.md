---
title: "My Approach to Engineering With AI Agents"
date: 2026-10-04
draft: true
description: "How I use AI agents every day, from specs to tickets to PRs, what happened when two teams adopted them, and why our release process splits work between machines, agents, and people."
tags: ["ai", "claude code", "release engineering", "engineering leadership"]
---

When I started using AI coding tools seriously, I expected two things: that I'd work a lot faster, and that the code would be more correct than it turned out to be. The first expectation was partly right. The second was mostly wrong, and how I've adjusted to that is what this post is about.

There's a lot of writing about AI and software engineering that's either very excited or very dismissive. My experience has been more ordinary than either. I use agents every day, I think they've changed how I work for the better, and I still have open questions about them that I'll get to at the end. I'm going to walk through how I work now, roughly in the order work happens: specs, tickets, fixes, and the routine work around them. Then I'll cover what happened when two teams adopted these tools, and a release project at NetBox Labs that shaped how I think about where AI belongs and where it doesn't.

## Spec first

The biggest single improvement in my results came from slowing down at the start. Agents are very good at building the wrong thing quickly, so most of my effort now goes into making sure the thing is right before any code exists.

For anything bigger than a small fix, I start with a spec, using the [Superpowers](https://github.com/obra/superpowers) workflow. The brainstorming step is where the design gets settled, and for that I use Matt Pocock's grill-me skill, which interviews me about the design until the open questions are actually resolved rather than glossed over. From there, Superpowers turns the design into a plan with small tasks that each carry their own tests, and executes it task by task with a fresh agent per task and a review at the end. The plan becomes the contract. When the agent drifts, I compare its work against the plan instead of against my memory of what I meant.

It's not glamorous, and it feels slower at first. But the difference in what comes out the other end is large enough that I don't skip it anymore.

## Tickets as prompts

At NetBox Labs the same idea moved one step earlier, into how we file work. We write Linear issues as prompts: the description is something another Claude session could pick up and execute without asking a question. That means it names the mechanism, how to reproduce the problem, and how we'll know it's fixed. It turns out that a ticket good enough for an agent is also a much better ticket for a person.

I built two workflows on top of that. `/nbe-fix` takes a single issue from ticket to reviewable PR in one session. It reads the issue and everything attached to it, finds the mechanism in the code, reproduces the failure on a real instance, fixes it, and then proves the fix on that same instance before opening the PR. Each stage is gated on captured evidence rather than on the agent saying it's done: no reproduction transcript, no fix; no verification transcript, no PR.

`/nbe-fleet` does the same for a batch of related tickets, in two phases. The design phase classifies each ticket, writes a design doc where the approach isn't settled yet, and rewrites the ticket into an executable prompt, without touching CI, a cluster, or a remote. The execute phase dispatches those tickets into separate git worktrees, reviews and gates each one before anything leaves my machine, pushes, verifies the change live, and marks the PR ready once CI is green.

The last piece isn't mine, but I use it constantly. Our QA tooling generates a test plan for a change and then executes it on the surfaces the change actually touches, which for us means the different ways customers install NetBox Enterprise. That closes a gap I used to fill by hand: knowing not just that the tests passed, but that the right things were tested in the right places.

## The routine work around the work

The project I'm proudest of on the tooling side is Switchboard, which I started in late June and which has about 1,270 commits as I write this. It's an internal tool, so it isn't public, but the idea is simple enough to describe. It's a local agent that carries the routine parts of an engineer's day across GitHub, Linear, and Slack, so I can run many workstreams without holding each one in my head.

On every sweep it moves my open PRs toward merge by resolving conflicts, fixing failing CI, and drafting replies to review comments in worktrees. It drafts code reviews for PRs that request me, including requests it finds in Slack. In lead mode it triages new Linear issues and checks workflow hygiene. One dashboard shows all of it.

The design decision that matters most is what it doesn't do on its own. Every review, every Linear write, and every merge waits for my click, and every push stays human-initiated behind a hardware key touch. Only two low-risk writes happen automatically, and there's a kill switch for those. Switchboard does the legwork; I keep the decisions.

Once writing code got cheaper, review became the slow part, so I also built [claude-review-code](https://github.com/dakaneye/claude-review-code), a review skill with 12 specialist subagents and checklists for Go, Node, Java, Python, Bash, and Terraform. It does a first pass for the mechanical problems so that human review can focus on design and intent, which is where my early expectation of "more correct" turned out to need the most help.

## Two teams, two adoption curves

I've now watched two teams adopt these tools. Chainguard adopted them more slowly. NetBox Labs adopted them fast.

At NetBox Labs I standardized the team's Claude Code skills and workflows rather than letting everyone build their own. If every engineer has private prompts and agents, you end up with as many quality bars as you have engineers and no easy way to tell them apart. Shared skills give you one bar, and improving it once improves it for everyone. Beyond the workflows above, we share agents for scoping tickets, tracking release readiness, and on-call handoff, plus automated review that works the same way in every repo we ship. We also changed where QA spends its time: instead of writing a manual test plan for each ticket, QA now focuses on automated coverage and regression testing.

## Where AI belongs in a release

The project that shaped my thinking most was one I led at NetBox Labs this summer, which we called Release Guard Rails.

Three releases in a row, 2.1.0 through 2.1.2, failed on preventable mechanical errors. Pins were merged after a failed plan. Fixes never reached the release branch. A promotion ran and silently did nothing. None of these were hard problems, and the people involved weren't careless. The process simply depended on people being careful at every step, every time, and that's not a reasonable thing to depend on.

The goal was to make those failures impossible instead of relying on people being careful, and the design split the work into three layers:

1. **Guard rails block mechanically.** Required checks, branch rulesets, and verification jobs. For example, a check that every fix labeled for a release is actually an ancestor of the release branch, validation of plugin pins against the NetBox version at build time, and a job after every promotion that asserts what shipped matches what was planned.
2. **A release driver handles the mechanics.** It's a Claude Code skill that runs the runbook steps and writes the release record, with evidence for each gate attached. We deliberately started it in status mode, where it reports and documents rather than acts, before letting it do more. Ship-day finalization, meaning the tag, the GitHub Release, and the appliance build, now fires automatically.
3. **Humans keep the judgment calls.** Sign-offs, scope, and demotions stay with people, and that split doesn't change as more automation lands.

Two governance rules made it stick. Every rail cites the specific failure that created it, so nobody has to guess why a check exists. And rails get ratified for enforcement at release retros, so the team decides together what becomes mandatory rather than having rules appear on them. The result was what we wanted: releases became more reliable, with fewer errors during the release itself.

This is the model I keep coming back to for AI more generally, and it's the same one behind Switchboard and the fix workflows. The agent is good at running mechanics and writing things down. Deterministic checks are better at blocking mistakes, because they don't get creative. And people are still the right ones to make the calls that involve judgment.

## What I'm still unsure about

I have two open questions that I don't think I can answer yet.

The first is whether AI actually makes me faster, in a way I could prove. It feels faster, and I get more done in parallel than I used to. But I've also spent time reviewing, correcting, and re-prompting work that I might have written correctly myself the first time, and I don't have a clean measurement that settles it.

The second is what I think of as dark code: code that's in the repository, passes every check, and that no person actually wrote or fully understands. Specs, evidence gates, and guard rails reduce the risk, but I'm not convinced they remove it, and I suspect it's a cost that shows up later rather than sooner.

I don't work for, invest in, or advise any AI companies. For what it's worth, nearly all of my experience is with Claude, so I can't speak to how other tools compare.
