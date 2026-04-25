Studio 5000 DevOps – CI Pipeline Setup Guide
Who This Is For

This guide is for beginners who want to understand how a simple CI pipeline can work with a Studio 5000 project.

It is written for:

controls engineers who are new to Jenkins, CI, or DevOps
anyone trying to reproduce the Boiler DevOps Demo pipeline
people who want to understand what Jenkins is actually doing, not just click buttons and hope

This is not a polished enterprise deployment standard.

It is a practical demo workflow that shows how a Studio 5000 source-controlled project can be rebuilt and tested automatically. Some parts are still demo-grade, and a few behaviors are important enough to call out later as known limitations.

The example paths shown below are from the current demo setup. Replace them if your system uses different locations.

Desktop/local repo path used in examples: C:\Users\DevOps\Desktop\boiler-devops-demo

Jenkins workspace path used in examples: C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI

What This Guide Covers

This guide shows how to set up the CI pipeline for the Boiler DevOps Demo repository.

The goal is to help you understand:

what files and folders the repo needs for CI
what Jenkins is expected to do
what the pipeline stages mean
what success looks like after each major step

This guide does not try to teach all of Jenkins, all of DevOps, or every possible Studio 5000 automation workflow.

It is focused on one story:

a change is made in Studio 5000
the project is exported/exploded and committed to Git
Jenkins detects the change
Jenkins rebuilds project artifacts from repo content
Jenkins runs an automated test harness
the pipeline clearly passes or fails

The main idea is simple: CI is not just rebuilding files. It is validating controller behavior after a rebuild.

What This CI Demo Does

At a high level, this pipeline does the following:

A change is made in the Studio 5000 project.
The project is exported/exploded and committed to Git.
Jenkins detects the repo change.
Jenkins checks out the repo into its workspace.
Jenkins reads the exploded project content from the repo.
Jenkins implodes that content into an .L5X file.
Jenkins converts that .L5X into an .ACD.
Jenkins runs a .NET test harness against the rebuilt .ACD.
Jenkins reports pass or fail based on the test harness result.

That last point matters.

Jenkins is not directly testing controller logic by itself. Jenkins is running a repeatable sequence of steps and then launching the test program. The test harness is the part that decides whether the rebuilt controller behaves the way you expect.

Important CI Rules for This Repo

Before setting up Jenkins, keep these rules in your head.

1. Exploded content in Git is the source of truth

In this demo, the text-based exploded project content in the repo is what Jenkins rebuilds from.

That means Jenkins should use repo content such as:

01-vcs\exploded-content

not whatever happens to exist only on a desktop folder.

2. Rebuilt .L5X and .ACD files are generated artifacts

The generated project files are outputs of the pipeline.

They are useful for:

build output
test execution
demo evidence
troubleshooting

They are not the source of truth.

3. Pipeline logic belongs in the repo

The following should live in the repo:

the Jenkinsfile
the PowerShell scripts
the test harness source
sample inputs and sample output

That makes the pipeline easier to understand, easier to reproduce, and less tied to one developer machine.

4. Generated output belongs in CI output folders

Generated files for this demo go under:

02-ci\generated\

Examples:

02-ci\generated\l5x\BoilerDemo_CI.l5x
02-ci\generated\acd\BoilerDemo_CI.ACD
02-ci\generated\logs\

These files can be archived by Jenkins, but they should not be treated like hand-maintained source files.

5. The current L5X-to-ACD step is not a proven clean-room build-from-nothing workflow

Based on the behavior observed during setup, l5xgit l5x2acd appears to work like an update/transform against an existing ACD, not a guaranteed “create brand-new ACD from nothing” command. That matters enough that the docs should say it plainly instead of pretending otherwise.

CI-Focused Repo Structure

The CI part of the Boiler DevOps Demo repo currently looks like this:

02-ci/
├─ generated/
│  ├─ acd/
│  │  └─ BoilerDemo_CI.ACD
│  └─ l5x/
├─ jenkins/
│  └─ Jenkinsfile_CI
├─ pipeline-scripts/
│  ├─ implode-content.ps1
│  ├─ l5x-to-acd.ps1
│  └─ run-ci-tests.ps1
├─ sample-inputs/
│  ├─ AOI_DelayedSum.xlsx
│  ├─ FullApp_ExampleWithCICD_L85E.xlsx
│  └─ ci-inputexcelworkbook-template/
│     └─ UnitTestInput_TEMPLATE.xlsx
├─ sample-output/
└─ test-harness/
   ├─ ConsoleFormatter_ClassLibrary/
   ├─ LogixDesigner_ClassLibrary/
   ├─ LogixEcho_ClassLibrary/
   ├─ UnitTesting_ConsoleApp/
   │  ├─ UnitTesting_ConsoleApp.csproj
   │  └─ UnitTestProgram.cs
   └─ LogixUnitTesting.sln

