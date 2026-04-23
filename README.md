# Boiler DevOps Demo

An unofficial personal demo repo showing one practical way to apply version control, CI, and optional CD ideas to Studio 5000 projects.

This is not an official Rockwell Automation example. It is a public learning repo built to show what is possible, what is confusing, and what was learned while getting the pieces working.

The goal is to help controls engineers, OEMs, system integrators, and curious early adopters understand how a Studio 5000 project can move through a more modern workflow:

**versioned project content → automated validation → optional deployment**

---

## What This Repo Demonstrates

This repo is organized around three related but separate ideas:

### 1. VCS
How a Studio 5000 project can be converted into a version-friendly structure that works better with Git than a binary ACD file.

### 2. CI
How Jenkins can take versioned project content, rebuild usable artifacts, and run automated validation against an emulated controller workflow.

### 3. CD
How a deployment stage could be added later after validation is working reliably.

These are discussed together because they are connected, but they are intentionally separated in the repo so each part can be understood on its own.

---

## What This Repo Is Not

This repo is not:

- an official vendor-supported solution
- a polished production framework
- a complete troubleshooting guide for every environment
- a promise that every SDK or authentication path will behave the same on every machine

It is a practical demo built from real setup experience, including the parts that wasted time and the parts that finally worked.

---

## Who This Is For

This repo is for people who are:

- new to Git or version control in the Studio 5000 world
- curious about CI for industrial automation projects
- trying to understand what "DevOps" could mean for Logix workflows
- looking for a public example that is more hands-on than marketing material

You do not need to already know VCS, CI, or CD to get value from this repo.

---

## Core Idea

We do **not** treat the ACD file as the main version-controlled artifact.

Instead, the general workflow looks like this:

1. Start with a Studio 5000 project
2. Convert it into an L5X-based representation
3. Explode that content into Git-friendly files
4. Track those files in version control
5. Rebuild usable artifacts from repo content in CI
6. Run automated validation
7. Optionally add deployment later

That separation matters:

- **VCS** is for readable history and change tracking
- **CI** is for automated validation
- **CD** is for deployment after validation

---

## Repo Structure

```text
boiler-devops-demo/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ docs/
│  ├─ 00-overview.md
│  ├─ 01-vcs-setup.md
│  ├─ 02-ci-pipeline-setup.md
│  ├─ 03-ci-teststage.md
│  ├─ 04-cd-deployment-stage.md
│  ├─ 05-demo-walkthrough.md
│  ├─ 06-known-issues-and-gotchas.md
│  └─ 07-limitations-and-what-is-not-included.md
├─ 01-vcs/
│  ├─ acd-source/
│  ├─ l5x-source/
│  ├─ exploded-content/
│  └─ examples/
├─ 02-ci/
│  ├─ jenkins/
│  ├─ pipeline-scripts/
│  ├─ test-harness/
│  ├─ generated/
│  └─ sample-output/
├─ 03-cd/
│  ├─ jenkins/
│  ├─ deployment-scripts/
│  └─ templates/
├─ 04-shared/
│  ├─ config-templates/
│  ├─ package-version-notes/
│  └─ helper-scripts/
├─ 05-demo-assets/
│  ├─ screenshots/
│  ├─ sample-pass-output/
│  ├─ sample-failure-output/
│  └─ sample-test-data/
└─ 99-local-dev/
   ├─ restore-local.ps1
   ├─ run-local.ps1
   └─ notes/
```
---

## Start Here

If you are new to this topic, follow the docs in order:

1. `docs/00-overview.md`
2. `docs/01-vcs-setup.md`
3. `docs/02-ci-pipeline-setup.md`
4. `docs/03-ci-teststage.md`

After that, use these as needed:

- `docs/04-cd-deployment-stage.md`
- `docs/05-demo-walkthrough.md`
- `docs/06-known-issues-and-gotchas.md`
- `docs/07-limitations-and-what-is-not-included.md`

The docs are written as a guided path, not as a reference manual that assumes you already know the territory.

## VCS in Plain Language

Studio 5000 ACD files are not ideal for Git history or diffs because they are not a human-friendly text format.

A more version-friendly pattern is:

- convert ACD to L5X
- explode L5X into structured files
- commit those structured files to Git

That gives you something closer to normal source control behavior:

- readable file changes
- commit history
- branch workflows
- easier code review

## CI in Plain Language

The CI side watches for changes in the repo and runs an automated workflow.

In this demo, the intended CI story is:

1. Jenkins pulls the repo
2. Pipeline scripts rebuild usable project artifacts from versioned content
3. A test harness runs validation logic
4. The job clearly passes or fails

The point is not just "run a script." The point is to catch bad changes automatically before they spread.

## CD in Plain Language

CD is optional in this repo.

The deployment stage is separated on purpose because many teams may want:

- VCS only
- VCS + CI only
- VCS + CI + CD later

This repo is structured so those ideas can be explored independently.

## Demo Story

The main demo story is simple:

1. Make a bad logic change
2. Save and commit it through the version-controlled workflow
3. Trigger CI
4. Rebuild testable artifacts from repo content
5. Run automated tests
6. Show the failure clearly
7. Fix or revert the change
8. Run again
9. Show the pass

That is the heart of the repo.

## External Tools and Dependencies

This repo may reference external tools such as:

- Git
- .NET 8 SDK
- Jenkins
- Studio 5000-related VCS tooling
- Echo / Logix SDK components where applicable

Some vendor packages, proprietary project files, or licensed components are not included in the public repo.

See:

- `docs/01-vcs-setup.md`
- `docs/02-ci-pipeline-setup.md`
- `docs/07-limitations-and-what-is-not-included.md`

## Important Practical Notes

A few important lessons from this project:

- readable version control requires working with structured text-based content, not only raw ACD files
- CI is easier to explain when it consumes repo content and generates testable artifacts
- setup details matter more than people expect
- some workflows are reliable enough for demos but still environment-sensitive
- documenting the gotchas is part of the value

This repo is meant to save other people time, not just show a happy-path screenshot.

## Suggested Audience Use

You can use this repo to:

- learn the workflow step by step
- build your own proof of concept
- borrow the structure for internal demos
- explain DevOps ideas to controls engineers in plain language
- show that VCS, CI, and CD can be related without being the same thing

## Status

This repo is a working demo and learning resource, not a finished product.

Some pieces are intentionally separated, simplified, or left optional so the concepts are easier to understand and adapt.

## License

See `LICENSE`.