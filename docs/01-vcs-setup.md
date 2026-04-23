# VCS Setup for the Boiler DevOps Demo

## What This Document Covers

This guide explains the version control side of the demo.

The goal is to show how a Studio 5000 project can be moved into a format that works better with Git than a binary ACD file.

By the end of this guide, you should understand:

- why the ACD file is not the main version-controlled artifact
- how ACD, L5X, and exploded content relate to each other
- where the VCS content lives in this demo repo
- how to create a first commit using either Studio 5000 or PowerShell

This is a learning-focused workflow, not a polished production standard.

---

## Why This Matters

Git works best with text-based files that can be compared between commits.

A Studio 5000 ACD file is not ideal for that because it is a binary project file. You can store it in Git, but Git cannot show useful diffs the way it can for normal source files.

For this demo, the better pattern is:

1. start with an ACD
2. convert it to L5X
3. explode the L5X into structured files
4. commit those structured files to Git

That gives you:

- readable changes
- branch history
- easier reviews
- a better path into CI later

---

## What the VCS Side Looks Like in This Demo

In this repo, the VCS portion lives under:

```text
01-vcs/
├─ acd-source/
├─ l5x-source/
├─ exploded-content/
└─ examples/

Folder Purpose
acd-source/
Starting ACD files used for the demo. Think of this as the original Studio 5000 project input.
l5x-source/
L5X exports created from the ACD.
exploded-content/
Git-friendly structured files created from the L5X. This is the main version-controlled representation of the project.
examples/
Optional sample changes, screenshots, or small reference examples related to the VCS workflow.
Important Idea

For this demo, the exploded content is the main source-controlled form.

That does not mean the ACD stops mattering. It means the ACD is not the best file for readable Git history.

Relationship Between ACD, L5X, and Exploded Content

Think of the flow like this:

ACD -> L5X -> exploded content -> Git
Plain-English meaning
ACD = the Studio 5000 project file
L5X = an export format that is easier to process
exploded content = structured files broken into smaller pieces for source control
Git = where those structured files are tracked over time

Later in CI, the flow can go the other direction:

Git -> exploded content -> L5X -> ACD -> automated validation

That is why the VCS setup matters. It creates the versioned source representation that CI can build from later.

Prerequisites

Before starting, make sure you have:

Windows
.NET 8 SDK
Git
access to the Studio 5000 VCS custom tools
a Studio 5000 ACD file to use for the demo

If you are following the full repo in order, the shared overview and prerequisites docs will eventually cover more environment details. This page focuses only on the VCS side.

Install .NET 8 SDK

Download and install the .NET 8 SDK for Windows.

After installing, open PowerShell and run:

dotnet --version

You should see a version number.

Install Git

Install Git for Windows.

After installing, open a new PowerShell window and run:

git --version

You should see a version number.

Get the VCS Tools

This demo uses the Logix Designer VCS custom tools repository.

Option A - Clone with Git
git clone https://github.com/RockwellAutomation/ra-logix-designer-vcs-custom-tools.git
cd ra-logix-designer-vcs-custom-tools
Option B - Download ZIP
download the repository ZIP
extract it locally
open PowerShell in the extracted folder
Build the Tools

From the tools repository folder, run:

dotnet build -c Release

Wait for the build to complete successfully.

The build output should appear under:

artifacts\bin\Release
Verify the Tools

From the build output folder, run:

.\l5xgit.exe -h

If needed, you can also try:

dotnet .\l5xgit.dll -h

If help text appears, the tool is available.

Optional: Add the Tools into Studio 5000

This step is only needed if you want to use the Studio 5000 menu-based workflow.

After building the tools, locate:

Path to your cloned repo\artifacts\bin\Release\Assets\CustomToolsMenu.xml

Copy that file into:

C:\Program Files (x86)\Rockwell Software\RSLogix 5000\Common\

Then restart Studio 5000.

If you are only using the manual PowerShell workflow, this step is not required.

Prepare the Demo Folders

Inside your demo repo, the VCS folders should look like this:

01-vcs/
├─ acd-source/
├─ l5x-source/
├─ exploded-content/
└─ examples/

A simple starting point is:

place your original ACD in 01-vcs/acd-source/
create your L5X export in 01-vcs/l5x-source/
create exploded content in 01-vcs/exploded-content/

Example:

01-vcs/
├─ acd-source/
│  └─ BoilerDemo.ACD
├─ l5x-source/
│  └─ BoilerDemo.L5X
├─ exploded-content/
│  └─ RSLogix5000Content/
└─ examples/
What Is RSLogix5000Content

The RSLogix5000Content folder is the exploded project representation.

It breaks the project into smaller, more Git-friendly pieces.

Common subfolders may include:

Programs/
Tags/
Tasks/
Modules/
DataTypes/
AddOnInstructionDefinitions/

You will also typically see files such as:

RSLogix5000Content.xml
export-options.yaml

This is the content Git can compare meaningfully across commits.

Initialize Git in the Demo Repo

From the root of your demo repo, run:

git init

If the repo already exists on GitHub, you may instead clone it first and work from that clone.

Workflow Option 1 - Use Studio 5000

This is the easier workflow to understand if you want to see the tool integration from inside Studio 5000.

Steps
Open your ACD in Studio 5000
Go to Tools -> Commit
When prompted for the target directory, choose your exploded content folder

Example:

Path to your repo\01-vcs\exploded-content
If prompted for a commit message, enter one
Complete the commit
What Happens Behind the Scenes

The high-level flow is:

ACD -> L5X -> explode -> git add -> git commit
Result

You should now have:

an exploded content folder under 01-vcs/exploded-content/
a Git commit containing that structured content
Workflow Option 2 - Use PowerShell

This option is better if you want to understand the individual steps more clearly or automate them later.

Run these commands from the VCS tools build output folder.

Step 1 - Convert ACD to L5X
.\l5xgit.exe acd2l5x `
  --acd "Path to your repo\01-vcs\acd-source\BoilerDemo.ACD" `
  --l5x "Path to your repo\01-vcs\l5x-source\BoilerDemo.L5X"
Step 2 - Explode L5X into Structured Files
.\l5xplode.exe explode `
  --l5x "Path to your repo\01-vcs\l5x-source\BoilerDemo.L5X" `
  --dir "Path to your repo\01-vcs\exploded-content"
Step 3 - Commit to Git

From the root of your demo repo:

git add .
git commit -m "Initial VCS setup for BoilerDemo"
Result

You should now have:

01-vcs/
├─ acd-source/
├─ l5x-source/
└─ exploded-content/
   └─ RSLogix5000Content/

and a commit in Git tracking the exploded content.

Verify the Commit

Run:

git log --oneline

You should see your commit in the history.

You can also run:

git status

to confirm whether there are any uncommitted changes left.

Studio vs PowerShell Summary
Step	Studio 5000	PowerShell
Convert ACD to L5X	automatic	explicit command
Explode into structured files	automatic	explicit command
Commit to Git	integrated flow	git add + git commit

Both workflows get you to the same place:

version-controlled exploded project content

What This Means for the Rest of the Demo

This VCS workflow is the first layer of the overall demo.

Later sections build on it:

the VCS side creates a readable, trackable project representation
the CI side can consume repo content and rebuild testable artifacts
the CD side can be added later if needed

That is why the folders are separated in the repo even though the concepts are connected.

Watch Out

A few practical notes:

the build output for the VCS tools is under artifacts\bin\Release
CustomToolsMenu.xml only appears after the build
replace placeholder paths with your own real paths
exploded content is for version control, not direct controller download
this workflow is useful even if you are not ready to implement CI yet
Key Concept to Remember
explode = create Git-friendly files
commit = save a version in Git

That is the whole point of the VCS side of this demo.