This is the part of the repo Jenkins interacts with most directly during the CI demo. It contains the pipeline definition, rebuild scripts, generated output folders, sample inputs, and the automated test harness projects.

Purpose
generated/

This folder is for files created by the CI pipeline during a run.

It currently includes:

generated\l5x\ for rebuilt .L5X output
generated\acd\ for rebuilt .ACD output

Example:

02-ci\generated\acd\BoilerDemo_CI.ACD

These files are generated artifacts, not source of truth. Jenkins creates or updates them during the pipeline run.

jenkins/

This folder contains the Jenkins pipeline definition.

Current file:

02-ci\jenkins\Jenkinsfile_CI

This file tells Jenkins:

what stages to run
what repo-relative paths to use
what external tools to call
what PowerShell scripts to run
pipeline-scripts/

This folder contains the PowerShell scripts used by the CI pipeline.

Current scripts:

implode-content.ps1
l5x-to-acd.ps1
run-ci-tests.ps1

These scripts do the actual rebuild and test work:

implode exploded project content into an .L5X
convert the .L5X into an .ACD
restore, build, and run the automated test harness
sample-inputs/

This folder is for example input files used for CI and testing examples.

Current contents include:

AOI_DelayedSum.xlsx
FullApp_ExampleWithCICD_L85E.xlsx
ci-inputexcelworkbook-template\UnitTestInput_TEMPLATE.xlsx
sample-output/

This folder is for example CI output.

It can be used for:

documentation examples
pass/fail screenshots
sample logs
demo-ready artifacts
test-harness/

This folder contains the .NET solution and supporting projects used to test the rebuilt controller project.

Important file:

02-ci\test-harness\LogixUnitTesting.sln

Projects currently included:

ConsoleFormatter_ClassLibrary
LogixDesigner_ClassLibrary
LogixEcho_ClassLibrary
UnitTesting_ConsoleApp

Important console app files:

02-ci\test-harness\UnitTesting_ConsoleApp\UnitTesting_ConsoleApp.csproj
02-ci\test-harness\UnitTesting_ConsoleApp\UnitTestProgram.cs

What Happens Manually vs What Happens in Jenkins

This is the part that usually gets blurred together. Do not blur it together.

Manual / local work

These steps happen outside Jenkins:

Make the change in Studio 5000.
Export/explode the project content.
Commit and push the repo change.
Install and configure Jenkins the first time.
Validate tools and scripts locally while you are building the demo.

This matches the earlier VCS story:

ACD → L5X → explode → git add → git commit

Automated in Jenkins

Once Jenkins detects the repo change, it takes over and performs these steps:

Check out the repo into the Jenkins workspace.
Validate that required paths exist.
Create output folders under 02-ci\generated\.
Implode the exploded content into a generated .L5X.
Convert that .L5X into a generated .ACD.
Restore and build the .NET test harness.
Run the harness against the generated .ACD.
Archive the generated output.

That split matters because beginners often expect Jenkins to somehow know about the project sitting open on their desktop. It does not. Jenkins only knows what is in its workspace copy of the repo and what your pipeline tells it to do.

Prerequisites

Before you create the Jenkins job, make sure the basic pieces below already exist.

This CI pipeline is not a “download Jenkins and miracles happen” setup. Jenkins is only orchestrating a workflow that already depends on Git, .NET, the Rockwell VCS tools, a working test harness, and the Echo / Logix environment behind the test stage.

What should already be true

At minimum, you should already have:

a local clone of the Boiler DevOps Demo repo
the 01-vcs and 02-ci folder structure in place
Jenkins installed and able to run Pipeline jobs
Git installed
.NET 8 SDK installed
the Rockwell VCS tools built and available locally
the test harness solution present in the repo
a local environment that can support the Echo / Logix test stage
Required software
Git

You should be able to open PowerShell and run:

git --version
.NET 8 SDK

The test harness builds and runs as a .NET application targeting net8.0. Verify it with:

dotnet --version

Jenkins

