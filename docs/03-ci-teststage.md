Studio 5000 DevOps – CI Test Stage Guide
Who This Is For

This guide is for readers who already understand the basic CI pipeline flow and want to know what the test stage is actually doing.

Read this after:

docs/02-ci-pipeline-setup.md

This document explains:

what Jenkins runs during the CI stage
what each PowerShell script does
how the generated ACD is passed into the test harness
what the test harness does with Echo and Logix
what the current boiler tests are checking
how pass/fail is determined

This is not a full troubleshooting guide. It is the “what this stage actually does” guide.

What the CI Test Stage Proves

The CI stage in this demo is not just rebuilding files.

It proves that a Studio 5000 project can be:

rebuilt from repo-managed exploded content
turned back into generated project artifacts
loaded into Logix Echo
tested automatically for expected controller behavior

That is the real value of this stage. It is not just “did the project build?” It is also “does the logic still behave the way we expect?”

Where the CI Test Stage Lives

The CI test-stage files live under:

02-ci\

The main folders involved are:

02-ci\
├─ jenkins\
│  └─ Jenkinsfile_CI
├─ pipeline-scripts\
│  ├─ implode-content.ps1
│  ├─ l5x-to-acd.ps1
│  └─ run-ci-tests.ps1
├─ generated\
│  ├─ l5x\
│  └─ acd\
└─ test-harness\
   ├─ ConsoleFormatter_ClassLibrary\
   ├─ LogixDesigner_ClassLibrary\
   ├─ LogixEcho_ClassLibrary\
   ├─ UnitTesting_ConsoleApp\
   └─ LogixUnitTesting.sln

That structure matches the current repo tree for the demo.

How the Jenkinsfile Uses the Test Stage

The Jenkinsfile is the orchestrator. It defines:

the stage order
repo-relative paths
external tool paths
which PowerShell scripts run

The current CI pipeline uses these stages:

Checkout
Validate Repository Structure
Prepare Output Folders
Implode Exploded Content to L5X
Convert L5X to ACD
Run Echo CI Tests

The test-stage internals mainly live in the last three stages:

Implode Exploded Content to L5X
Convert L5X to ACD
Run Echo CI Tests

The Jenkinsfile should stay readable and keep the heavy lifting in PowerShell scripts. That was one of the main lessons from the setup effort.

Pipeline Scripts Overview

The PowerShell scripts for the CI stage live under:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\

Current scripts:

implode-content.ps1
l5x-to-acd.ps1
run-ci-tests.ps1

These scripts do the real work:

rebuild .L5X from exploded content
rebuild .ACD from .L5X
restore, build, and run the .NET test harness

This split is deliberate. It keeps the Jenkinsfile simpler and makes each stage easier to test outside Jenkins.

Script 1 – implode-content.ps1

Path:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\implode-content.ps1
Purpose

This script takes the exploded Studio 5000 content from the repo and rebuilds it into a single .L5X file.

Its job is to:

verify the exploded input folder exists
create the output folder if needed
delete the old generated .L5X
run l5xplode implode
fail if the tool exits nonzero
fail if the expected .L5X file is not created
Expected input
C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\exploded-content
Expected output
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\l5x\BoilerDemo_CI.l5x
Exact command used inside the script
& $ImplodeToolPath implode --dir $resolvedInput --l5x $outputPathFull

That command matches the working CI notes.

What success looks like

Success means:

the input folder is found
the output folder exists
the tool runs without error
BoilerDemo_CI.l5x exists afterward
What failure looks like

This stage fails if:

the input folder is missing
the tool exits with an error
the .L5X file does not exist after the command runs
Script 2 – l5x-to-acd.ps1

Path:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\l5x-to-acd.ps1
Purpose

This script takes the generated .L5X and converts it into a generated .ACD.

Its job is to:

verify the input .L5X exists
create the output folder if needed
run l5xgit l5x2acd
fail if the tool exits nonzero
fail if the expected .ACD file is not created
Expected input
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\l5x\BoilerDemo_CI.l5x
Expected output
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\acd\BoilerDemo_CI.ACD
Exact command used inside the script
& $ConverterToolPath l5x2acd --l5x $resolvedInput --acd $outputPathFull

That matches the working setup notes.

Important current behavior

This is a real caveat.

Observed behavior suggests that l5xgit l5x2acd currently expects an existing .ACD file at the target path. In practice, the working flow behaves more like:

existing ACD + generated L5X -> updated/generated ACD

