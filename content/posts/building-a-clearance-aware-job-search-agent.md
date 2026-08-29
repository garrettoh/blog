---
title: "My First Agentic Build: A Job Search Tool That Turns Experience Into Better Applications"
date: 2026-08-28
author: garrettoh
draft: false
tags: ["python", "mongodb", "chromadb", "automation", "career-tools", "security-engineering"]
categories: ["Projects"]
---

Job searching looks easy until you actually do it.

You open a pile of tabs, compare requirements with your experience, check whether the application link is real, then rewrite the same resume for the fifth time. It gets old fast.

I built a tool to handle the repetitive parts. This was my first serious taste of agentic development, and I wanted to understand the whole system, not just ask a model for a paragraph and hope for the best.

![Job search dashboard](/images/job-search-agent/dashboard.png)

## The idea

I wanted one place to answer a few practical questions:

- Is this a real, current job posting?
- Does the role fit my skills and experience?
- Which parts of my background matter for this job?
- Can I produce a focused resume without making anything up?

The hard part was the handoff. Search results, profile facts, job requirements, and resume bullets usually sit in separate places. I wanted each step to pass useful information to the next one.

## The subagents

The project is split into small workers with clear responsibilities.

Portfolio Sync refreshes a cache of my public site. Profiler combines that context with my structured profile. Discovery collects and normalizes postings from approved sources.

Then Triage reads the job requirements. Ranking scores technical fit, seniority, portfolio overlap, and the practical path into the role. Resume Tailor finds the strongest supporting facts for a selected posting. Finally, the renderers create DOCX and PDF files.

The orchestrator ties everything together. It validates each handoff and records checkpoints, which makes debugging much less painful. When something goes wrong, I have a decent chance of finding the stage that caused it.

## Turning experience into data

My profile lives as structured data instead of one giant resume blob. It includes roles, dates, skills, projects, education, certifications, preferences, and verified evidence.

The local JSON version keeps development simple. MongoDB gives me a document-backed option for running the application as a service. The nested model feels natural here. Experience has highlights. Projects have technologies. Evidence has sources. Those relationships are useful.

Provenance is the rule I care about most. Every piece of evidence gets an identifier and source information. The resume step can select, reorder, shorten, or restate a verified fact. It cannot invent a credential, change a date, or inflate a number.

## ChromaDB as the memory layer

ChromaDB powers the evidence index. Resume highlights, skills, projects, and portfolio posts become searchable documents with provenance IDs.

When a job comes in, Resume Tailor searches for the evidence that best matches it. A search result is only useful if it maps back to a stored source record. That connection is what keeps the generated resume grounded.

The default setup uses deterministic feature-hash embeddings, so the local version stays lightweight. ChromaDB can persist the vectors without downloading a separate embedding model. There is also an optional semantic path for ambiguous cases.

In practice, the system takes a big record of my experience, breaks it into searchable pieces, and pulls the right pieces back out for a specific role. Much better than starting from a blank page.

## The clearance problem

Clearance language is one of the reasons this project became useful for my job search. A posting might mention sponsorship, eligibility, Public Trust, Secret, or TS/SCI. Those words can point to very different situations.

The triage worker records the evidence behind its decision and passes that context to Ranking. It also checks that application links belong to the employer or an approved applicant-tracking system.

That is one part of the project. The larger goal is making job search decisions easier to inspect and easier to act on.

## A resume with guardrails

After I choose a role, Resume Tailor promotes relevant experience, reorders projects, selects useful skills, and builds a role-specific headline.

The renderer keeps the output to two pages. It checks the document package and extracts the text for ATS verification. The generated files include a manifest with the job, backend choices, evidence references, and artifact hashes.

I still make the final call. The dashboard does not submit applications, create accounts, contact employers, or run in the background. It gives me a sharper shortlist and a better first draft.

## What I learned

The biggest lesson was that agentic development is as much about boundaries as it is about clever behavior.

Each subagent became easier to trust once it had a narrow job, a defined output, and evidence behind its decisions. MongoDB gave the profile a durable home. ChromaDB made the experience searchable. The orchestrator gave the whole thing a spine.

It is still a work in progress, but it already feels more useful than a collection of browser tabs. I can see why a role surfaced, what supports the match, and where the resume content came from.
