Studio 5000 DevOps – Overview
What This Repo Is

This repo is a beginner-friendly demo of a Studio 5000 DevOps workflow.

It is meant to show how a Studio 5000 project can move through three connected ideas:

VCS – turn a controller project into Git-friendly exploded content
CI – rebuild project artifacts from repo content and run automated checks
CD – leave room for future deployment-stage work

Right now, the strongest and most complete parts of the repo are the VCS and CI sections. The CD section exists as a placeholder structure, but it is not the main focus yet.

What This Demo Is Trying To Prove

At a high level, this repo is trying to prove that a Studio 5000 workflow can be made more transparent, more versionable, and more testable.

The basic story is:

start with a Studio 5000 project
export and explode it into Git-friendly content
commit and push the source-controlled content
let Jenkins detect the change
rebuild generated artifacts from the repo
run an automated test harness against the rebuilt project
clearly report pass or fail

That is the core value of the demo: not just storing files in Git, but actually validating controller behavior after a rebuild.

What the Main Sections Mean
01-vcs/

This is the version control side of the demo.

It shows how to take a Studio 5000 project and turn it into exploded text-based content that Git can actually track in a meaningful way. The 01-vcs area includes:

original ACD source files
L5X source files
exploded content
a manual build area
examples

Important idea: for this workflow, the exploded content is the Git-friendly source representation.

02-ci/

This is the continuous integration side of the demo.

It contains:

the Jenkins pipeline definition
PowerShell scripts for rebuild and test flow
generated L5X and ACD folders
sample inputs and outputs
the .NET test harness solution and projects

Important idea: Jenkins rebuilds from repo content and runs the automated test harness.

03-cd/

This is the deployment-stage area.

Right now it is mainly structure:

deployment scripts
a CD Jenkinsfile
templates

Important idea: CD is part of the long-term architecture, but it is not the most developed part of the demo today.

04-shared/

This is the shared-support area for things that do not belong only to VCS, CI, or CD.

It includes:

config templates
helper scripts
package version notes
05-demo-assets/

This is where demo-friendly artifacts can live, such as:

sample pass/fail output
sample failure output
screenshots
test data
99-local-dev/

This is the local-only helper area for things like:

local restore scripts
local run scripts
notes
docs/

This is the documentation set for the repo. It is where the repo is explained in a step-by-step way instead of making readers reverse-engineer the whole thing from scripts and folders.

The Most Important Architecture Decision

The most important idea in this repo is:

exploded content in Git is the source of truth

That means:

the exploded project content is what gets versioned
generated .L5X and .ACD files are artifacts
Jenkins should rebuild from repo content during CI
generated output should go into generated/output folders, not become the main source files

If a reader misses that idea, the rest of the repo gets confusing fast.

How the Docs Are Meant To Be Read

The recommended reading order is:

docs/01-vcs-setup.md
Start here to understand how the Studio 5000 project becomes Git-friendly exploded content.
docs/02-ci-pipeline-setup.md
Read this next to understand how Jenkins is set up and how the CI pipeline is supposed to run.
docs/03-ci-teststage.md
Read this after setup to understand what the CI stage is actually doing under the hood.
docs/06-known-issues-and-gotchas.md
Read this when you want the practical warning labels and the lessons learned from the real setup effort.

Later, the repo can also include:

a demo walkthrough
a limitations document
fuller CD guidance
What This Repo Is Not

This repo is not:

a polished enterprise standard
a complete production CI/CD platform
a guarantee that every Studio 5000 workflow behaves the same way
a fully mature CD example today

It is a practical demo repo meant to teach the ideas clearly and honestly. The docs already describe some areas where the workflow is still a little sharp around the edges, especially around rebuild behavior and environment dependencies.

What a Reader Should Walk Away With

By the time someone finishes the current docs, they should understand:

how a Studio 5000 project can be represented in Git-friendly exploded form
how Jenkins can rebuild project artifacts from repo content
how a test harness can validate controller behavior after rebuild
why generated artifacts are not the source of truth
where the current demo is strong
where the current demo is still intentionally incomplete

That is enough to make the repo useful as a learning tool instead of just a folder full of interesting files and dangerous optimism.

Repo at a Glance
boiler-devops-demo/
├─ 01-vcs/        # version control workflow
├─ 02-ci/         # continuous integration workflow
├─ 03-cd/         # future deployment workflow
├─ 04-shared/     # shared helpers and templates
├─ 05-demo-assets/# screenshots, sample output, demo material
├─ 99-local-dev/  # local-only helper scripts and notes
└─ docs/          # step-by-step documentation

This is the simple mental model:

01-vcs = make the project versionable
02-ci = make the project rebuildable and testable
03-cd = make room for future deployment flow

That is the repo in one breath.