This guide assumes Jenkins is already installed locally and can run a normal Pipeline job.

Rockwell VCS tools

The CI rebuild steps depend on:

l5xplode.exe
l5xgit.exe

In the current working setup, these are referenced with explicit local paths rather than assuming they are on PATH:

C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xplode.exe
C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xgit.exe

Prerequisite check before moving on

Before touching Jenkins, you should be able to point to these repo locations and say “yes, those are real and present”:

C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\exploded-content
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\jenkins\Jenkinsfile_CI
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\implode-content.ps1
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\l5x-to-acd.ps1
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\run-ci-tests.ps1
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\LogixUnitTesting.sln

If those paths are missing, Jenkins is not the first problem.

Jenkins Job Setup

For this demo, Jenkins should be set up as a Pipeline job.

This is important because the pipeline definition lives in the repo. Jenkins reads the pipeline from the repo instead of storing the pipeline logic only inside the Jenkins UI. That makes the setup easier to reproduce and keeps the demo tied to source control instead of one machine’s settings.

Job Type

Create a new Jenkins job of type:

Pipeline
Source Code Repository

Point Jenkins to the Git repository for the Boiler DevOps Demo.

Jenkins should monitor the branch currently used for the CI demo:

*/feature/ci-echo-test-harness

This setup uses a repo-backed pipeline, not inline pipeline text pasted into Jenkins.

Pipeline Script Path

In the Jenkins job configuration, set the pipeline script path to:

02-ci/jenkins/Jenkinsfile_CI

That tells Jenkins where to find the CI pipeline definition inside the repo.

Trigger

For this demo, the practical automatic trigger is:

Poll SCM

with schedule:

H/2 * * * *

This means Jenkins checks the repo every couple of minutes on a staggered schedule and starts a build when it detects a change.

Why Poll SCM Is Used

This Jenkins setup is local.

Because Jenkins is running locally, GitHub webhooks to localhost are not practical for this demo. Poll SCM is the simple option that works without needing extra network exposure or webhook plumbing.

What success looks like

After the job is configured correctly:

Jenkins can connect to the repo
Jenkins can find 02-ci/jenkins/Jenkinsfile_CI
Jenkins starts a pipeline run instead of failing immediately with a missing path or missing script error
What the Jenkinsfile Does

The Jenkinsfile is the orchestrator for the CI stage.

Its job is to define:

the stage order
the repo-relative paths
the external tool locations
which PowerShell scripts run
where generated output should go

The Jenkinsfile should stay readable. The real work should live in the PowerShell scripts under:

02-ci/pipeline-scripts/

That keeps the pipeline easier to explain, easier to test locally, and easier to maintain.

Repo-relative paths used by the pipeline

The current Jenkinsfile uses repo-relative paths like these:

01-vcs/exploded-content
02-ci/generated/l5x
02-ci/generated/acd
02-ci/generated/logs
02-ci/pipeline-scripts
02-ci/test-harness
02-ci/test-harness/LogixUnitTesting.sln
02-ci/generated/l5x/BoilerDemo_CI.l5x
02-ci/generated/acd/BoilerDemo_CI.acd

External tool paths

The current pipeline also uses explicit external tool paths for the Rockwell VCS tools:

C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xplode.exe
C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xgit.exe

That means the demo does not assume these tools are magically available on the system PATH.

Jenkins workspace vs desktop repo

This matters more than people expect.

Jenkins runs the pipeline from its workspace copy of the repo, not from the desktop repo. So when the pipeline creates files, those files are created in the Jenkins workspace.

Example Jenkins workspace path:

C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI\

If a file exists only on the desktop and is not in the repo or copied into the Jenkins workspace by the pipeline, Jenkins does not care.

Pipeline Stage Overview

The current Jenkinsfile uses these stages:

Checkout
Validate Repository Structure
Prepare Output Folders
Implode Exploded Content to L5X
Convert L5X to ACD
Run Echo CI Tests

These stage names are simple, which is good. A beginner should be able to look at the build log and understand roughly where the pipeline is.

1. Checkout

This stage pulls the repo into the Jenkins workspace.

What success looks like:

the stage passes
Jenkins checks out the correct branch
the build log shows normal SCM checkout activity
2. Validate Repository Structure

This stage checks that required repo paths exist before the heavier steps run.

Examples of things Jenkins should be able to find:

01-vcs/exploded-content
02-ci/pipeline-scripts
02-ci/test-harness
02-ci/test-harness/LogixUnitTesting.sln
02-ci/jenkins/Jenkinsfile_CI

What success looks like:

the stage passes quickly
no missing-folder or missing-file errors appear
3. Prepare Output Folders

This stage creates the output folders Jenkins needs during the run.

Current output areas include:

02-ci/generated/l5x
02-ci/generated/acd
02-ci/generated/logs

What success looks like:

the stage passes
these folders exist in the Jenkins workspace after the run starts
4. Implode Exploded Content to L5X

This stage calls the PowerShell script:

02-ci/pipeline-scripts/implode-content.ps1

This takes the repo’s exploded content and produces:

02-ci/generated/l5x/BoilerDemo_CI.l5x

What success looks like:

the stage passes
BoilerDemo_CI.l5x exists under 02-ci/generated/l5x/
5. Convert L5X to ACD

This stage calls:

02-ci/pipeline-scripts/l5x-to-acd.ps1

This takes the generated .L5X and produces:

02-ci/generated/acd/BoilerDemo_CI.ACD

What success looks like:

the stage passes
BoilerDemo_CI.ACD exists under 02-ci/generated/acd/
6. Run Echo CI Tests

This stage calls:

02-ci/pipeline-scripts/run-ci-tests.ps1

This script restores and builds the .NET solution, then runs the test harness against the generated .ACD.

What success looks like:

restore succeeds
build succeeds
the console app launches
the harness prints the generated ACD path from the Jenkins workspace
Echo setup succeeds
download/run succeeds
tests execute
the pipeline ends green or red for a meaningful reason
First-Run Checkpoints

For a beginner, the first good run is not about perfection. It is about proving the flow works in layers.

Here is the proof chain to look for.

Checkpoint 1 — Jenkins starts the pipeline from source control

Success looks like:

Jenkins detects the repo change
the pipeline starts normally
the repo checkout stage passes

This proves the job, branch, trigger, and SCM connection are working.

Checkpoint 2 — The repo structure is valid for CI

Success looks like:

the validation stage passes
Jenkins can find the expected folders and files

This proves the repo has the minimum required plumbing for the CI demo.

Checkpoint 3 — Output folders are created

Success looks like:

Jenkins creates 02-ci/generated/l5x
Jenkins creates 02-ci/generated/acd
Jenkins creates 02-ci/generated/logs

This proves the workspace is writable and the pipeline can prepare its output locations.

Checkpoint 4 — Implode works

Success looks like:

the implode stage passes
a generated .L5X appears in the expected output folder

This proves Jenkins can use repo content to generate a build artifact.

Checkpoint 5 — L5X-to-ACD works

Success looks like:

the conversion stage passes
a generated .ACD appears in the expected output folder

This proves the pipeline can move from text-based source content toward a runnable Studio 5000 artifact.

Checkpoint 6 — The .NET harness restores and builds

Success looks like:

dotnet restore succeeds
dotnet build succeeds
Jenkins shows successful output for the harness projects

This proves the CI test stage is structurally sound before runtime behavior is involved.

Checkpoint 7 — The harness launches with the generated ACD

Success looks like:

the console app starts
it prints the workspace ACD path at startup
it is clearly using the Jenkins-generated file
Checkpoint 8 — Echo setup and Logix workflow succeed

Success looks like:

chassis creation or lookup succeeds
controller info is read from the ACD
controller is created in Echo
communication path is built
controller is changed to Program
ACD is downloaded
controller is changed to Run
Checkpoint 9 — Functional logic tests execute

Success looks like:

the harness writes inputs and reads outputs
all 8 defined tests run
pass/fail output is printed clearly

The current harness runs these 8 checks:

Tank1 inlet opens below setpoint
Tank1 inlet blocked at setpoint
Tank1 outlet opens above zero
Tank1 outlet blocked at zero
Tank2 inlet opens below setpoint
Tank2 inlet blocked at setpoint
Tank2 outlet opens above zero
Tank2 outlet blocked at zero
Checkpoint 10 — A red build can now be useful

One of the most valuable outcomes of the first real run was that the pipeline failed for a controller logic reason, not a Jenkins plumbing reason.

The first usable end-to-end run reportedly passed six checks and failed two outlet-open checks. That is a good teaching point. Once checkout, tooling, rebuild, Echo, and harness execution are working, a red build is no longer “CI is broken.” It can mean the pipeline is doing its job and catching behavior that does not match expectations.