not yet a fully proven:

nothing -> brand-new ACD

This matters because it affects how you should describe the rebuild flow. The current demo should not overclaim that it is doing a clean-room rebuild from nothing.

What success looks like

Success means:

the input .L5X exists
the tool runs without error
BoilerDemo_CI.ACD exists afterward
What failure looks like

This stage fails if:

the input .L5X is missing
the tool exits with an error
the .ACD file is missing afterward
Script 3 – run-ci-tests.ps1

Path:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\pipeline-scripts\run-ci-tests.ps1
Purpose

This script owns the CI test run.

Its job is to:

resolve the solution path
locate the console app project
run dotnet restore
run dotnet build
check whether the ACD exists
run the console harness if the ACD exists
fail if the harness exits nonzero
Main inputs
AcdPath
SolutionPath
Configuration
RequireAcd
Exact commands used inside the script

Restore:

dotnet restore $resolvedSolution

Build:

dotnet build $resolvedSolution -c $Configuration --no-restore

Run harness:

dotnet run --project $consoleProject -c $Configuration -- $resolvedAcd

These commands match the working CI notes.

Why this split is good

Letting this script own restore, build, and run is cleaner than splitting those tasks between Jenkins and inline shell commands. That was one of the main lessons from the working setup.

ACD argument contract

This line is the key contract point:

dotnet run --project $consoleProject -c $Configuration -- $resolvedAcd

That final -- $resolvedAcd passes the generated ACD path into the console app as args[0]. This is the correct CI pattern because the harness should use the file Jenkins just generated, not a hardcoded desktop path.

What success looks like

Success means:

solution path resolves
console project is found
restore succeeds
build succeeds
the generated ACD exists
the console app launches
the console app exits with code 0
What failure looks like

This stage fails if:

the solution path cannot be resolved
the console project is missing
restore fails
build fails
the ACD is required and missing
the harness exits nonzero

That is why restore, build, and runtime should be treated as separate failure checkpoints.

Script-to-Stage Mapping

Here is the mapping between Jenkins stages and scripts:

Jenkins stage	Script
Implode Exploded Content to L5X	02-ci\pipeline-scripts\implode-content.ps1
Convert L5X to ACD	02-ci\pipeline-scripts\l5x-to-acd.ps1
Run Echo CI Tests	02-ci\pipeline-scripts\run-ci-tests.ps1

The earlier Jenkins stages (Checkout, Validate Repository Structure, Prepare Output Folders) are setup/orchestration stages. The scripted CI work happens in the last three.

Manual PowerShell Examples

These examples are for learning and troubleshooting. They let you run each CI script directly in PowerShell without waiting on Jenkins.

Use the desktop repo path when running the scripts manually:

C:\Users\DevOps\Desktop\boiler-devops-demo

Use the Jenkins workspace path when checking what Jenkins itself created:

C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI

That distinction matters. Jenkins runs against its workspace copy of the repo, not the desktop copy.

Example: implode manually from the desktop repo
.\implode-content.ps1 `
  -InputPath "C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\exploded-content" `
  -OutputPath "C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\l5x\BoilerDemo_CI.l5x" `
  -ImplodeToolPath "C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xplode.exe"
Example: convert L5X to ACD manually from the desktop repo
.\l5x-to-acd.ps1 `
  -InputPath "C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\l5x\BoilerDemo_CI.l5x" `
  -OutputPath "C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\acd\BoilerDemo_CI.ACD" `
  -ConverterToolPath "C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xgit.exe"
Example: run CI tests manually from the desktop repo
.\run-ci-tests.ps1 `
  -AcdPath "C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\generated\acd\BoilerDemo_CI.ACD" `
  -SolutionPath "C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\LogixUnitTesting.sln" `
  -Configuration "Release" `
  -RequireAcd
Example: inspect the files Jenkins created
C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI\02-ci\generated\l5x\BoilerDemo_CI.l5x
C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI\02-ci\generated\acd\BoilerDemo_CI.ACD
C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI\02-ci\test-harness\LogixUnitTesting.sln
Test Harness Overview

The CI pipeline does not directly test controller behavior by itself. Jenkins runs a .NET console application, and that console application acts as the test harness for the rebuilt project.

In this demo, Jenkins is the orchestrator. The console app is the part that:

accepts the generated ACD path
provisions or reuses an Echo target
downloads the rebuilt project
changes controller mode
writes test inputs
reads test outputs
returns pass or fail to Jenkins through its exit code

This means the CI stage is not just “build validation.” It is an integration test of the rebuilt controller project.

Where the Test Harness Lives

The harness code lives under:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\

Important files and folders include:

C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\LogixUnitTesting.sln
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\ConsoleFormatter_ClassLibrary\
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\LogixDesigner_ClassLibrary\
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\LogixEcho_ClassLibrary\
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\UnitTesting_ConsoleApp\
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\UnitTesting_ConsoleApp\UnitTesting_ConsoleApp.csproj
C:\Users\DevOps\Desktop\boiler-devops-demo\02-ci\test-harness\UnitTesting_ConsoleApp\UnitTestProgram.cs

That structure separates:

console formatting/helper code
Echo-related code
Logix Designer-related code
the main test runner
What the Console App Expects

The console app entry point is Main(string[] args) in UnitTestProgram.cs.

It currently supports these runtime arguments:

args[0] = ACD path
args[1] = optional chassis name
args[2] = optional cleanup flag

Current defaults:

ACD path fallback = C:\CI-Pipeline-Files\BoilerDemo.ACD
chassis name fallback = DemoChassis
cleanup fallback = true

That contract was also described in the working setup notes.

For CI, the important part is that Jenkins passes the generated ACD path in at runtime. The harness should not depend on a hardcoded local file path.

What the Harness Does During a Run

At a high level, the console app does this:

reads the ACD path argument
validates the ACD file exists
connects to the Echo service
creates or reuses a chassis
reads controller metadata from the ACD
creates or reuses the controller in Echo
computes the communication path
opens the project through Logix Designer SDK
changes the controller to Program mode
downloads the ACD
changes the controller to Run mode
runs functional logic checks
reports pass or fail
optionally cleans up the Echo chassis on exit

This is why the test stage is valuable. It is validating controller behavior after rebuild, not merely proving that some files exist.

Why Flat Atomic Tags Are Used

The current harness uses flat controller-scoped tags like:

Tank1_ValveInStatus
Tank1_ValveInCmd
Tank1_ValveOutStatus
Tank1_ValveOutCmd
Tank1_Level
Tank1_SetPoint
and matching tags for Tank2

This is a deliberate design choice, not laziness.

Earlier setup notes showed that flat atomic tags worked reliably with LDSDK online read/write methods, while direct UDT member access was not as practical for a beginner-friendly public demo. For this CI demo, a flat test interface makes the harness simpler, clearer, and more reliable.

Current Boiler Logic Tests

The current harness runs 8 functional checks.

Tank 1
inlet opens below setpoint
inlet blocked at setpoint
outlet opens above zero
outlet blocked at zero
Tank 2
inlet opens below setpoint
inlet blocked at setpoint
outlet opens above zero
outlet blocked at zero

These tests were described in the working setup notes and were part of the first usable end-to-end CI run.

Test pattern

The harness uses a simple pattern:

reset known values
write input tags
wait briefly
read output tags
compare expected vs actual
count failures
move to the next test

This is a good beginner pattern because it behaves like a small readable test framework instead of a mystery script.

Pass / Fail Behavior

The console app returns:

0 when all tests pass
1 when the ACD is missing
1 when an exception occurs
1 when any test fails

That behavior was explicitly described in the working notes.

Example final output behavior

When failures are found, the harness prints output like:

=== FINAL RESULT ===
FAIL | 2 issue(s) found.

When all tests pass, it prints output indicating success.

This is exactly what Jenkins needs. The console app decides pass/fail and Jenkins reads the exit code.

Cleanup Behavior

At the end of the run, the harness:

attempts to clean up its session
optionally deletes the Echo chassis if cleanup is enabled

The working notes described cleanup output like:

Cleaning up Echo chassis 'DemoChassis'...
Echo cleanup complete.

That cleanup behavior is helpful for repeatable demos because it reduces leftover state between runs.

What the First Real CI Result Proved

One of the most useful outcomes of the working demo is that the first end-to-end run did not just prove the pipeline plumbing.

It proved that the harness could:

launch with the generated ACD
provision Echo resources
run through Logix workflow
execute real functional tests
fail for a meaningful controller-logic reason rather than a Jenkins reason

The reported first useful result was:

passes on tests 1, 2, 4, 5, 6, and 8
failures on tests 3 and 7

Those were the “outlet opens above zero” checks for both tanks. That is a strong teaching point:

Once the CI plumbing is working, a red build can be good news. It means the pipeline is now catching real logic mismatches instead of just falling over on setup.